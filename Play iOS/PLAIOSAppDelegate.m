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
  
  [[PLAController sharedController] setPlayUrl:@"http://localhost:5050"];

  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      self.viewController = [[[PLAPlayerViewController alloc] initWithNibName:@"PLPlayerViewController_iPhone" bundle:nil] autorelease];
  } else {
      self.viewController = [[[PLAPlayerViewController alloc] initWithNibName:@"PLPlayerViewController_iPad" bundle:nil] autorelease];
  }
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
}

- (void)applicationWillTerminate:(UIApplication *)application{
}

@end
