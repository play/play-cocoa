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

@interface PLAQueueWindowController ()

@property (retain) NSArray *queue;
@property (retain) PLATrack *currentTrack;

- (void)updateQueue;

@end

@implementation PLAQueueWindowController

@synthesize playButton = _playButton;

@synthesize queue = _queue;
@synthesize currentTrack = _currentTrack;

- (id)init
{	
	return [super initWithWindowNibName:@"PLAQueueWindow"];
}

- (void)dealloc
{
	[_queue release], _queue = nil;
	[_currentTrack release], _currentTrack = nil;
	[super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
		
	[self updateQueue];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueue) name:PLANowPlayingUpdated object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStarted:) name:PLAItemStartedPlayingNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStopped:) name:PLAItemStoppedPlayingNotificationName object:nil];
}

- (void)updateQueue
{
	[PLATrack currentTrackWithBlock: ^ (PLATrack *track, NSError *err) 
	{
		if (track == nil) {
			NSLog(@"Could not get current track: %@", err);
			return;
		}
		
		self.currentTrack = track;
	}];
	
	[PLATrack currentQueueWithBlock: ^ (NSArray *tracks, NSError *err) 
	{
		if (tracks == nil) {
			NSLog(@"Could not get current queue: %@", err);
			return;
		}
		
		self.queue = tracks;
	 }];
}

#pragma mark -
#pragma mark Actions

- (IBAction)togglePlay:(id)sender
{
	[[NSApp delegate] togglePlayState];
}

#pragma mark -
#pragma mark Notification Callbacks

- (void)playbackStarted:(NSNotification *)note
{
	self.playButton.image = [NSImage imageNamed:@"play-button-on"];
	self.playButton.alternateImage = [NSImage imageNamed:@"play-button-on-pushed"];
}

- (void)playbackStopped:(NSNotification *)note
{
	self.playButton.image = [NSImage imageNamed:@"play-button-off"];
	self.playButton.alternateImage = [NSImage imageNamed:@"play-button-off-pushed"];
}

@end
