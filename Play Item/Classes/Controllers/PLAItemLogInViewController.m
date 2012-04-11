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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.view;
    [window setLevel:NSFloatingWindowLevel];

    [playUrlTextField setStringValue:[[PLAController sharedController] playUrl]];
    [authTokenTextField setStringValue:[[PLAController sharedController] authToken]];
  }
  
  return self;
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
