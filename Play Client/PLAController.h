//
//  PLAController.h
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusher.h"

extern NSString *const PLANowPlayingUpdated;

@class PLATrack;

@interface PLAController : NSObject <PTPusherDelegate>{
  NSArray *queuedTracks;
  PLATrack *currentlyPlayingTrack;
  PTPusher *pusherClient;
  NSString *pusherKey;
  NSString *streamUrl;
  PTPusherEventBinding *updateNowPlayingPusherChannelBinding;
}

@property (nonatomic, retain) NSArray *queuedTracks;
@property (nonatomic, retain) PLATrack *currentlyPlayingTrack;
@property (nonatomic, retain) PTPusher *pusherClient;
@property (nonatomic, retain) PTPusherEventBinding *updateNowPlayingPusherChannelBinding;
@property (nonatomic, retain) NSString *streamUrl;
@property (nonatomic, retain) NSString *pusherKey;

+ (PLAController *)sharedController;

- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (PTPusherChannel *)nowPlayingPusherChannel;
- (void)setUpPusher;
- (void)subscribeToChannels;
- (void)setPlayUrl:(NSString *)url;
- (NSString *)playUrl;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;
- (void)channelEventPushed:(PTPusherEvent *)channelEvent;

@end
