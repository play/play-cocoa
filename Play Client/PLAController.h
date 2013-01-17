//
//  PLAController.h
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PLANowPlayingUpdated;

@class PLATrack;

@interface PLAController : NSObject {
  NSArray *queuedTracks;
  PLATrack *currentlyPlayingTrack;
  NSString *streamUrl;
}

@property (nonatomic, strong) NSArray *queuedTracks;
@property (nonatomic, strong) PLATrack *currentlyPlayingTrack;
@property (nonatomic, strong) NSString *streamUrl;

+ (PLAController *)sharedController;

- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (void)setPlayUrl:(NSString *)url;
- (NSString *)playUrl;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;

@end
