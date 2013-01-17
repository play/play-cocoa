//
//  PLAItemWindow.m
//  Play Item
//
//  Created by Jon Maddox on 4/11/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAItemWindow.h"

@implementation PLAItemWindow

- (BOOL)canBecomeKeyWindow{
  return YES;
}

- (void)shake{
  [self setAnimations:@{@"frameOrigin": [self shakeAnimation:[self frame]]}];
  [[self animator] setFrameOrigin:[self frame].origin];  
}

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame{
  CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
  
  CGMutablePathRef shakePath = CGPathCreateMutable();
  CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
  
  int numberOfShakes = 3;
  float durationOfShake = 0.5f;
  float vigourOfShake = 0.05f;
  
  
  int index;
  for (index = 0; index < numberOfShakes; ++index){
    CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
    CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
  }
  CGPathCloseSubpath(shakePath);
  shakeAnimation.path = shakePath;
  shakeAnimation.duration = durationOfShake;
  return shakeAnimation;
}

@end
