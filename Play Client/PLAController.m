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
#import "PLAChannel.h"

#if TARGET_OS_EMBEDDED
#import "Reachability.h"
#endif

NSString *const PLANowPlayingUpdated = @"PLANowPlayingUpdated";
NSString *const PLAChannelTuned = @"PLAChannelTuned";

@implementation PLAController

@synthesize queuedTracks, currentlyPlayingTrack, queuePoller, channels, tunedChannel;

- (void) dealloc{
  [queuedTracks release];
  [currentlyPlayingTrack release];
  [queuePoller invalidate];
  [queuePoller release];
  [channels release];
  [tunedChannel release];

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
  
  self.channels = [NSMutableArray array];
  
  return self;
}

- (void)logInWithBlock:(void(^)(BOOL succeeded))block{
  [[PLAPlayClient sharedClient] getPath:@"/api/channels" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

	if (block != nil)
    self.channels = [NSMutableArray array];
    
    [self updateChannelsWithCompletionBlock:^{
      [self loadTunedChannel];
      
      // nothing got tuned, so just tune the first channel
      if (![self tuned]) {
        NSLog(@"nothing got loaded so we'll do the first channel.");
        NSLog(@"channels: %@", channels);
        [self tuneChannel:[self.channels firstObject]];
      }

      block(YES);
    }];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", error);
	  if (block != nil)
		  block(NO);
  }];

}

- (NSString *)streamUrl{
  return [self.tunedChannel streamUrl];
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

- (void)startPolling{
  [queuePoller invalidate];
  self.queuePoller = nil;
  
  self.queuePoller = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateNowPlaying) userInfo:nil repeats:YES];
  [queuePoller fire];
}

- (void)stopPolling{
  [queuePoller invalidate];
  self.queuePoller = nil;
  [queuePoller release];
}

#pragma mark - Channels

- (void)updateChannelsWithCompletionBlock:(void(^)())completionBlock{
  NSLog(@"updating channels");
  
  [PLAChannel channelsWithBlock:^(NSArray *returnedChannels, NSError *error) {
    
    for (PLAChannel *channel in returnedChannels) {
      NSInteger index = [channels indexOfObject:channel];
      
      if (index != NSNotFound) {
        PLAChannel *foundChannel = [channels objectAtIndex:index];
        [foundChannel setName:[channel name]];
        [foundChannel setNowPlaying:[channel nowPlaying]];
      }else{
        [channels addObject:channel];
      }
    }
    
    completionBlock();
  }];
}

- (void)tuneChannel:(PLAChannel *)channel{
  self.tunedChannel = channel;
  [self saveTunedChannel];
  [self updateNowPlaying];
  [[NSNotificationCenter defaultCenter] postNotificationName:PLAChannelTuned object:nil];
}

- (void)saveTunedChannel{
  if (![self tuned]) return;

  [[NSUserDefaults standardUserDefaults] setObject:self.tunedChannel.slug forKey:@"tunedChannelSlug"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadTunedChannel{
  NSString *channelSlug = [[NSUserDefaults standardUserDefaults]  objectForKey:@"tunedChannelSlug"];
  
  if (channelSlug) {
    for (PLAChannel *channel in self.channels) {
      if ([[channel slug] isEqualToString:channelSlug]) {
        [self tuneChannel:channel];
        break;
      }
    }
  }
}

- (BOOL)tuned{
  return self.tunedChannel != nil;
}

#pragma mark - State methods

- (void)updateNowPlaying{
  if (![self tuned]) return;
  
  NSLog(@"Updating Now Playing");
  
  [tunedChannel currentQueueWithBlock:^(NSArray *tracks, NSError *err) {
    NSMutableArray *foundTracks = [NSMutableArray arrayWithArray:tracks];
    
    if ([foundTracks count] > 0) {
      self.currentlyPlayingTrack = [foundTracks objectAtIndex:0];
      [foundTracks removeObjectAtIndex:0];
    }
    
    self.queuedTracks = [NSArray arrayWithArray:foundTracks];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [[NSNotificationCenter defaultCenter] postNotificationName:PLANowPlayingUpdated object:nil];
    });
  }];  
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
    }];

  }
}
#endif



@end
