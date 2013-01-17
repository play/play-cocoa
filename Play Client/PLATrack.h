//
//  PLTrack.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLATrack : NSObject <NSCopying>

@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, assign) BOOL queued;
@property (weak, nonatomic, readonly) NSURL *albumArtURL;
@property (weak, nonatomic, readonly) NSURL *downloadURL;
@property (weak, nonatomic, readonly) NSURL *albumDownloadURL;

#if !TARGET_OS_IPHONE
@property (nonatomic, readonly, strong) NSImage *albumArtwork; //starts off as nil, then gets downloaded in the background and set. KVO compliant.
#endif

+ (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *err))block;
+ (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *err))block;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)toggleStarredWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
- (void)starWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
- (void)unstarWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
@end
