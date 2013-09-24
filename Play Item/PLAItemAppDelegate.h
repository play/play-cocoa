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
@class PLAQueueWindowController;
@class PLAChannelsWindowController;

extern NSString *const PLAItemStartedPlayingNotificationName;
extern NSString *const PLAItemStoppedPlayingNotificationName;
extern NSString *const PLAItemLoggedInNotificationName;

@interface PLAItemAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) NSStatusItem *statusItem;
@property (strong) PLAItemLogInWindowController *logInWindowController;
@property (nonatomic, readonly) PLAQueueWindowController *queueWindowController;
@property (nonatomic, readonly) PLAChannelsWindowController *channelsWindowController;

- (void)didLogIn;
- (void)flipWindowToLogin;
- (void)flipWindowToQueue;
- (void)flipWindowToChannels;
- (IBAction)goToPlay:(id)sender;
- (void)togglePlayState;
- (void)createStreamer;
- (void)destroyStreamer;

@end
