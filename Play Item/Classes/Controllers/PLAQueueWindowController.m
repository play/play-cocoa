//
//  PLAQueueWindowController.m
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueWindowController.h"

#import "PLAItemAppDelegate.h"
#import "PLAController.h"
#import "PLAShadowTextField.h"
#import "PLATrack.h"

#import "AFNetworking.h"
#import "AudioStreamer.h"

@interface PLAQueueWindowController ()

@property (retain) NSArray *queue;
@property (retain) PLATrack *currentTrack;
@property (nonatomic, readonly) NSOperationQueue *downloadQueue;

- (void)updateQueue;
- (void)updateNowPlayingStarImage;
- (void)downloadTrack:(PLATrack *)track;

@end

@implementation PLAQueueWindowController

@synthesize playButton = _playButton;
@synthesize nowPlayingStarButton = _nowPlayingStarButton;
@synthesize streamDuration = _streamDuration;
@synthesize streamProgress = _streamProgress;

@synthesize queue = _queue;
@synthesize currentTrack = _currentTrack;
@synthesize downloadQueue = _downloadQueue;

- (id)init
{	
	self = [super initWithWindowNibName:@"PLAQueueWindow"];
	if (self == nil)
		return nil;
	
	_downloadQueue = [[NSOperationQueue alloc] init];

	return self;
}

- (void)dealloc
{
	[_queue release], _queue = nil;
	[_currentTrack release], _currentTrack = nil;
	[_downloadQueue release], _downloadQueue = nil;
	[super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	[self.window setOpaque:NO];
	self.window.backgroundColor = [NSColor clearColor];
	[self.window setLevel:NSFloatingWindowLevel];
		
	[self updateQueue];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueue) name:PLANowPlayingUpdated object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStarted:) name:PLAItemStartedPlayingNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStopped:) name:PLAItemStoppedPlayingNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueue) name:PLAItemLoggedInNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:NSWindowDidResignKeyNotification object:self.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:NSApplicationDidResignActiveNotification object:nil];
}

- (void)updateQueue
{
	self.currentTrack = [[PLAController sharedController] currentlyPlayingTrack];
	self.queue = [[PLAController sharedController] queuedTracks];
	
	[self updateNowPlayingStarImage];
}

- (void)updateNowPlayingStarImage
{
	self.nowPlayingStarButton.image = [NSImage imageNamed:(self.currentTrack.starred ? @"starred-pink" : @"unstarred-pink")];
	self.nowPlayingStarButton.alternateImage = [NSImage imageNamed:(self.currentTrack.starred ? @"starred-pink-down" : @"unstarred-pink-down")];
}

#pragma mark -
#pragma mark Actions

- (IBAction)togglePlay:(id)sender
{
	[[NSApp delegate] togglePlayState];
}

- (IBAction)toggleNowPlayingStar:(id)sender
{
	[self.currentTrack toggleStarredWithCompletionBlock:^(BOOL success, NSError *err) {
		if (success)
			[self updateNowPlayingStarImage];
	}];
}

- (IBAction)showPrefs:(id)sender
{
	[[NSApp delegate] flipWindowToLogin];
}

NSURL *(^downloadsFolderLocation)() = ^ 
{
	NSArray *downloadFolderPaths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
	if (downloadFolderPaths.count < 1)
		return (NSURL *)nil;
	
	return (NSURL *)[NSURL fileURLWithPath:[downloadFolderPaths objectAtIndex:0]];
};

- (void)downloadTrack:(PLATrack *)track
{
	if (track == nil)
		return;
	
	NSURL *downloadsFolder = downloadsFolderLocation();
	if (downloadsFolder == nil) {
		NSBeep();
		return;
	}
	
	NSURL *targetURL = [downloadsFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.m4a", track.name, track.artist]]; //I'm just guessing m4a… there should probably be a smart way to get the format
	NSOutputStream *outStream = [NSOutputStream outputStreamWithURL:targetURL append:NO];
	AFHTTPRequestOperation *downloadOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:track.downloadURL]] autorelease];
	downloadOperation.outputStream = outStream;
	[downloadOperation setCompletionBlockWithSuccess: ^ (AFHTTPRequestOperation *operation, id responseObject) 
	 {
		 //Um… do something? I guess?
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) 
	 {
		 NSLog(@"%@", error);
		 NSBeep(); // :trollface: we should probably be way better with errors
	 }];
	[self.downloadQueue addOperation:downloadOperation];
}

- (void)downloadAlbumFromTrack:(PLATrack *)track //Being a tad lazy here… should probably abstract this out somewhat… needs to ship it!
{
	if (track == nil)
		return;
	
	NSURL *downloadsFolder = downloadsFolderLocation();
	if (downloadsFolder == nil) {
		NSBeep();
		return;
	}
	
	NSURL *targetURL = [downloadsFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.zip", track.artist, track.album]];
	NSOutputStream *outStream = [NSOutputStream outputStreamWithURL:targetURL append:NO];
	AFHTTPRequestOperation *downloadOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:track.albumDownloadURL]] autorelease];
	downloadOperation.outputStream = outStream;
	[downloadOperation setCompletionBlockWithSuccess: ^ (AFHTTPRequestOperation *operation, id responseObject) 
	 {
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) 
	 {
		 NSLog(@"%@", error);
		 NSBeep();
	 }];
	[self.downloadQueue addOperation:downloadOperation];

}

#pragma mark -
#pragma mark Notification Callbacks

- (void)playbackStarted:(NSNotification *)note
{
	self.playButton.image = [NSImage imageNamed:@"stop-button"];
	self.playButton.alternateImage = [NSImage imageNamed:@"stop-button-down"];
}

- (void)playbackStopped:(NSNotification *)note
{
	self.playButton.image = [NSImage imageNamed:@"play-button"];
	self.playButton.alternateImage = [NSImage imageNamed:@"play-button-down"];
}

#pragma mark -
#pragma mark TableView Delegate

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	return NO;
}

@end
