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

@interface PLAController : NSObject

@property (nonatomic, strong) NSArray *queuedTracks;
@property (nonatomic, strong) PLATrack *currentlyPlayingTrack;
@property (nonatomic, strong) NSString *streamUrl;
@property (nonatomic, copy) NSURL *playURL;

+ (PLAController *)sharedController;

- (void)logInWithBlock:(void(^)(BOOL succeeded))block;
- (void)setAuthToken:(NSString *)token;
- (NSString *)authToken;
- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict;

@end
