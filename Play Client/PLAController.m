//
//  PLAController.m
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAController.h"

@implementation PLAController

@synthesize queuedTracks, currentlyPlayingTrack, pusherClient;

- (void) dealloc{
  [queuedTracks release];
  [currentlyPlayingTrack release];
  [pusherClient release];

  [super dealloc];
}

+ (PLAController *)sharedController {
  static PLAController *_sharedController = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedController = [[self alloc] init];
  });
  
  return _sharedController;
}

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  
//  NSData *settingsFile = [NSData dataWithContentsOfFile:[self settingsPath]];
//  
//  if ([NSKeyedUnarchiver unarchiveObjectWithData:settingsFile]){
//    self.settingsDict = [NSKeyedUnarchiver unarchiveObjectWithData:settingsFile];
//    if (![settingsDict objectForKey:@"joinedRooms"]) {
//      [settingsDict setObject:[NSMutableArray array] forKey:@"joinedRooms"];
//      [self saveSettings];
//    }
//  }else{
//    self.settingsDict = [NSMutableDictionary dictionary];
//    [settingsDict setObject:[NSMutableArray array] forKey:@"joinedRooms"];
//    [self saveSettings];
//  }
  
  
  // set up pusher stuff
  
  self.pusherClient = [PTPusher pusherWithKey:@"e9b0032af2f98b47120f" delegate:self encrypted:NO];
  
  PTPusherChannel *channel = [pusherClient subscribeToChannelNamed:@"now_playing_updates"];
  
  [channel bindToEventNamed:@"update_now_playing" handleWithBlock:^(PTPusherEvent *channelEvent) {
    NSLog(@"eventtttttttt: %@", channelEvent);
  }];
    

  
  return self;
}


- (void)didReceiveChannelEventNotification:(NSNotification *)notification{
  NSLog(@"notification: %@", notification);
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request{
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error{
  NSLog(@"failed to subscribe: %@", error.description);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent{
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
}




@end
