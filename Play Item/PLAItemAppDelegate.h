//
//  PLAItemAppDelegate.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioStreamer.h"
#import "PLAItemLogInViewController.h"

@interface PLAItemAppDelegate : NSObject <NSApplicationDelegate>{
  NSStatusItem *statusItem;
  NSMenu *statusMenu;
  AudioStreamer *streamer;
  PLAItemLogInViewController *logInViewController;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSWindow *window;
@property (strong) PLAItemLogInViewController *logInViewController;


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
