//
//  PLAImageCache.m
//  Play Cocoa
//
//  Created by Danny Greg on 19/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAAlbumArtworkImageCache.h"

#import "AFNetworking.h"

//***************************************************************************

CGFloat const PLAAlbumArtworkImageCacheImageSize = 47.0;

//***************************************************************************

@interface PLAAlbumArtworkImageCache ()

@property (nonatomic, readonly) NSOperationQueue *artworkDownloadQueue;

- (NSImage *)cachedImageForURL:(NSURL *)url;

@end

//***************************************************************************

@implementation PLAAlbumArtworkImageCache

@synthesize artworkDownloadQueue = _artworkDownloadQueue;

+ (id)sharedCache
{
	static PLAAlbumArtworkImageCache *sharedCache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedCache = [[PLAAlbumArtworkImageCache alloc] init];
	});
	
	return sharedCache;
}

- (id)init
{	
	self = [super init];
	if (self == nil)
		return nil;
	
	_artworkDownloadQueue = [[NSOperationQueue alloc] init];	

	return self;
}

- (void)dealloc
{
	[_artworkDownloadQueue release], _artworkDownloadQueue = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark API

- (void)imageForURL:(NSURL *)imageURL withCompletionBlock:(void(^)(NSImage *image, NSError *error))completionBlock
{
	NSImage *localImage = [self cachedImageForURL:imageURL];
	if (localImage != nil) {
		if (completionBlock != nil)
			completionBlock(localImage, nil);
		return;
	}
	
	void (^callCompletionBlockWithImageError)(NSImage *image, NSError *error) = ^ (NSImage *image, NSError *error) 
	{
		if (completionBlock == nil)
			return;
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			completionBlock(image, error);
		});
	};
	
	NSURLRequest *artworkRequest = [NSURLRequest requestWithURL:imageURL];
	AFHTTPRequestOperation *requestOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:artworkRequest] autorelease];
	[requestOperation setCompletionBlockWithSuccess: ^ (AFHTTPRequestOperation *operation, id responseObject) 
	{
		NSImage *image = [[NSImage alloc] initWithData:responseObject];
		if (image == nil) {
			callCompletionBlockWithImageError(nil, [NSError errorWithDomain:@"org.play.play-item" code:-1 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Could not create image from downloaded data.", nil) forKey:NSLocalizedDescriptionKey]]);
			return;
		}
		
		image.size = NSMakeSize(PLAAlbumArtworkImageCacheImageSize, PLAAlbumArtworkImageCacheImageSize);
		callCompletionBlockWithImageError(image, nil);
		
	} failure: ^ (AFHTTPRequestOperation *operation, NSError *error) 
	{
		callCompletionBlockWithImageError(nil, error);
	}];
	
	[self.artworkDownloadQueue addOperation:requestOperation];
}

@end
