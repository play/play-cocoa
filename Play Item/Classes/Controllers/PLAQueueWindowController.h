//
//  PLAQueueWindowController.h
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PLAItemAppDelegate;
@class PLAShadowTextField;
@class PLATrack;

@interface PLAQueueWindowController : NSWindowController <NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSButton *playButton; 
@property (nonatomic, weak) IBOutlet NSButton *nowPlayingStarButton;

//used for bindings
@property (nonatomic, readonly) double streamProgress;
@property (nonatomic, readonly) double streamDuration;

- (id)init;

- (IBAction)togglePlay:(id)sender;
- (IBAction)toggleNowPlayingStar:(id)sender;
- (IBAction)showPrefs:(id)sender;

- (void)downloadTrack:(PLATrack *)track;
- (void)downloadAlbumFromTrack:(PLATrack *)track;

@end
