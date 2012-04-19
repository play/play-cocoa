//
//  PLALoginHeaderBackgroundView.m
//  Play Item
//
//  Created by Danny Greg on 18/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLALoginHeaderBackgroundView.h"

@implementation PLALoginHeaderBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
	static NSGradient *backgroundGradient = nil;
	if (backgroundGradient == nil) {
		NSColor *topColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
		NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.961 alpha:1.0];
		backgroundGradient = [[NSGradient alloc] initWithStartingColor:bottomColor endingColor:topColor];
	}
	
	[backgroundGradient drawInRect:self.bounds angle:90.0];
	
	NSColor *highlightColour = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
	[highlightColour setStroke];
	NSPoint startPoint = NSMakePoint(0.0,0.0);
	NSPoint endPoint = NSMakePoint(NSWidth(self.bounds), startPoint.y);
	[NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
	
	
	NSColor *lowlightColour = [NSColor colorWithCalibratedWhite:0.675 alpha:1.000];
	[lowlightColour setStroke];
	startPoint = NSMakePoint(0.0, 0.5);
	endPoint = NSMakePoint(NSWidth(self.bounds), startPoint.y);
	[NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
}

@end
