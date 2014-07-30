//
//  WorkoutViewController.m
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "WorkoutViewController.h"
#import "AnalyticsViewController.h"
#import "PastWorkoutCell.h"

@interface WorkoutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *savedLabel;
@property (weak, nonatomic) IBOutlet UITableView *workoutHistoryTable;
@property (strong, nonatomic) NSMutableArray *workoutHistory;
@property (strong, nonatomic) UIGestureRecognizer *tap;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_workoutName];
    [_savedLabel setAlpha:0];
    [_weightField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_setsField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_repsField setKeyboardType:UIKeyboardTypeDecimalPad];
    _saveButton.layer.cornerRadius = 5.0f;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = YES;
    [self.view addGestureRecognizer:_tap];
    
    _workoutHistory = [_workoutData objectForKey:@"data"];
    
    [_workoutHistoryTable setDelegate: self];
    [_workoutHistoryTable setDataSource: self];
}

-(void)hideKeyboard{
    [_weightField resignFirstResponder];
    [_setsField resignFirstResponder];
    [_repsField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_workoutHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"Workout";
    NSDictionary *workout = [_workoutHistory objectAtIndex:[_workoutHistory count] - indexPath.row - 1];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[workout objectForKey:@"timestamp"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    PastWorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.weightLabel setText:[NSString stringWithFormat:@"%@ %@",[NSNumber numberWithDouble:[[workout objectForKey:@"weight"] doubleValue]],[workout objectForKey:@"units"]]];
    [cell.setsRepsLabel setText:[NSString stringWithFormat:@"%@ x %@",[NSNumber numberWithInt:[[workout objectForKey:@"sets"] integerValue]],[NSNumber numberWithInt:[[workout objectForKey:@"reps"] integerValue]]]];
    [cell.timestampLabel setText:[NSString stringWithFormat:@"%@ %@, %@",[formatter stringFromDate:[workout objectForKey:@"timestamp"]],[NSNumber numberWithInteger:[components day]],[NSNumber numberWithInteger:[components year]]]];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"Deleting");
        [_workoutHistory removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [_user saveInBackground];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnalyticsViewController *vc = (AnalyticsViewController *)[segue destinationViewController];
    vc.workoutData = _workoutHistory;
}

- (IBAction)saveWorkout:(id)sender {
    [self hideKeyboard];
    NSString *units = ([[_unitSegments titleForSegmentAtIndex:[_unitSegments selectedSegmentIndex]]isEqualToString:@"Pounds"]) ?@"lbs" : @"kgs";
    NSDictionary *workoutEntry = @{@"timestamp":[NSDate date],@"weight":[NSNumber numberWithDouble:[_weightField.text doubleValue]],@"sets":[NSNumber numberWithInt:[_setsField.text intValue]],@"reps":[NSNumber numberWithInt:[_repsField.text intValue]],@"units": units};
    [_workoutHistory addObject:workoutEntry];
    [_user saveInBackground];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_workoutHistoryTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [_weightField setText:@""];
    [_setsField setText:@""];
    [_repsField setText:@""];
    /*
    [UIView animateWithDuration:0.5f animations:^{
        [_savedLabel setAlpha:1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            [_savedLabel setAlpha:0];
        }];
    }];
     */
    NSLog(@"User: %@",[_user description]);
}

- (IBAction)showAnalytics:(id)sender {
    [self performSegueWithIdentifier:@"Analytics" sender:self];
}
@end
