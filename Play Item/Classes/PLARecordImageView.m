//
//  PLARecordImageView.m
//  Play Item
//
//  Created by Danny Greg on 14/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLARecordImageView.h"



@implementation PLARecordImageView

- (void)drawRect:(NSRect)dirtyRect
{
#warning This image isn't 100% extracted properly. I need to ask for @caged's help on that one.
    NSImage *recordImage = [NSImage imageNamed:@"record"];
	[recordImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	
}

@end
