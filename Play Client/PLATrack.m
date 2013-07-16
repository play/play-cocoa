//
//  PLTrack.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLATrack.h"

#if !TARGET_OS_IPHONE
#import "PLAAlbumArtworkImageCache.h"
#endif

#import "PLAController.h"
#import "PLAPlayClient.h"

#import "AFNetworking.h"

#if !TARGET_OS_IPHONE
@interface PLATrack ()

@property (nonatomic, retain) NSImage *albumArtwork;

@end
#endif

@implementation PLATrack
@synthesize slug, name, album, albumSlug, artist, artistSlug, albumArtPath, queued, starred;

#if !TARGET_OS_IPHONE
@synthesize albumArtwork = _albumArtwork;
#endif

+ (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *error))block{
	[[PLAPlayClient sharedClient] getPath:@"/api/now_playing" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		PLATrack *track = [[[PLATrack alloc] initWithAttributes:[responseObject objectForKey:@"now_playing"]] autorelease];
		block(track, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		block(nil, error);
	}];  
}

+ (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *error))block
{
	[[PLAPlayClient sharedClient] getPath:@"/api/queue" parameters:nil 
	success: ^ (AFHTTPRequestOperation *operation, id responseObject) 
	{
		NSArray *songDicts = [responseObject valueForKey:@"songs"];
		NSMutableArray *trackObjects = [NSMutableArray array];
		for (id song in songDicts) {
			PLATrack *track = [[[PLATrack alloc] initWithAttributes:song] autorelease];
			[trackObjects addObject:track];
		}
		
		block(trackObjects, nil);
	} 
	failure: ^ (AFHTTPRequestOperation *operation, NSError *error) 
	{
		block(nil, error);
	}];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  NSLog(@"attributes: %@", attributes);
  
  self.slug = [attributes valueForKeyPath:@"slug"];
  self.name = [attributes valueForKeyPath:@"title"];
  self.album = [attributes valueForKeyPath:@"album_name"];
  self.albumSlug = [attributes valueForKeyPath:@"album_slug"];
  self.artist = [attributes valueForKeyPath:@"artist_name"];
  self.artistSlug = [attributes valueForKeyPath:@"artist_slug"];
  self.albumArtPath = [attributes valueForKeyPath:@"album_art_path"];
  queued = [[attributes valueForKeyPath:@"queued"] boolValue];
  starred = [[attributes valueForKeyPath:@"starred"] boolValue];
	
#if !TARGET_OS_IPHONE
	[[PLAAlbumArtworkImageCache sharedCache] imageForTrack:self withCompletionBlock: ^ (NSImage *image, NSError *error) 
	{
		self.albumArtwork = image;
	}];
#endif
  
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	PLATrack *copy = [[PLATrack alloc] init];
	copy.slug = self.slug;
	copy.name = self.name;
	copy.album = self.album;
	copy.albumSlug = self.albumSlug;
	copy.artist = self.artist;
	copy.artistSlug = self.artistSlug;
	copy.albumArtPath = self.albumArtPath;
	copy.queued = self.queued;
	copy.starred = self.starred;
	
#if !TARGET_OS_IPHONE
	copy.albumArtwork = self.albumArtwork;
#endif
	return copy;
}

- (void)dealloc{
	[slug release];
	[name release];
	[album release];
	[albumSlug release];
	[artist release];
	[artistSlug release];
	[albumArtPath release];
	
#if !TARGET_OS_IPHONE
	[_albumArtwork release], _albumArtwork = nil;
#endif
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (NSURL *)albumArtURL
{
	NSString *urlString = [NSString stringWithFormat:@"%@%@", [[PLAController sharedController] playUrl], self.albumArtPath];
	return [NSURL URLWithString:urlString];
}

- (NSURL *)downloadURL
{
	NSString *urlString = [NSString stringWithFormat:@"%@/api/artists/%@/songs/%@/download", [[PLAController sharedController] playUrl], [self.artistSlug stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.albumSlug stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return [NSURL URLWithString:urlString];
}

- (NSURL *)albumDownloadURL
{
	NSString *urlString = [NSString stringWithFormat:@"%@/api/artist/%@/album/%@/download", [[PLAController sharedController] playUrl], [self.artistSlug stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.albumSlug stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	return [NSURL URLWithString:urlString];
}

#pragma mark -
#pragma mark Operations

- (void)toggleStarredWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock
{
  if (self.starred) {
    [self unstarWithCompletionBlock:^(BOOL success, NSError *err) {
      if (completionBlock != nil)
        completionBlock(success, err);
    }];
  }else{
    [self starWithCompletionBlock:^(BOOL success, NSError *err) {
      if (completionBlock != nil)
        completionBlock(success, err);
    }];
  }
}

- (void)starWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock
{
  NSLog(@"starring");
  [[PLAPlayClient sharedClient] postPath:@"/star" parameters:[NSDictionary dictionaryWithObject:self.slug forKey:@"id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    self.starred = YES;
		if (completionBlock != nil)
			completionBlock(YES, nil);

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (completionBlock != nil)
			completionBlock(NO, error);
  }];
}

- (void)unstarWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock
{
  [[PLAPlayClient sharedClient] deletePath:@"/star" parameters:[NSDictionary dictionaryWithObject:self.slug forKey:@"id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    self.starred = NO;
		if (completionBlock != nil)
			completionBlock(YES, nil);
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (completionBlock != nil)
			completionBlock(NO, error);
  }];
}

@end
