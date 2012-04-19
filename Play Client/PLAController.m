//
//  PLAController.m
//  Play Item
//
//  Created by Jon Maddox on 4/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAController.h"

#import "PLAPlayClient.h"
#import "PLATrack.h"
#import "PTPusherChannel.h"

#if TARGET_OS_EMBEDDED
#import "Reachability.h"
#endif

NSString *const PLANowPlayingUpdated = @"PLANowPlayingUpdated";

@implementation PLAController

@synthesize queuedTracks, currentlyPlayingTrack, pusherClient, updateNowPlayingPusherChannelBinding, streamUrl, pusherKey;

- (void) dealloc{
  [queuedTracks release];
  [currentlyPlayingTrack release];
  [pusherClient release];
  [updateNowPlayingPusherChannelBinding release];
  [streamUrl release];
  [pusherKey release];

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
  
  return self;
}

- (void)logInWithBlock:(void(^)(BOOL succeeded))block{
  [[PLAPlayClient sharedClient] getPath:@"/streaming_info" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    self.streamUrl = [responseObject objectForKey:@"stream_url"];
    self.pusherKey = [responseObject objectForKey:@"pusher_key"];

	if (self.pusherClient == nil)
		[self setUpPusher];
    [self subscribeToChannels];

	if (block != nil)
	  block(YES);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", error);
	  if (block != nil)
		  block(NO);
  }];

}

#pragma mark - Pusher Bootstrap

- (PTPusherChannel *)nowPlayingPusherChannel{
  if (pusherClient) {
    return [pusherClient subscribeToChannelNamed:@"now_playing_updates"];
  }
  
  return nil;
}

- (void)setUpPusher{
  self.pusherClient = [PTPusher pusherWithKey:pusherKey delegate:self encrypted:NO];
  [pusherClient setReconnectAutomatically:YES];
  [pusherClient setReconnectDelay:30];  
}

- (void)subscribeToChannels{
  if (pusherClient) {
    NSLog(@"subscribing to channels");
    PTPusherChannel *channel = [self nowPlayingPusherChannel];
    self.updateNowPlayingPusherChannelBinding = [channel bindToEventNamed:@"update_now_playing" target:self action:@selector(channelEventPushed:)];
  }
}

#pragma mark - Settings

- (void)setPlayUrl:(NSString *)url{
  [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"playUrl"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)playUrl{
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"playUrl"];
}

- (void)setAuthToken:(NSString *)token{
  [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"authToken"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)authToken{
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
}

#pragma mark - State methods

- (void)updateNowPlaying:(NSDictionary *)nowPlayingDict{
  // record current state
  self.currentlyPlayingTrack = [[[PLATrack alloc] initWithAttributes:[nowPlayingDict objectForKey:@"now_playing"]] autorelease];

  NSMutableArray *tracks = [NSMutableArray array];
  for (NSDictionary *trackDict in [nowPlayingDict objectForKey:@"songs"]) {
    PLATrack *track = [[PLATrack alloc] initWithAttributes:trackDict];
    [tracks addObject:track];
    [track release];
  }
  
  self.queuedTracks = [NSArray arrayWithArray:tracks];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
}

#pragma mark - Channel Event handler

- (void)channelEventPushed:(PTPusherEvent *)channelEvent{
  if ([[channelEvent name] isEqualToString:@"update_now_playing"]) {
    [self updateNowPlaying:(NSDictionary *)[channelEvent data]];
  }
}

#pragma mark - PTPusher Delegate Methods

- (void)pusher:(PTPusher *)client connectionDidConnect:(PTPusherConnection *)connection{
  NSLog(@"connectionDidConnect");
  client.reconnectAutomatically = YES;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
  NSLog(@"did subscribe to channel: %@", [channel name]);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error{
  NSLog(@"failed to subscribe: %@", error.description);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent{
  NSLog(@"received error event: %@", errorEvent);
}

- (void)pusher:(PTPusher *)client connectionDidDisconnect:(PTPusherConnection *)connection{
  NSLog(@"connectionDidDisconnect");
  
#if TARGET_OS_EMBEDDED
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  if ([reachability currentReachabilityStatus] == NotReachable) {
    NSLog(@"NotReachable");
    client.reconnectAutomatically = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:reachability];
    
    [reachability startNotifier];
  }else{
    [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.currentlyPlayingTrack = track;
        [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
        [self setUpPusher];
        [self subscribeToChannels];
      });
    }];
  }
  
#else
  [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *err) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      self.currentlyPlayingTrack = track;
      [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
      [self setUpPusher];
      [self subscribeToChannels];
    });
  }];
	
	[PLATrack currentQueueWithBlock:^(NSArray *tracks, NSError *err) {
		if (tracks != nil)
			self.queuedTracks = tracks;
	}];
#endif
}

#if TARGET_OS_EMBEDDED
- (void)reachabilityChanged:(NSNotification *)note{
  NSLog(@"reachabilityChanged");
  Reachability *reachability = note.object;
  
  if ([reachability currentReachabilityStatus] != NotReachable) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability stopNotifier];
    
    [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *error) {
      self.currentlyPlayingTrack = track;
      [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
      [self setUpPusher];
      [self subscribeToChannels];
    }];

  }
}
#endif



@end
