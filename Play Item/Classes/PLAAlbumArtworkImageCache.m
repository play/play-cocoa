//
//  PLAImageCache.m
//  Play Cocoa
//
//  Created by Danny Greg on 19/04/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAAlbumArtworkImageCache.h"

#import "PLATrack.h"

#import "AFNetworking.h"

//***************************************************************************

CGFloat const PLAAlbumArtworkImageCacheImageSize = 47.0;

//***************************************************************************

@interface PLAAlbumArtworkImageCache ()

@property (nonatomic, readonly) NSOperationQueue *artworkDownloadQueue;

- (NSURL *)localImageLocationForTrack:(PLATrack *)track;
- (NSImage *)cachedImageForTrack:(PLATrack *)track;

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
	_artworkDownloadQueue = nil;
}

#pragma mark -
#pragma mark API

- (void)imageForTrack:(PLATrack *)track withCompletionBlock:(void(^)(NSImage *image, NSError *error))completionBlock
{
	NSImage *localImage = [self cachedImageForTrack:track];
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
	
	NSURL *imageURL = track.albumArtURL;
	NSURLRequest *artworkRequest = [NSURLRequest requestWithURL:imageURL];
	AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:artworkRequest];
	[requestOperation setCompletionBlockWithSuccess: ^ (AFHTTPRequestOperation *operation, id responseObject) 
	{
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:responseObject];
		if (imageRep == nil) {
			callCompletionBlockWithImageError(nil, [NSError errorWithDomain:@"org.play.play-item" code:-1 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Could not create image from downloaded data.", nil) forKey:NSLocalizedDescriptionKey]]);
			return;
		}
		
		imageRep.size = NSMakeSize(PLAAlbumArtworkImageCacheImageSize, PLAAlbumArtworkImageCacheImageSize);
		NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
		NSError *err = nil;
		NSURL *localURL = [self localImageLocationForTrack:track];
		if (![imageData writeToURL:localURL options:NSDataWritingAtomic error:&err])
			NSLog(@"Could not write to local caches dir at URL %@ for this reason: %@", localURL, [err localizedDescription]);
		
		NSImage *returnImage = [[NSImage alloc] initWithSize:imageRep.size];
		[returnImage addRepresentation:imageRep];
		callCompletionBlockWithImageError(returnImage, nil);
		
	} failure: ^ (AFHTTPRequestOperation *operation, NSError *error) 
	{
		callCompletionBlockWithImageError(nil, error);
	}];
	
	[self.artworkDownloadQueue addOperation:requestOperation];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)localImageLocationForTrack:(PLATrack *)track
{
	NSString *(^normalizeString)(NSString *) = ^ (NSString *string) 
	{
		return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	};
	
	NSString *artist = normalizeString(track.artist);
	NSString *album = normalizeString(track.album);
	
	NSString *fileName = [NSString stringWithFormat:@"%@-%@.png", artist, album];
	
	NSString *cachesFolderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	cachesFolderPath = [[cachesFolderPath stringByAppendingPathComponent:@"org.play.play-item"] stringByAppendingPathComponent:@"Artwork"];
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSFileManager *manager = [[NSFileManager alloc] init]; //file manager is not thread safe, so let's create our own
		if (![manager fileExistsAtPath:cachesFolderPath])
			[manager createDirectoryAtPath:cachesFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	});
	
	NSURL *returnLocation = [[NSURL fileURLWithPath:cachesFolderPath] URLByAppendingPathComponent:fileName];
	
	return returnLocation;
}

- (NSImage *)cachedImageForTrack:(PLATrack *)track
{
	return [[NSImage alloc] initWithContentsOfURL:[self localImageLocationForTrack:track]]; //This does the smart thing and returns nil if no image exists at that path
}

@end
