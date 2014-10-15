//
//  WorkoutStationViewController.m
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "WorkoutStationViewController.h"
#import "WorkoutViewController.h"
#import "WorkoutCell.h"
#import "AddCell.h"

@interface WorkoutStationViewController ()
@property (strong, nonatomic) NSMutableArray *workoutList;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) NSMutableArray *existingWorkouts;
@end

@implementation WorkoutStationViewController{
    NSString *selectedWorkout;
    NSDictionary *selectedData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Showing for station: %@",_stationCode);
    NSLog(@"Station data: %@",[_station description]);
    NSString *stationName = [[NSString alloc] initWithString:([_presets objectForKey:_stationCode] == nil) ? _stationCode : [[_presets objectForKey:_stationCode] objectForKey:@"stationName"]];
    [self setTitle:stationName];
    _workoutList = [_station objectForKey:@"workouts"];
    if([_workoutList count] == 0 && _presets){
        for(NSString *workoutName in [[_presets objectForKey:_stationCode] objectForKey:@"workouts"]){
            NSMutableArray *data = [[NSMutableArray alloc] init];
            NSDictionary *workout = @{@"workoutName":workoutName,@"data":data};
            [_workoutList addObject:workout];
        }
    }else{
    }
    
    
    NSMutableDictionary *workouts = _user[@"workouts"];
    if(_user[@"workouts"] == nil){
        _user[@"workouts"] = [[NSMutableDictionary alloc] init];
        workouts = _user[@"workouts"];
    }
    
    for(NSDictionary *workout in _workoutList){
        if(![workouts.allKeys containsObject:[workout objectForKey:@"workoutName"]]){
            [workouts setObject:[workout objectForKey:@"data"] forKey:[workout objectForKey:@"workoutName"]];
        }
    }
    
    [_user saveInBackground];
    _existingWorkouts = [[NSMutableArray alloc] init];
    for(NSDictionary *workout in _workoutList){
        [_existingWorkouts addObject:[workout objectForKey:@"workoutName"]];
    }
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = NO;
    //[self.view addGestureRecognizer:_tap];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark UITableViewDelegate methods

-(void)hideKeyboard{
    NSIndexPath *path = [NSIndexPath indexPathForRow:[_workoutList count] inSection:0];
    AddCell *cell = (AddCell *)[self.tableView cellForRowAtIndexPath:path];
    [cell.workoutField resignFirstResponder];
    _tap.enabled = NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_workoutList count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row != [_workoutList count]){
        return 60.0;
    }else{
        return 100.0;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseId;
    if(indexPath.row == [_workoutList count]){
        reuseId = @"Add";
        AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
        cell.workoutField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Workout Name Here" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        cell.workoutField.delegate = self;
        return cell;
    }else{
        reuseId = @"Workout";
        WorkoutCell *cell = (WorkoutCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
        [cell.workoutLabel setText:[[_workoutList objectAtIndex:indexPath.row] objectForKey:@"workoutName"]];
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == [_workoutList count]){
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideKeyboard];
    if(indexPath.row == [_workoutList count]){
        AddCell *cell = (AddCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *workoutName = cell.workoutField.text;
        if([workoutName length] != 0 && ![_existingWorkouts containsObject:workoutName]){
            NSString *firstLetter = [[workoutName substringToIndex:1] capitalizedString];
            workoutName = [NSString stringWithFormat:@"%@%@",firstLetter,[workoutName substringFromIndex:1]];
            NSMutableArray *data = [[NSMutableArray alloc] init];
            NSDictionary *workout = @{@"workoutName":workoutName,@"data":data};
            [_workoutList addObject:workout];
            /*
            NSMutableDictionary *workouts =_user[@"workouts"];
            if(![workouts.allKeys containsObject:workoutName]){
                [workouts setObject:data forKey:workoutName];
            }
             */
            [_user saveInBackground];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[_workoutList count]-1 inSection:0];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
            [tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_workoutList count] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [cell.workoutField setText:@""];
            [cell.workoutField resignFirstResponder];
        }else if([_existingWorkouts containsObject:workoutName]){
            _alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Workout already exists!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [_alert show];
        }else{
            _alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please enter a workout name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [_alert show];
        }
    }else{
        WorkoutCell *cell = (WorkoutCell *)[tableView cellForRowAtIndexPath:indexPath];
        selectedWorkout = [[NSString alloc] initWithString:cell.workoutLabel.text];
        selectedData = [_workoutList objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"Workout" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"Deleting");
        [_workoutList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [_user saveInBackground];
    }
}

#pragma mark UITextFieldDelgate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //[self animateTextField: textField up: YES];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    //[self animateTextField: textField up: NO];
    
}

-(void)animateTextField:(UITextField *)textfield up:(BOOL)up{
    int movementDistance = 140;
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    WorkoutViewController *vc = (WorkoutViewController *)[segue destinationViewController];
    vc.workoutName = selectedWorkout;
    vc.user = _user;
    vc.workoutData = selectedData;
}


@end
