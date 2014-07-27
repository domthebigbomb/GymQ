//
//  LoginViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;


- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)makeAccount:(id)sender;

@end
