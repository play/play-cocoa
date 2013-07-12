//
//  PLTrack.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLATrack : NSObject <NSCopying> {
  NSString *slug;
  NSString *name;
  NSString *album;
  NSString *albumSlug;
  NSString *artist;
  NSString *artistSlug;
  NSString *albumArtPath;
  BOOL starred;
  BOOL queued;
}

@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *albumSlug;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *artistSlug;
@property (nonatomic, retain) NSString *albumArtPath;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, assign) BOOL queued;
@property (nonatomic, readonly) NSURL *albumArtURL;
@property (nonatomic, readonly) NSURL *downloadURL;
@property (nonatomic, readonly) NSURL *albumDownloadURL;

#if !TARGET_OS_IPHONE
@property (nonatomic, readonly, retain) NSImage *albumArtwork; //starts off as nil, then gets downloaded in the background and set. KVO compliant.
#endif

+ (void)currentTrackWithBlock:(void(^)(PLATrack *track, NSError *err))block;
+ (void)currentQueueWithBlock:(void(^)(NSArray *tracks, NSError *err))block;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)toggleStarredWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
- (void)starWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
- (void)unstarWithCompletionBlock:(void(^)(BOOL success, NSError *err))completionBlock;
@end
