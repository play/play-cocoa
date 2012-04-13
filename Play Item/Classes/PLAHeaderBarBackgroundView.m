//
//  PLAHeaderBarBackgroundView.m
//  Play Item
//
//  Created by Danny Greg on 13/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAHeaderBarBackgroundView.h"

@implementation PLAHeaderBarBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
    static NSGradient *backingGradient = nil;
	if (backingGradient == nil) {
		NSColor *startColor = [NSColor colorWithCalibratedWhite:(184.0/255.0) alpha:1.0];
		NSColor *endColor = [NSColor colorWithCalibratedWhite:(214.0/255.0) alpha:1.0];
		backingGradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	}
	
	[backingGradient drawInRect:self.bounds angle:90.0];
}

@end
