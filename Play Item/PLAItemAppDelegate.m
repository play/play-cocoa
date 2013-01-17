//
//  PLAItemAppDelegate.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAItemAppDelegate.h"

#import "AudioStreamer.h"

#import "PLAController.h"
#import "PLAPlayClient.h"
#import "PLAItemLogInWindowController.h"
#import "PLAQueueWindowController.h"
#import "PLATrack.h"
#import "SPMediaKeyTap.h"

#import "NSWindow_Flipr.h"

NSString *const PLAItemStartedPlayingNotificationName = @"PLAItemStartedPlayingNotificationName";
NSString *const PLAItemStoppedPlayingNotificationName = @"PLAItemStoppedPlayingNotificationName";
NSString *const PLAItemLoggedInNotificationName = @"PLAItemLoggedInNotificationName";

@interface PLAItemAppDelegate ()

@property (nonatomic, strong) SPMediaKeyTap *keyTap;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (nonatomic, strong) NSWindowController *currentWindowController;

@end

@implementation PLAItemAppDelegate

@synthesize statusItem = _statusItem;
@synthesize logInWindowController = _logInWindowController;
@synthesize streamer = _streamer;

@synthesize keyTap = _keyTap;
@synthesize queueWindowController = _queueWindowController;
@synthesize currentWindowController = _currentWindowController;

- (id)init
{	
	self = [super init];
	if (self == nil)
		return nil;
	
	_queueWindowController = [[PLAQueueWindowController alloc] init];
	_logInWindowController = [[PLAItemLogInWindowController alloc] init];

	return self;
}

- (void)dealloc{
  [self destroyStreamer];

  _keyTap = nil;
	_queueWindowController = nil;
	_currentWindowController = nil;
}

-(void)awakeFromNib{
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [self.statusItem setAction:@selector(toggleWindow:)];
  [self.statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
  [self.statusItem setAlternateImage:[NSImage imageNamed:@"status-icon-inverted.png"]];
  [self.statusItem setHighlightMode:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStarted:) name:PLAItemStartedPlayingNotificationName object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStopped:) name:PLAItemStoppedPlayingNotificationName object:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
  
	//pre-load the queue and login windows.
	self.currentWindowController = self.queueWindowController;
	(void)self.logInWindowController.window;
	(void)self.currentWindowController.window;
	
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [self didLogIn];
      }else{
		  [self toggleWindow:nil]; //Make sure the flip animation happens in the right place
		  [self flipWindowToLogin];
      }
    
    });
  }];
  
    self.keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    [self.keyTap startWatchingMediaKeys];
}

- (void)didLogIn{
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAItemLoggedInNotificationName object:self];
  
  [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *err) {
    [[PLAController sharedController] setCurrentlyPlayingTrack:track];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [PLATrack currentQueueWithBlock:^(NSArray *tracks, NSError *err) {
        [PLAController sharedController].queuedTracks = tracks;
        [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
      }];		
    });

  }];
	
}

- (IBAction)toggleWindow:(id)sender
{
	if (self.currentWindowController.window.isVisible) {
		[self.currentWindowController close];
	} else {
		NSDisableScreenUpdates();
		NSImage *image = self.statusItem.image;
		NSImage *alternateImage = self.statusItem.alternateImage;
		id target = self.statusItem.target;
		SEL action = self.statusItem.action;
		NSView *dummyView = [[NSView alloc] initWithFrame:NSZeroRect];
		self.statusItem.view = dummyView;
		NSWindow *statusItemWindow = [dummyView window]; //Bit of a cheat, but we know here that the last click was in the status item (remember that all menu items are rendered as windows)
		
		//Apparently setting a view has a number of nasty circumstances, repatch everything here
		self.statusItem.view = nil;
		self.statusItem.image = image;
		self.statusItem.alternateImage = alternateImage;
		self.statusItem.highlightMode = YES;
		self.statusItem.target = target;
		self.statusItem.action = action;
		NSEnableScreenUpdates();
		
		NSRect statusItemScreenRect = [statusItemWindow frame]; 
		CGFloat midX = NSMidX(statusItemScreenRect);
		CGFloat windowWidth = NSWidth(self.queueWindowController.window.frame);
		CGFloat windowHeight = NSHeight(self.queueWindowController.window.frame);
		NSRect windowFrame = NSMakeRect(floor(midX - (windowWidth / 2.0)), floor(NSMinY(statusItemScreenRect) - windowHeight - [[NSApp mainMenu] menuBarHeight]), windowWidth, windowHeight);
		
		[self.currentWindowController.window setFrameOrigin:windowFrame.origin];
		[self.currentWindowController showWindow:sender];
		[NSApp activateIgnoringOtherApps:YES];
	}
}


#pragma mark - View State Methods

- (void)flipWindowToLogin
{
	self.currentWindowController = self.logInWindowController;
	[self.queueWindowController.window flipToShowWindow:self.logInWindowController.window forward:YES];
}

- (void)flipWindowToQueue
{
	self.currentWindowController = self.queueWindowController;
	[self.logInWindowController.window flipToShowWindow:self.queueWindowController.window forward:YES];
}

- (IBAction)goToPlay:(id)sender{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[PLAController sharedController] playUrl]]];
}

#pragma mark - Play Methods

- (void)togglePlayState{
  if (self.streamer && [self.streamer isPlaying]) {
		[self destroyStreamer];
  }else{
    [self createStreamer];
    [self.streamer start];
  }
}

- (void)createStreamer{
	if (self.streamer){
		return;
	}
  
  NSString *streamUrl = [[PLAController sharedController] streamUrl];
  
  NSLog(@"opening stream at: %@", streamUrl);
  
	[self destroyStreamer];
  
	self.streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:streamUrl]];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:self.streamer];
}

- (void)destroyStreamer{
	if (self.streamer){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:self.streamer];
		
		[self.streamer stop];
		self.streamer = nil;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PLAItemStoppedPlayingNotificationName object:self];
	}
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([self.streamer isPlaying]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:PLAItemStartedPlayingNotificationName object:self];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:PLAItemStoppedPlayingNotificationName object:self];
	}
}

#pragma mark -
#pragma mark SPMediaKeyTap Delegate

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    if ([event type] != NSSystemDefined || [event subtype] != SPSystemDefinedEventMediaKeys)
        return;
    
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
    
    if (keyState != 1 || keyRepeat > 1 || keyCode != NX_KEYTYPE_PLAY) //Only supporting play/pause for now
        return;
    
    [self togglePlayState];
}

#pragma mark -
#pragma mark Notification Callbacks

- (void)playbackStarted:(NSNotification *)note
{
	self.statusItem.image = [NSImage imageNamed:@"status-icon-on.png"];
}

- (void)playbackStopped:(NSNotification *)note
{
	self.statusItem.image = [NSImage imageNamed:@"status-icon-off.png"];
}

@end
