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

@interface PLAController : NSObject{
  NSArray *queuedTracks;
  PLATrack *currentlyPlayingTrack;
}

@property (nonatomic, retain) NSArray *queuedTracks;
@property (nonatomic, retain) PLATrack *currentlyPlayingTrack;

+ (PLAController *)sharedController;

- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (void)setPlayUrl:(NSString *)url;
- (NSString *)playUrl;
- (NSString *)streamUrl;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;

@end
