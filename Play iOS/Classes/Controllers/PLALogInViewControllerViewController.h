//
//  PLALogInViewControllerViewController.h
//  Play Item
//
//  Created by Jon Maddox on 4/10/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLALogInViewControllerViewController : UIViewController <UITextFieldDelegate>{
  UITextField *playUrlTextField;
  UITextField *playTokenTextField;
}

@property (retain, nonatomic) IBOutlet UITextField *playUrlTextField;
@property (retain, nonatomic) IBOutlet UITextField *playTokenTextField;

@end
