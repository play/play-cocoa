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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  self.viewController = [[PLAPlayerViewController alloc] initWithNibName:@"PLAPlayerViewController_iPhone" bundle:nil];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
