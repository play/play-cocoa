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
    NSImage *recordImage = [NSImage imageNamed:@"record"];
	[recordImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect recordBounds = NSMakeRect(2.0, 1.0, NSWidth(self.bounds) - 3.0, NSHeight(self.bounds) - 3.0); //The bounds of the actual record are not those of the imageview…
	
	NSRect (^centralRectOfDiamater)(CGFloat) = ^ (CGFloat diamater)
	{
		return NSMakeRect(floor(NSMidX(recordBounds) - (diamater / 2.0)), floor(NSMidY(recordBounds) - (diamater / 2.0)), diamater, diamater);
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
