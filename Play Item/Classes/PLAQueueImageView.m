//
//  PLAQueueImageView.m
//  Play Item
//
//  Created by Danny Greg on 13/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAQueueImageView.h"

CGFloat const PLAQueueImageViewCornerRadius = 3.0;
CGFloat const PLAQueueImageViewImageInset = 3.0;

@implementation PLAQueueImageView

- (void)drawRect:(NSRect)dirtyRect
{
	[NSGraphicsContext saveGraphicsState];
    
	NSRect drawingBounds = NSMakeRect(NSMinX(self.bounds), floor(NSMinY(self.bounds) + 1.0), NSWidth(self.bounds), floor(NSHeight(self.bounds) - 1.0));
	NSBezierPath *outerClip = [NSBezierPath bezierPathWithRoundedRect:drawingBounds xRadius:PLAQueueImageViewCornerRadius yRadius:PLAQueueImageViewCornerRadius];
	static NSGradient *backingGrad = nil;
	if (backingGrad == nil) {
		NSColor *startColor = [NSColor colorWithCalibratedWhite:(23.0/255.0) alpha:1.0];
		NSColor *endColor = [NSColor colorWithCalibratedWhite:(36.0/255.0) alpha:1.0];
		backingGrad = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	}
	[backingGrad drawInBezierPath:outerClip angle:90.0];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
