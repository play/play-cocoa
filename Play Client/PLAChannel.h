//
//  PLAChannel.h
//  Play Cocoa
//
//  Created by Jon Maddox on 9/19/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "PLATrack.h"

@interface PLAChannel : NSObject <NSCopying>

@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PLATrack *nowPlaying;
@property (nonatomic, retain) NSString *color;

+ (void)channelsWithBlock:(void(^)(NSArray *channels, NSError *error))block;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *err))block;
- (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *err))block;
- (NSString *)streamUrl;

@end
