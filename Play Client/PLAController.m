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

#if TARGET_OS_EMBEDDED
#import "Reachability.h"
#endif

NSString *const PLANowPlayingUpdated = @"PLANowPlayingUpdated";

@implementation PLAController

@synthesize queuedTracks, currentlyPlayingTrack, queuePoller;

- (void) dealloc{
  [queuedTracks release];
  [currentlyPlayingTrack release];
  [queuePoller invalidate];
  [queuePoller release];

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
  [[PLAPlayClient sharedClient] getPath:@"/api/now_playing" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

	if (block != nil)
	  block(YES);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", error);
	  if (block != nil)
		  block(NO);
  }];

}

- (NSString *)streamUrl{
  return [NSString stringWithFormat:@"%@/api/stream?token=%@", [[PLAController sharedController] playUrl], [self authToken]];
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
  if (queuePoller) return;
  
  self.queuePoller = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(updateNowPlaying) userInfo:nil repeats:YES];
  [queuePoller fire];
}

- (void)stopPolling{
  [queuePoller invalidate];
  self.queuePoller = nil;
  [queuePoller release];
}

#pragma mark - State methods

- (void)updateNowPlaying{
  NSLog(@"Updating Now Playing");
  
  [PLATrack currentQueueWithBlock:^(NSArray *tracks, NSError *err) {
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
