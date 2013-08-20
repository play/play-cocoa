//
//  PLAIOSAppDelegate.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAIOSAppDelegate.h"
#import "PLAPlayerViewController.h"
#import "PLAController.h"

@implementation PLAIOSAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc{
  [_window release];
  [_viewController release];

  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
  self.viewController = [[[PLAPlayerViewController alloc] initWithNibName:@"PLAPlayerViewController_iPhone" bundle:nil] autorelease];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
  [[PLAController sharedController] updateNowPlaying];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{  
  [[PLAController sharedController] setAuthToken:[[[url query] componentsSeparatedByString:@"="] lastObject]];
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    if (succeeded) {
      [_viewController.modalViewController dismissViewControllerAnimated:YES completion:^{}];
      [[PLAController sharedController] updateNowPlaying];
    }else{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Play cannot be reached or your log in details are incorrect. Try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
      [alert show];
      [alert release];
    }
  }];
  
  return YES;
}


@end
