//
//  WorkoutViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WorkoutViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong,nonatomic) NSString *workoutName;
@property (strong,nonatomic) NSDictionary *workoutData;
@property (strong,nonatomic) PFUser *user;

@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UITextField *setsField;
@property (weak, nonatomic) IBOutlet UITextField *repsField;
@property (weak, nonatomic) IBOutlet UITextField *distanceField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *switchTypeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegments;
@property (weak, nonatomic) IBOutlet UISegmentedControl *distanceSegments;
@property (weak, nonatomic) IBOutlet UILabel *weightXSets;
@property (weak, nonatomic) IBOutlet UILabel *setsXReps;
- (IBAction)saveWorkout:(id)sender;
- (IBAction)showAnalytics:(id)sender;

@end
