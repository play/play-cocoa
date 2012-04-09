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
}

@property (nonatomic, retain) NSArray *queuedTracks;
@property (nonatomic, retain) PLATrack *currentlyPlayingTrack;
@property (nonatomic, retain) PTPusher *pusherClient;

+ (PLAController *)sharedController;

@end
