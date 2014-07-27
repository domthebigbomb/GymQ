//
//  WorkoutStationViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WorkoutStationViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSDictionary *station;
@property (strong, nonatomic) NSString *stationCode;

@end
