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

- (void)dealloc{
  [trackId release];
  [name release];
  [album release];
  [artist release];
  
  [super dealloc];
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

+ (void)currentTrackWithBlock:(void(^)(PLATrack *track))block{
  [[PLAPlayClient sharedClient] getPath:@"/now_playing" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    PLATrack *track = [[[PLATrack alloc] initWithAttributes:responseObject] autorelease];
    block(track);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", error);
    block(nil);
  }];  
}

- (NSString *)albumArtUrl{
  return [NSString stringWithFormat:@"%@/images/art/%@.png", [[PLAController sharedController] playUrl], trackId];
}


@end
