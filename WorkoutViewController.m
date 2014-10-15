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
@property (strong, nonatomic) UIPickerView *timePicker;

@end

@implementation WorkoutViewController{
    NSMutableArray *minSecNums;
    NSMutableArray *hourNums;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_workoutName];
    [_savedLabel setAlpha:0];
    [_weightField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_setsField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_repsField setKeyboardType:UIKeyboardTypeDecimalPad];
    _saveButton.layer.cornerRadius = 5.0f;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = NO;
    [self.view addGestureRecognizer:_tap];
    
    minSecNums = [[NSMutableArray alloc] init];
    for(int i = 0; i< 60; i++){
        [minSecNums addObject:[NSNumber numberWithInt:i]];
    }
    hourNums = [[NSMutableArray alloc] init];
    for(int i = 0; i<99; i++){
        [hourNums addObject:[NSNumber numberWithInt:i]];
    }
    
    _timePicker = [[UIPickerView alloc] init];
    [_timePicker setDelegate:self];
    [_timePicker setDataSource:self];
    [_timeField setInputView:_timePicker];
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0,0, 320, 44)]; //should code with variables to support view resizing
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(inputAccessoryViewDidFinish)];
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    _timeField.inputAccessoryView = myToolbar;
    
    _workoutHistory = [_workoutData objectForKey:@"data"];
    
    [_workoutHistoryTable setDelegate: self];
    [_workoutHistoryTable setDataSource: self];
}

-(void)inputAccessoryViewDidFinish{
    [_timeField resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [_tap setEnabled:YES];
    return YES;
}

-(void)hideKeyboard{
    [_weightField resignFirstResponder];
    [_setsField resignFirstResponder];
    [_repsField resignFirstResponder];
    [_distanceField resignFirstResponder];
    [_timeField resignFirstResponder];
    [_tap setEnabled:NO];
}


-(NSString *)durationToString:(NSInteger) interval{
    NSLog(@"Interval: %d",interval);
    NSInteger hour = interval / 3600;
    interval %= 3600;
    NSInteger min = interval / 60;
    interval %= 60;
    NSInteger sec = interval;
    NSString *string = [[NSString alloc] initWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)min,(long)sec];
    NSLog(@"String: %@", string);
    return string;
}

#pragma mark - UIPickerViewDelegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(component == 0){
        return [hourNums count];
    }else{
        return [minSecNums count];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0){
        return [NSString stringWithFormat:@"%02ld",(long)row];
    }else if(component == 1){
        return [NSString stringWithFormat:@"%02ld",(long)row];
    }else{
        return [NSString stringWithFormat:@"%02ld",(long)row];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSMutableString *time = [[_timeField text] mutableCopy];
    if(component == 0){
        NSString *remainder = [time substringFromIndex:2];
        NSMutableString *newHour = [[NSMutableString alloc] initWithFormat:@"%02ld", (long)row];
        [newHour appendString:remainder];
        [_timeField setText:newHour];
    }else if(component == 1){
        NSMutableString *pre = [[time substringToIndex:3] mutableCopy];
        NSString *post = [time substringFromIndex:5];
        NSString *newMin = [[NSString alloc] initWithFormat:@"%02ld", (long)row];
        [pre appendString:newMin];
        [pre appendString:post];
        [_timeField setText:pre];
    }else{
        NSMutableString *pre = [[time substringToIndex:6] mutableCopy];
        NSString *newSS = [[NSString alloc] initWithFormat:@"%02ld",(long)row];
        [pre appendString:newSS];
        [_timeField setText:pre];
    }
}

