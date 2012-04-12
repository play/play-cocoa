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

@interface PLAItemAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) NSStatusItem *statusItem;
@property (strong) PLAItemLogInWindowController *logInWindowController;

- (void)didLogIn;
- (IBAction)presentLogIn:(id)sender;
- (IBAction)goToPlay:(id)sender;
- (void)togglePlayState;
- (void)createStreamer;
- (void)destroyStreamer;

@end
