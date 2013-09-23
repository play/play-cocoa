//
//  PLAIOSAppDelegate.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLAPlayerViewController;
@class PLANavigationController;

@interface PLAIOSAppDelegate : UIResponder <UIApplicationDelegate>{
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PLAPlayerViewController *viewController;
@property (strong, nonatomic) PLANavigationController *rootViewController;

@end
