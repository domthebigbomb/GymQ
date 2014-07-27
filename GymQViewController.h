//
//  GymQViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRScanViewController.h"
#import <Parse/Parse.h>
@interface GymQViewController : UIViewController<QRScanViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (strong) PFUser *user;

- (IBAction)scanQR:(id)sender;
- (IBAction)searchCode:(id)sender;
- (IBAction)logout:(id)sender;

@end
