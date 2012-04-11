//
//  PLAItemWindow.h
//  Play Item
//
//  Created by Jon Maddox on 4/11/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PLAItemWindow : NSWindow

- (void)shake;
- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame;

@end
