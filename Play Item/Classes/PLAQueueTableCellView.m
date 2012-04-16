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

- (void)setup
{
	[self addObserver:self forKeyPath:@"objectValue" options:0 context:&PLAQueueTableCellViewObjectValueObservationContext];
}

- (id)initWithFrame:(NSRect)frameRect
{	
	self = [super initWithFrame:frameRect];
	if (self == nil)
		return nil;
	
	[self setup];

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{	
	self = [super initWithCoder:aDecoder];
	if (self == nil)
		return nil;
	
	[self setup];

	return self;
}

- (IBAction)downloadTrack:(id)sender
{
	[[[NSApp delegate] queueWindowController] downloadTrack:self.objectValue];
}

- (IBAction)downloadAlbum:(id)sender
{
	
}

- (IBAction)toggleStar:(id)sender
{
	[self.objectValue toggleStarredWithCompletionBlock:nil];		
}

#pragma mark -
#pragma mark Helpers

- (void)updateStarImage
{
	self.starButton.image = [NSImage imageNamed:([self.objectValue starred] ? @"starred-grey" : @"unstarred-grey")];
	self.starButton.alternateImage = [NSImage imageNamed:([self.objectValue starred] ? @"starred-grey-down" : @"unstarred-grey-down")];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &PLAQueueTableCellViewObjectValueObservationContext) {
        [self updateStarImage];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
