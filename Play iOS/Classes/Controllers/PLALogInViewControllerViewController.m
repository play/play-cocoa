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
@synthesize pagingScrollView, pageControl, urlView, tokenView, playUrlTextField, playTokenTextField, urlButton;

- (void)dealloc {
  [playUrlTextField release];
  [playTokenTextField release];
  [pagingScrollView release];
  [pageControl release];
  [tokenView release];
  [urlView release];
  [urlButton release];
  [super dealloc];
}


- (void)viewDidLoad{
  [super viewDidLoad];
  
  pageControlBeingUsed = NO;
  
  if ([[PLAController sharedController] playUrl]) {
    [playUrlTextField setText:[[PLAController sharedController] playUrl]];
  }

  if ([[PLAController sharedController] authToken]) {
    [playTokenTextField setText:[[PLAController sharedController] authToken]];
  }
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];

  CGFloat pageWidth = self.view.bounds.size.width;
  
  [pagingScrollView setContentSize:CGSizeMake(pageWidth * 2, 200.0)];
  [pagingScrollView setPagingEnabled:YES];
  
  
  [urlView setFrame:CGRectMake(0, 0, pageWidth, 200.0)];  
  [tokenView setFrame:CGRectMake(pageWidth, 0, pageWidth, 200.0)];
  
  [pagingScrollView addSubview:urlView];
  [pagingScrollView addSubview:tokenView];
  
  [pageControl setNumberOfPages:2];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  
  CGFloat pageWidth = self.view.bounds.size.width;
  NSLog(@"pageWidth: %f", pageWidth);

  [playUrlTextField becomeFirstResponder];
}

- (void)viewDidUnload{
  self.playUrlTextField = nil;
  self.playTokenTextField = nil;
  self.pagingScrollView = nil;
  self.pageControl = nil;
  self.urlView = nil;
  self.tokenView = nil;
  self.urlButton = nil;
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

- (IBAction)changePage {
  pageControlBeingUsed = YES;
  CGRect frame;
  frame.origin.x = self.pagingScrollView.frame.size.width * self.pageControl.currentPage;
  frame.origin.y = 0;
  frame.size = self.pagingScrollView.frame.size;
  [self.pagingScrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)goToPlayToken{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/token?back_to=play-ios://", playUrlTextField.text]]];
}

- (void)setUpTokenView{
  [urlButton setTitle:[NSString stringWithFormat:@"%@ →", playUrlTextField.text] forState:UIControlStateNormal];
  
  pageControl.currentPage = 2;
  [self changePage];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  pageControlBeingUsed = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
  if (!pageControlBeingUsed) {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.pagingScrollView.frame.size.width;
    int page = floor((self.pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  if (textField == playUrlTextField) {
    [self setUpTokenView];
  }else{
    [self logIn];
  }
  
  return YES;
}

@end
