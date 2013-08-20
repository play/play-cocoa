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
@synthesize welcomeLabel, playUrlTextField, urlButton;

- (void)dealloc {
  [playUrlTextField release];
  [urlButton release];
  [welcomeLabel release];
  [super dealloc];
}


- (void)viewDidLoad{
  [super viewDidLoad];
  
  [welcomeLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:24.0]];
  
  if ([[PLAController sharedController] playUrl]) {
    [playUrlTextField setText:[[PLAController sharedController] playUrl]];
  }
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  
  [playUrlTextField becomeFirstResponder];
}

- (void)viewDidUnload{
  self.playUrlTextField = nil;
  self.urlButton = nil;
  self.welcomeLabel = nil;
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
    return YES;
  }
}


- (IBAction)logIn{
  [[PLAController sharedController] setPlayUrl:playUrlTextField.text];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/account/token?back_to=play-ios://", playUrlTextField.text]]];
}

- (void)setFirstResponder{
  [playUrlTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  [self logIn];
  
  return YES;
}

@end
