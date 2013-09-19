//
//  PLAChannel.m
//  Play Cocoa
//
//  Created by Jon Maddox on 9/19/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "PLAChannel.h"
#import "PLAPlayClient.h"
#import "PLAController.h"

@implementation PLAChannel

+ (void)channelsWithBlock:(void(^)(NSArray *channels, NSError *error))block{
	[[PLAPlayClient sharedClient] getPath:@"/api/channels" parameters:nil
                                success: ^ (AFHTTPRequestOperation *operation, id responseObject)
   {
     NSArray *channelDicts = [responseObject valueForKey:@"channels"];
     NSMutableArray *channelObjects = [NSMutableArray array];
     for (id channelDict in channelDicts) {
       PLAChannel *channel = [[[PLAChannel alloc] initWithAttributes:channelDict] autorelease];
       [channelObjects addObject:channel];
     }
     
     block(channelObjects, nil);
   }
                                failure: ^ (AFHTTPRequestOperation *operation, NSError *error)
   {
     block(nil, error);
   }];
}

- (void)dealloc{
	[self.slug release];
	[self.name release];
	[self.color release];
	[self.nowPlaying release];

	[super dealloc];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.slug = [[attributes valueForKeyPath:@"slug"] stringValue];
  self.name = [attributes valueForKeyPath:@"name"];
  self.color = [attributes valueForKeyPath:@"color"];
  
  if ([attributes valueForKeyPath:@"now_playing"]) {
    self.nowPlaying = [[[PLATrack alloc] initWithAttributes:[attributes valueForKeyPath:@"now_playing"]] autorelease];
  }
  
  return self;
}

- (NSString *)streamUrl{
  return [NSString stringWithFormat:@"%@/api/channels/%@/stream?token=%@", [[PLAController sharedController] playUrl], self.slug, [[PLAController sharedController] authToken]];
}


- (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *error))block{
	[[PLAPlayClient sharedClient] getPath:[NSString stringWithFormat:@"/api/channels/%@/queue", self.slug] parameters:nil
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

- (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *error))block{
	[[PLAPlayClient sharedClient] getPath:[NSString stringWithFormat:@"/api/channels/%@/now_playing", self.slug] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		PLATrack *track = [[[PLATrack alloc] initWithAttributes:[responseObject objectForKey:@"now_playing"]] autorelease];
		block(track, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		block(nil, error);
	}];
}

- (id)copyWithZone:(NSZone *)zone{
	PLAChannel *copy = [[PLAChannel alloc] init];
	copy.slug = self.slug;
	copy.name = self.name;
	copy.color = self.color;
	copy.nowPlaying = self.nowPlaying;

	return copy;
}

- (BOOL)isEqual:(PLAChannel *)other{
  return [self.slug isEqualToString:other.slug];
}


@end
