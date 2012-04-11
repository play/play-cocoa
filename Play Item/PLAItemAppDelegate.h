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


- (NSMenuItem *)playStatusItem;
- (NSMenuItem *)playActionItem;
- (void)setPlayStatus:(NSString *)statusString;
- (void)setPlayActionTitle:(NSString *)actionTitle;
- (void)createStreamer;
- (void)destroyStreamer;
- (void)togglePlayState;
- (void)didLogIn;
- (IBAction)goToPlay;
- (IBAction)presentLogIn;

@end
