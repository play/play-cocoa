//
//  PLAQueueWindowController.h
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PLAShadowTextField;
@class PLATrack;

@interface PLAQueueWindowController : NSWindowController <NSTableViewDelegate>

@property (nonatomic, assign) IBOutlet NSButton *playButton; 
@property (nonatomic, assign) IBOutlet NSButton *nowPlayingStarButton;

- (id)init;

- (IBAction)togglePlay:(id)sender;
- (IBAction)toggleNowPlayingStar:(id)sender;

- (void)downloadTrack:(PLATrack *)track;

@end
