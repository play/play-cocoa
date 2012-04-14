//
//  PLARecordImageView.m
//  Play Item
//
//  Created by Danny Greg on 14/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLARecordImageView.h"

static CGFloat PLARecordImageViewStickerDiamater = 30.0;

@implementation PLARecordImageView

- (void)drawRect:(NSRect)dirtyRect
{
#warning This image isn't 100% extracted properly. I need to ask for @caged's help on that one.
    NSImage *recordImage = [NSImage imageNamed:@"record"];
	[recordImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect middleStickerRect = NSMakeRect(floor(NSMidX(self.bounds) - (PLARecordImageViewStickerDiamater / 2.0)), floor(NSMidY(self.bounds) - (PLARecordImageViewStickerDiamater / 2.0)), PLARecordImageViewStickerDiamater, PLARecordImageViewStickerDiamater);
	NSBezierPath *circleClip = [NSBezierPath bezierPathWithOvalInRect:middleStickerRect];
	[circleClip setClip];
	[self.image drawInRect:middleStickerRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
