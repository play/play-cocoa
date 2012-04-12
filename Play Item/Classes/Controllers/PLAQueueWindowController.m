//
//  PLAQueueWindowController.m
//  Play Item
//
//  Created by Danny Greg on 11/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueWindowController.h"

@interface PLAQueueWindowController ()

@property (readonly) NSMutableArray *queue;

@end

@implementation PLAQueueWindowController

@synthesize queue = _queue;

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
	[super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
