//
//  PLAController.h
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLATrack.h"
#import "PTPusher.h"

@interface PLAController : NSObject <PTPusherDelegate>{
  NSArray *queuedTracks;
  PLATrack *currentlyPlayingTrack;
  PTPusher *pusherClient;
  NSString *streamUrl;
  NSString *pusherKey;
}

@property (nonatomic, retain) NSArray *queuedTracks;
@property (nonatomic, retain) PLATrack *currentlyPlayingTrack;
@property (nonatomic, retain) PTPusher *pusherClient;
@property (nonatomic, retain) NSString *streamUrl;
@property (nonatomic, retain) NSString *pusherKey;

+ (PLAController *)sharedController;

- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;

- (void)setPlayUrl:(NSString *)url;
- (NSString *)playUrl;
- (void)setPusherKey:(NSString *)key;
- (NSString *)pusherKey;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;

@end
