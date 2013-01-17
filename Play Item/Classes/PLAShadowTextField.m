//
//  PLAShadowTextField.m
//  Play Item
//
//  Created by Danny Greg on 13/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAShadowTextField.h"

@implementation PLAShadowTextField

@synthesize shadow = _shadow;

- (void)drawRect:(NSRect)dirtyRect
{
	if (self.shadow == nil) {
		[super drawRect:dirtyRect];
		return;
	}
	
	NSMutableDictionary *attributes = [[self.attributedStringValue attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
	attributes[NSShadowAttributeName] = self.shadow;
	
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
	[attrString drawInRect:dirtyRect];
}

@end
