//
//  PLAQueueWhiteTextField.m
//  Play Item
//
//  Created by Danny Greg on 13/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueWhiteTextField.h"

@implementation PLAQueueWhiteTextField

- (void)setup
{
	self.shadow = [[NSShadow alloc] init];
	self.shadow.shadowOffset = NSMakeSize(1.0, -1.0);
	self.shadow.shadowColor = [NSColor colorWithCalibratedRed:(152.0/255.0) green:(24.0/255.0) blue:(160.0/255.0) alpha:0.56];
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
