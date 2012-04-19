//
//  PLAImageCache.m
//  Play Cocoa
//
//  Created by Danny Greg on 19/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAAlbumArtworkImageCache.h"

@implementation PLAAlbumArtworkImageCache

+ (id)sharedCache
{
	static PLAAlbumArtworkImageCache *sharedCache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedCache = [[PLAAlbumArtworkImageCache alloc] init];
	});
	
	return sharedCache;
}

- (void)imageForURL:(NSURL *)imageURL withCompletionBlock:(void(^)(NSImage *image, NSError *error))completionBlock
{
	
}

@end
