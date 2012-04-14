//
//  PLARecordImageView.m
//  Play Item
//
//  Created by Danny Greg on 14/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLARecordImageView.h"

static CGFloat PLARecordImageViewStickerDiamater = 30.0;
static CGFloat PLARecordImageViewSpindleDiamater = 3.0;

@implementation PLARecordImageView

- (void)drawRect:(NSRect)dirtyRect
{
#warning This image isn't 100% extracted properly. I need to ask for @caged's help on that one.
    NSImage *recordImage = [NSImage imageNamed:@"record"];
	[recordImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect (^centralRectOfDiamater)(CGFloat) = ^ (CGFloat diamater)
	{
		return NSMakeRect(floor(NSMidX(self.bounds) - (diamater / 2.0)), floor(NSMidY(self.bounds) - (diamater / 2.0)), diamater, diamater);
	};
	
	NSRect middleStickerRect = centralRectOfDiamater(PLARecordImageViewStickerDiamater);
	NSBezierPath *circleClip = [NSBezierPath bezierPathWithOvalInRect:middleStickerRect];
	[circleClip setClip];
	[self.image drawInRect:middleStickerRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect spindleRect = centralRectOfDiamater(PLARecordImageViewSpindleDiamater);
	NSBezierPath *spindle = [NSBezierPath bezierPathWithOvalInRect:spindleRect];
	[[NSColor blackColor] set];
	[spindle fill];
}

@end
