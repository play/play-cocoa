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

@synthesize queuedTracks, currentlyPlayingTrack;

- (void) dealloc{
  [queuedTracks release];
  [currentlyPlayingTrack release];

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
  return [NSString stringWithFormat:@"%@:8000", [[PLAController sharedController] playUrl]];
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

  }
    
  
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
