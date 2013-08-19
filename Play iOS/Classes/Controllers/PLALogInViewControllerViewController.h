//
//  PLALogInViewControllerViewController.h
//  Play Item
//
//  Created by Jon Maddox on 4/10/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLALogInViewControllerViewController : UIViewController <UITextFieldDelegate>{  
  UIButton *urlButton;
  UILabel *welcomeLabel;
  UITextField *playUrlTextField;
}


@property (retain, nonatomic) IBOutlet UIButton *urlButton;
@property (retain, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (retain, nonatomic) IBOutlet UITextField *playUrlTextField;

@end
