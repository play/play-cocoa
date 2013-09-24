//
//  PLAController.h
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PLANowPlayingUpdated;
extern NSString *const PLAChannelTuned;

@class PLATrack;
@class PLAChannel;

@interface PLAController : NSObject{
  NSArray *queuedTracks;
  PLATrack *currentlyPlayingTrack;
  NSTimer *queuePoller;
  NSMutableArray *channels;
  PLAChannel *tunedChannel;
}

@property (nonatomic, retain) NSArray *queuedTracks;
@property (nonatomic, retain) PLATrack *currentlyPlayingTrack;
@property (nonatomic, retain) NSTimer *queuePoller;
@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, retain) PLAChannel *tunedChannel;

+ (PLAController *)sharedController;

- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (void)setPlayUrl:(NSString *)url;
- (NSString *)playUrl;
- (NSString *)streamUrl;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)updateNowPlaying;
- (void)startPolling;
- (void)stopPolling;
- (void)updateChannelsWithCompletionBlock:(void(^)())completionBlock;
- (void)tuneChannel:(PLAChannel *)channel;
- (BOOL)tuned;

@end
