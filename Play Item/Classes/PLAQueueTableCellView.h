//
//  PLAQueueTableCellView.h
//  Play Item
//
//  Created by Danny Greg on 14/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PLAQueueTableCellView : NSTableCellView

@property (nonatomic, assign) IBOutlet NSButton *starButton;

- (IBAction)downloadTrack:(id)sender;
- (IBAction)downloadAlbum:(id)sender;
- (IBAction)toggleStar:(id)sender;

@end
