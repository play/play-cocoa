//
//  XFloatSecondsToHMSStringTransformer.m
//  Play Item
//
//  Created by Danny Greg on 17/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "XFloatSecondsToHMSStringTransformer.h"

@implementation XFloatSecondsToHMSStringTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value {
	if(value == nil ) return nil;
	NSString *hmsString = nil;
	float timeInterval = [value floatValue];
	int hours = (int)(timeInterval / 3600.0);
	int minutes = (int)(timeInterval / 60.0);
	int seconds = (int)timeInterval % 60;
	if (hours == 0) {
		hmsString =  [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
	} else {
		hmsString = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	}
	return hmsString;
}

- (id)reverseTransformedValue:(id)value {
	if(value == nil ) return nil;
	NSNumber *retVal;
	int hours = (int)[[value substringToIndex:2] intValue] * 3600;
	int minutes = (int)[[value substringWithRange:NSMakeRange(3,2)]	 intValue] * 60;
	int seconds = (int)[[value substringWithRange:NSMakeRange(6,2)] intValue];
	int frac = (int)[[value substringFromIndex:9] intValue];
	float fraction = (float)frac * 0.001;
	retVal = [NSNumber numberWithFloat:hours + minutes + seconds + fraction];
	return retVal;
}

@end
