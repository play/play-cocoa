//
//  PLALogInViewControllerViewController.h
//  Play Item
//
//  Created by Jon Maddox on 4/10/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLALogInViewControllerViewController : UIViewController <UITextFieldDelegate>{
  UIScrollView *pagingScrollView;
  UIPageControl *pageControl;
  
  UIView *urlView;
  UIView *tokenView;
  UIButton *urlButton;
  UILabel *welcomeLabel;
  UILabel *urlInstructionLabel;
  UILabel *tokenInstructionLabel;
  
  UITextField *playUrlTextField;
  UITextField *playTokenTextField;
  BOOL pageControlBeingUsed;
}

@property (strong, nonatomic) IBOutlet UIScrollView *pagingScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *urlView;
@property (strong, nonatomic) IBOutlet UIView *tokenView;
@property (strong, nonatomic) IBOutlet UIButton *urlButton;
@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UILabel *urlInstructionLabel;
@property (strong, nonatomic) IBOutlet UILabel *tokenInstructionLabel;

@property (strong, nonatomic) IBOutlet UITextField *playUrlTextField;
@property (strong, nonatomic) IBOutlet UITextField *playTokenTextField;

@end
