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

@interface PLAItemAppDelegate ()

@property (nonatomic, retain) SPMediaKeyTap *keyTap;
@property (nonatomic, readonly) PLAQueueWindowController *queueWindowController;
@property (nonatomic, retain) AudioStreamer *streamer;

@end

@implementation PLAItemAppDelegate

@synthesize statusItem = _statusItem;
@synthesize logInWindowController = _logInWindowController;
@synthesize streamer = _streamer;

@synthesize keyTap = _keyTap;
@synthesize queueWindowController = _queueWindowController;

- (id)init
{	
	self = [super init];
	if (self == nil)
		return nil;
	
	_queueWindowController = [[PLAQueueWindowController alloc] init];

	return self;
}

- (void)dealloc{
  [self destroyStreamer];
  [_statusItem release];

	[_logInWindowController release];
  [_keyTap release], _keyTap = nil;
	[_queueWindowController release], _queueWindowController = nil;
  [super dealloc];
}

-(void)awakeFromNib{
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [_statusItem setAction:@selector(toggleWindow:)];
  [_statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
  [_statusItem setAlternateImage:[NSImage imageNamed:@"status-icon-inverted.png"]];
  [_statusItem setHighlightMode:YES];
  
  self.logInWindowController = [[[PLAItemLogInWindowController alloc] init] autorelease];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
  
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [self didLogIn];
      }else{
        [self presentLogIn:nil];
      }
    
    });
  }];
  
    self.keyTap = [[[SPMediaKeyTap alloc] initWithDelegate:self] autorelease];
    [self.keyTap startWatchingMediaKeys];
}

- (void)didLogIn{
  // set play button to play
  
  // listen for notifications for updated songs from the CFController and pusher
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithTrackInformation) name:PLANowPlayingUpdated object:nil];
  
  [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *err) {
    [[PLAController sharedController] setCurrentlyPlayingTrack:track];
  }];
}

#pragma mark - View State Methods

- (IBAction)presentLogIn:(id)sender{
	[self.logInWindowController showWindow:sender];
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

@end
