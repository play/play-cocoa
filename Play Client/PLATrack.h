//
//  PLTrack.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLATrack : NSObject{
  NSString *trackId;
  NSString *name;
  NSString *album;
  NSString *artist;
  BOOL starred;
  BOOL queued;
}

@property (nonatomic, retain) NSString *trackId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, assign) BOOL queued;
@property (nonatomic, readonly) NSURL *albumArtURL;

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (void)currentTrackWithBlock:(void(^)(PLATrack *track))block;

@end
