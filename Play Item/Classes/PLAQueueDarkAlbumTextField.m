//
//  PLAQueueDarkAlbumTextField.m
//  Play Item
//
//  Created by Danny Greg on 13/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueDarkAlbumTextField.h"

@implementation PLAQueueDarkAlbumTextField

- (void)setup
{
	self.shadow = [[[NSShadow alloc] init] autorelease];
	self.shadow.shadowOffset = NSMakeSize(1.0, -1.0);
	self.shadow.shadowColor = [NSColor colorWithCalibratedRed:(195.0/255.0) green:(33.0/255.0) blue:(205.0/255.0) alpha:0.56];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
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

@end
