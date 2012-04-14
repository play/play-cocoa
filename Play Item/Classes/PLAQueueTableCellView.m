//
//  PLAQueueTableCellView.m
//  Play Item
//
//  Created by Danny Greg on 14/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueTableCellView.h"

#import "PLAItemAppDelegate.h"
#import "PLAQueueWindowController.h"

@implementation PLAQueueTableCellView

- (IBAction)downloadTrack:(id)sender
{
	[[[NSApp delegate] queueWindowController] downloadTrack:self.objectValue];
}

- (IBAction)downloadAlbum:(id)sender
{
	
}

- (IBAction)toggleStar:(id)sender
{
	
}

@end
