//
//  PLAItemLogInViewController.m
//  Play Item
//
//  Created by Jon Maddox on 4/11/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAItemLogInViewController.h"
#import "PLAController.h"
#import "PLAItemAppDelegate.h"

@implementation PLAItemLogInViewController
@synthesize playUrlTextField, authTokenTextField, window;

- (void)dealloc{
  [playUrlTextField release];
  [authTokenTextField release];
  [window release];
  
  [super dealloc];
}

- (void)awakeFromNib
{
	[window setLevel:NSFloatingWindowLevel];
	
	NSString *playURL = [[PLAController sharedController] playUrl]; //A URL which isn't NSURL… quit trolling maddox
    [playUrlTextField setStringValue:(playURL ?: @"")];
	
	NSString *token = [[PLAController sharedController] authToken];
    [authTokenTextField setStringValue:(token ?: @"")];
}

- (IBAction)logIn:(id)sender{
  [[PLAController sharedController] setPlayUrl:playUrlTextField.stringValue];
  [[PLAController sharedController] setAuthToken:authTokenTextField.stringValue];
  
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [window orderOut:self];
        PLAItemAppDelegate *appDelegate = (PLAItemAppDelegate *)[NSApp delegate];
        [appDelegate didLogIn];
      }else{
        [window shake];
      }
    });
  }];
}

@end
