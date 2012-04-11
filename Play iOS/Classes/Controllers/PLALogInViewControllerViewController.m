//
//  PLALogInViewControllerViewController.m
//  Play Item
//
//  Created by Jon Maddox on 4/10/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLALogInViewControllerViewController.h"
#import "PLAController.h"
#import "PLAPlayerViewController.h"

@implementation PLALogInViewControllerViewController
@synthesize playUrlTextField, playTokenTextField;

- (void)dealloc {
  [playUrlTextField release];
  [playTokenTextField release];
  [super dealloc];
}


- (void)viewDidLoad{
  [super viewDidLoad];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
  }

  
  if ([[PLAController sharedController] playUrl]) {
    [playUrlTextField setText:[[PLAController sharedController] playUrl]];
  }

  if ([[PLAController sharedController] authToken]) {
    [playTokenTextField setText:[[PLAController sharedController] authToken]];
  }
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  
  [playUrlTextField becomeFirstResponder];
}

- (void)viewDidUnload{
  self.playUrlTextField = nil;
  self.playTokenTextField = nil;
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
    return YES;
  }
}

- (void)logIn{
  [[PLAController sharedController] setPlayUrl:playUrlTextField.text];
  [[PLAController sharedController] setAuthToken:playTokenTextField.text];
    
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [(PLAPlayerViewController *)self.presentingViewController setUpForStreaming];
        [self dismissModalViewControllerAnimated:YES];
      }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Play cannot be reached or your log in details are incorrect. Try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
      }
    });
  }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  if (textField == playUrlTextField) {
    [playTokenTextField becomeFirstResponder];
  }else{
    [self logIn];
  }
  
  return YES;
}

@end
