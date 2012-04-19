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

@property (retain, nonatomic) IBOutlet UIScrollView *pagingScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UIView *urlView;
@property (retain, nonatomic) IBOutlet UIView *tokenView;
@property (retain, nonatomic) IBOutlet UIButton *urlButton;
@property (retain, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (retain, nonatomic) IBOutlet UILabel *urlInstructionLabel;
@property (retain, nonatomic) IBOutlet UILabel *tokenInstructionLabel;

@property (retain, nonatomic) IBOutlet UITextField *playUrlTextField;
@property (retain, nonatomic) IBOutlet UITextField *playTokenTextField;

@end
