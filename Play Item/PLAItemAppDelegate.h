//
//  PLAItemAppDelegate.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AudioStreamer;
@class PLAItemLogInWindowController;

@interface PLAItemAppDelegate : NSObject <NSApplicationDelegate>{
  NSStatusItem *statusItem;
  NSMenu *statusMenu;
  AudioStreamer *streamer;
  PLAItemLogInWindowController *logInWindowController;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSWindow *window;
@property (strong) PLAItemLogInWindowController *logInWindowController;

- (void)didLogIn;
- (NSMenuItem *)playStatusItem;
- (NSMenuItem *)playActionItem;
- (void)updateWithTrackInformation;
- (void)setPlayStatus:(NSString *)statusString;
- (void)setPlayActionTitle:(NSString *)actionTitle;
- (IBAction)presentLogIn:(id)sender;
- (IBAction)goToPlay:(id)sender;
- (void)togglePlayState;
- (void)createStreamer;
- (void)destroyStreamer;
- (void)playbackStateChanged:(NSNotification *)aNotification;

@end
