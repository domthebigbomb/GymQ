//
//  MyStationsViewController.h
//  GymQ
//
//  Created by Dominic Ong on 10/11/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface MyStationsViewController : UITableViewController<UIActionSheetDelegate>

@property (strong, nonatomic) PFUser *user;
@end