#pragma mark - UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([_workoutHistory count] > 0){
        [_switchTypeButton setHidden:YES];
        NSString *units = [[_workoutHistory firstObject] objectForKey:@"units"];
        if([units isEqualToString:@"mi"] || [units isEqualToString:@"km"]){
            [_distanceField setHidden:NO];
            [_timeField setHidden:NO];
            [_setsField setHidden:YES];
            [_repsField setHidden:YES];
            [_weightField setHidden:YES];
            [_unitSegments setHidden:YES];
            [_distanceSegments setHidden:NO];
            [_weightXSets setHidden:YES];
            [_setsXReps setHidden:YES];
            [[_switchTypeButton titleLabel] setText:@"Switch to Lifting"];
        }
    }
    return [_workoutHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"Workout";
    NSDictionary *workout = [_workoutHistory objectAtIndex:[_workoutHistory count] - indexPath.row - 1];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[workout objectForKey:@"timestamp"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    PastWorkoutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if([[_switchTypeButton titleLabel].text isEqualToString:@"Switch to Cardio"]){
        [cell.weightLabel setText:[NSString stringWithFormat:@"%@ %@",[NSNumber numberWithDouble:[[workout objectForKey:@"weight"] doubleValue]],[workout objectForKey:@"units"]]];
        [cell.setsRepsLabel setText:[NSString stringWithFormat:@"%@ x %@",[NSNumber numberWithInt:[[workout objectForKey:@"sets"] integerValue]],[NSNumber numberWithInteger:[[workout objectForKey:@"reps"] integerValue]]]];
    }else{
        [cell.weightLabel setText:[NSString stringWithFormat:@"%@ %@",[NSNumber numberWithDouble:[[workout objectForKey:@"distance"] doubleValue]],[workout objectForKey:@"units"]]];
        [cell.setsRepsLabel setText:[NSString stringWithFormat:@"%@",[self durationToString:[[workout objectForKey:@"duration"] integerValue]]]];
    }
    
    [cell.timestampLabel setText:[NSString stringWithFormat:@"%@ %@, %@",[formatter stringFromDate:[workout objectForKey:@"timestamp"]],[NSNumber numberWithInteger:[components day]],[NSNumber numberWithInteger:[components year]]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"Deleting");
        [_workoutHistory removeObjectAtIndex:[_workoutHistory count] - indexPath.row - 1];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [_user saveInBackground];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *workout = [_workoutHistory objectAtIndex:[_workoutHistory count] - indexPath.row - 1];
    if([[_switchTypeButton titleLabel].text isEqualToString:@"Switch to Cardio"]){
        [_weightField setText:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[[workout objectForKey:@"weight"] doubleValue]]]];
        [_setsField setText:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[[workout objectForKey:@"sets"] integerValue]]]];
        [_repsField setText:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[[workout objectForKey:@"reps"] integerValue]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else{
        [_distanceField setText:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[[workout objectForKey:@"distance"] doubleValue]]]];
        [_timeField setText:[self durationToString:[[workout objectForKey:@"duration"] integerValue]]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnalyticsViewController *vc = (AnalyticsViewController *)[segue destinationViewController];
    vc.workoutData = _workoutHistory;
}

-(IBAction)switchType:(id)sender{
    if([_switchTypeButton.currentTitle isEqualToString:@"Switch to Cardio"]){
        // Switch to cardio
        [_distanceField setHidden:NO];
        [_timeField setHidden:NO];
        [_setsField setHidden:YES];
        [_repsField setHidden:YES];
        [_weightField setHidden:YES];
        [_unitSegments setHidden:YES];
        [_distanceSegments setHidden:NO];
        [_weightXSets setHidden:YES];
        [_setsXReps setHidden:YES];
        [_switchTypeButton setTitle:@"Switch to Lifting" forState:UIControlStateNormal];
    }else{
        // Switch to lifting
        [_distanceField setHidden:YES];
        [_timeField setHidden:YES];
        [_setsField setHidden:NO];
        [_repsField setHidden:NO];
        [_weightField setHidden:NO];
        [_unitSegments setHidden:NO];
        [_weightXSets setHidden:NO];
        [_setsXReps setHidden:NO];
        [_distanceSegments setHidden:YES];
        [_switchTypeButton setTitle:@"Switch to Cardio" forState:UIControlStateNormal];
    }
}

- (IBAction)saveWorkout:(id)sender {
    [self hideKeyboard];
    if([[_switchTypeButton titleLabel].text isEqualToString:@"Switch to Cardio"]){
        // Lifting mode
        NSString *units = ([[_unitSegments titleForSegmentAtIndex:[_unitSegments selectedSegmentIndex]]isEqualToString:@"Pounds"]) ?@"lbs" : @"kgs";
        NSDictionary *workoutEntry = @{@"timestamp":[NSDate date],@"weight":[NSNumber numberWithDouble:[_weightField.text doubleValue]],@"sets":[NSNumber numberWithInt:[_setsField.text intValue]],@"reps":[NSNumber numberWithInt:[_repsField.text intValue]],@"units": units};
        [_workoutHistory addObject:workoutEntry];
        [_user saveInBackground];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_workoutHistoryTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [_weightField setText:@""];
        [_setsField setText:@""];
        [_repsField setText:@""];
    }else{
        NSString *units = ([[_distanceSegments titleForSegmentAtIndex:[_distanceSegments selectedSegmentIndex]]isEqualToString:@"Miles"]) ?@"mi" : @"km";
        NSInteger hh = [[_timeField.text substringToIndex:2] integerValue];
        NSInteger mm = [[[_timeField.text substringFromIndex:3] substringToIndex:2] integerValue];
        NSInteger ss = [[[_timeField.text substringFromIndex:6] substringToIndex:2] integerValue];
        NSTimeInterval interval = (hh * 3600) + (mm * 60) + ss;
        NSNumber *velocity = [NSNumber numberWithDouble:([_distanceField.text doubleValue]/interval) * 3600] ;
        NSDictionary *workoutEntry = @{@"timestamp":[NSDate date],@"distance":[NSNumber numberWithDouble:[_distanceField.text doubleValue]],@"duration":[NSNumber numberWithInt:interval],@"velocity": velocity,@"units": units};
        [_workoutHistory addObject:workoutEntry];
        [_user saveInBackground];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_workoutHistoryTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [_distanceField setText:@""];
        [_timeField setText:@"00:00:00"];
    }
    

    NSLog(@"User: %@",[_user description]);
}

- (IBAction)showAnalytics:(id)sender {
    [self performSegueWithIdentifier:@"Analytics" sender:self];
}
@end
