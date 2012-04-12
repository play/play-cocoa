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
#import "PLATrack.h"
#import "SPMediaKeyTap.h"

@interface PLAItemAppDelegate ()

@property (nonatomic, retain) SPMediaKeyTap *keyTap;

@end

@implementation PLAItemAppDelegate

@synthesize statusItem;
@synthesize statusMenu;
@synthesize logInWindowController;

@synthesize keyTap = _keyTap;

- (void)dealloc{
  [self destroyStreamer];
  [statusItem release];
  [statusMenu release];
  [logInWindowController release];
  [_keyTap release], _keyTap = nil;
  [super dealloc];
}

-(void)awakeFromNib{
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setAction:@selector(toggleWindow:)];
  [statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
  [statusItem setAlternateImage:[NSImage imageNamed:@"status-icon-inverted.png"]];
  [statusItem setHighlightMode:YES];
  
  [self setPlayActionTitle:@"Log In to Play"];
  [[self playActionItem] setTarget:self];
  [[self playActionItem] setAction:@selector(presentLogIn)];
  [[self playActionItem] setEnabled:YES];

  [[statusMenu itemAtIndex:1] setTarget:self];
  [[statusMenu itemAtIndex:1] setEnabled:NO];
  
  self.logInWindowController = [[[PLAItemLogInWindowController alloc] init] autorelease];
  [self setPlayStatus:@""];
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
  
    [PLATrack currentQueueWithBlock:^(NSArray *tracks, NSError *err) {
		NSLog(@"%@", err);
	}];
    self.keyTap = [[[SPMediaKeyTap alloc] initWithDelegate:self] autorelease];
    [self.keyTap startWatchingMediaKeys];

}

- (void)didLogIn{
  // set play button to play
  [self setPlayActionTitle:@"Play"];
  [[self playActionItem] setTarget:self];
  [[self playActionItem] setAction:@selector(togglePlayState)];
  [[statusMenu itemAtIndex:1] setAction:@selector(goToPlay)];
  
  
  // listen for notifications for updated songs from the CFController and pusher
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithTrackInformation) name:@"PLANowPlayingUpdated" object:nil];
  
  [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *err) {
    [[PLAController sharedController] setCurrentlyPlayingTrack:track];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self updateWithTrackInformation];
    });
    
  }];
}

#pragma mark - Status Item Getters

- (NSMenuItem *)playStatusItem{
  return [statusMenu itemAtIndex:4];
}

- (NSMenuItem *)playActionItem{
  return [statusMenu itemAtIndex:0];
}

#pragma mark - View State Methods

- (void)updateWithTrackInformation{
  PLATrack *currentlyPlayingTrack = [[PLAController sharedController] currentlyPlayingTrack];
  
  NSString *playStatusString = [NSString stringWithFormat:@"%@ - %@ - %@", [currentlyPlayingTrack artist], [currentlyPlayingTrack album], [currentlyPlayingTrack name]];
  
  [self setPlayStatus:playStatusString];
}

- (void)setPlayStatus:(NSString *)statusString{
  if (statusString && statusString.length > 0) {
    [[self playStatusItem] setHidden:NO];
    [[statusMenu itemAtIndex:3] setHidden:NO];
    [[self playStatusItem] setTitle:statusString];
  }else{
    [[self playStatusItem] setHidden:YES];
    [[statusMenu itemAtIndex:3] setHidden:YES];
  }
}

- (void)setPlayActionTitle:(NSString *)actionTitle{
  [[self playActionItem] setTitle:actionTitle];
}

- (IBAction)presentLogIn:(id)sender{
	[self.logInWindowController showWindow:sender];
}

- (IBAction)goToPlay:(id)sender{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[PLAController sharedController] playUrl]]];
}


#pragma mark - Play Methods

- (void)togglePlayState{
  if (streamer && [streamer isPlaying]) {
		[self destroyStreamer];
    [self setPlayActionTitle:@"Play"];
    [statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
  }else{
    [self setPlayStatus:@"Buffering..."];
    [self createStreamer];
    [streamer start];
  }
}

- (void)createStreamer{
	if (streamer){
		return;
	}
  
  NSString *streamUrl = [[PLAController sharedController] streamUrl];
  
  NSLog(@"opening stream at: %@", streamUrl);
  
	[self destroyStreamer];
  
	streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:streamUrl]];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
}

- (void)destroyStreamer{
	if (streamer){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}


#pragma mark - Audio player callbacks

- (void)playbackStateChanged:(NSNotification *)aNotification{
	if ([streamer isWaiting]){
    [self setPlayActionTitle:@"Play"];
    [statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
	}else if ([streamer isPlaying]){
    [self setPlayActionTitle:@"Stop"];
    [statusItem setImage:[NSImage imageNamed:@"status-icon-on.png"]];
    [self updateWithTrackInformation];
	}else if ([streamer isPaused]){
    [self setPlayActionTitle:@"Play"];
    [self setPlayStatus:@""];
    [statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
	}else if ([streamer isIdle]){
    [self setPlayActionTitle:@"Play"];
    [self setPlayStatus:@""];
    [statusItem setImage:[NSImage imageNamed:@"status-icon-off.png"]];
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
    
    [self toggelPlayState];
}

@end
