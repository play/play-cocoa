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
CGFloat const PLAQueueImageViewHighlightCurveStartXOffset = 5.0;
CGFloat const PLAQueueImageViewHighlightCurveEndYOffset = 5.0;

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
	
	NSRect imageRect = NSInsetRect(drawingBounds, PLAQueueImageViewImageInset, PLAQueueImageViewImageInset);
	[self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSBezierPath *highlightPath = [NSBezierPath bezierPath];
	[highlightPath moveToPoint:NSMakePoint(floor(NSMinX(imageRect) + PLAQueueImageViewHighlightCurveStartXOffset), NSMinY(imageRect))];
	NSPoint controlPoint = NSMakePoint(NSMidX(imageRect), NSMidY(imageRect));
	[highlightPath curveToPoint:NSMakePoint(NSMaxX(imageRect), floor(NSMaxY(imageRect) - PLAQueueImageViewHighlightCurveEndYOffset)) controlPoint1:controlPoint controlPoint2:controlPoint];
	
	[highlightPath lineToPoint:NSMakePoint(NSMaxX(imageRect), NSMaxY(imageRect))];
	[highlightPath lineToPoint:NSMakePoint(NSMinX(imageRect), NSMaxY(imageRect))];
	[highlightPath lineToPoint:NSMakePoint(NSMinX(imageRect), NSMinY(imageRect))];
	[highlightPath closePath];
	
	static NSGradient *highlightGrad = nil;
	if (highlightGrad == nil) {
		NSColor *startColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.2];
		NSColor *endColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.0];
		highlightGrad = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	}
	
	[highlightGrad drawInBezierPath:highlightPath angle:270.0];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
