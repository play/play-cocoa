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
#import "PLATrack.h"

NSString *PLAQueueTableCellViewObjectValueObservationContext = @"PLAQueueTableCellViewObjectValueObservationContext";

@implementation PLAQueueTableCellView

@synthesize starButton = _starButton;

- (IBAction)downloadTrack:(id)sender
{
	[[[NSApp delegate] queueWindowController] downloadTrack:self.objectValue];
}

- (IBAction)downloadAlbum:(id)sender
{
	[[[NSApp delegate] queueWindowController] downloadAlbumFromTrack:self.objectValue];
}

- (IBAction)toggleStar:(id)sender
{
	[self.objectValue toggleStarredWithCompletionBlock: ^ (BOOL success, NSError *err) {
		if (success)
			[self updateStarImage];
	}];		
}

#pragma mark -
#pragma mark Helpers

- (void)updateStarImage
{
	self.starButton.image = [NSImage imageNamed:([self.objectValue starred] ? @"starred-grey" : @"unstarred-grey")];
	self.starButton.alternateImage = [NSImage imageNamed:([self.objectValue starred] ? @"starred-grey-down" : @"unstarred-grey-down")];
}

#pragma mark -
#pragma mark Accessors

- (void)setObjectValue:(id)objectValue
{
	[super setObjectValue:objectValue];
	[self updateStarImage];
}

@end
