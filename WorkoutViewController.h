//
//  WorkoutViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WorkoutViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSString *workoutName;
@property (strong,nonatomic) NSDictionary *workoutData;
@property (strong,nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UITextField *setsField;
@property (weak, nonatomic) IBOutlet UITextField *repsField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegments;
- (IBAction)saveWorkout:(id)sender;
- (IBAction)showAnalytics:(id)sender;

@end
