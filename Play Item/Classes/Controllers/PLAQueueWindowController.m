//
//  PLAQueueWindowController.m
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueWindowController.h"

#import "PLATrack.h"

@interface PLAQueueWindowController ()

@property (retain) NSArray *queue;
@property (retain) PLATrack *currentTrack;

- (void)updateQueue;

@end

@implementation PLAQueueWindowController

@synthesize queue = _queue;
@synthesize currentTrack = _currentTrack;

- (id)init
{	
	self = [super initWithWindowNibName:@"PLAQueueWindow"];
	if (self == nil)
		return nil;
	
	_queue = [[NSMutableArray alloc] init];

	return self;
}

- (void)dealloc
{
	[_queue release], _queue = nil;
	[_currentTrack release], _currentTrack = nil;
	[super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	[self updateQueue];
}

- (void)updateQueue
{
	[PLATrack currentQueueWithBlock: ^ (NSArray *tracks, NSError *err) 
	{
		if (tracks == nil) {
			NSLog(@"Could not get current queue: %@", err);
			return;
		}
		
		self.queue = tracks;
	 }];
}

@end
