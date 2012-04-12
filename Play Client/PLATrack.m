//
//  PLTrack.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLATrack.h"
#import "PLAPlayClient.h"
#import "PLAController.h"

@implementation PLATrack
@synthesize trackId, name, album, artist, queued, starred;

+ (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *error))block{
	[[PLAPlayClient sharedClient] getPath:@"/now_playing" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		PLATrack *track = [[[PLATrack alloc] initWithAttributes:responseObject] autorelease];
		block(track, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		block(nil, error);
	}];  
}

+ (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *error))block
{
	[[PLAPlayClient sharedClient] getPath:@"/queue" parameters:nil 
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
  
  self.trackId = [attributes valueForKeyPath:@"id"];
  self.name = [attributes valueForKeyPath:@"name"];
  self.album = [attributes valueForKeyPath:@"album"];
  self.artist = [attributes valueForKeyPath:@"artist"];
  queued = [[attributes valueForKeyPath:@"queued"] boolValue];
  starred = [[attributes valueForKeyPath:@"starred"] boolValue];
  
  return self;
}

- (void)dealloc{
	[trackId release];
	[name release];
	[album release];
	[artist release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (NSURL *)albumArtURL
{
	NSString *urlString = [NSString stringWithFormat:@"%@/images/art/%@.png", [[PLAController sharedController] playUrl], trackId];
	return [NSURL URLWithString:urlString];
}

@end
