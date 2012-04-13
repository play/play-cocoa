//
//  PLAQueueWindowController.h
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PLAShadowTextField;

@interface PLAQueueWindowController : NSWindowController

@property (nonatomic, retain) IBOutlet NSButton *playButton; 

- (id)init;

- (IBAction)togglePlay:(id)sender;
- (IBAction)downloadCurrentSong:(id)sender;
- (IBAction)downloadCurrentSongAlbum:(id)sender;

@end
