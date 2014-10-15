//
//  GymQViewController.m
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "GymQViewController.h"
#import "WorkoutStationViewController.h"
#import "MyStationsViewController.h"
@interface GymQViewController ()
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) NSMutableDictionary *presets;
@end

@implementation GymQViewController{
    NSString *stationCode;
    NSDictionary *currStation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_codeField setDelegate:self];
    _codeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Code" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    NSLog(@"Current User: %@",[_user description]);
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = YES;
    [self.view addGestureRecognizer:_tap];
    if(!_user[@"workouts"]){
        NSLog(@"No workouts found");
        NSArray *existingWorkouts = _user[@"stations"];
    }else{
        NSLog(@"Workouts exists");
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(!_presets){
        PFQuery *query = [PFQuery queryWithClassName:@"PresetStations"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            _presets = [[NSMutableDictionary alloc] init];
            for(PFObject *object in objects){
                NSMutableDictionary *preset = [[NSMutableDictionary alloc] init];
                [preset setObject:object[@"stationName"] forKey:@"stationName"];
                [preset setObject:object[@"workouts"] forKey:@"workouts"];
                [_presets setObject:preset forKey:object[@"code"]];
            }
            //NSLog(@"Presets: %@",[_presets description]);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)syncWithStationName{
    currStation = nil;
    NSArray *userStations = [[NSArray alloc] initWithArray:_user[@"stations"]];
    for(NSDictionary *station in userStations){
        if([station[@"stationName"] isEqualToString:stationCode]){
            currStation = station;
        }
    }
    if(currStation == nil){
        NSMutableArray *workouts = [[NSMutableArray alloc] init];
        currStation = @{@"stationName":stationCode, @"workouts":workouts};
        [_user[@"stations"] addObject:currStation];
        [_user saveInBackground];
    }
    [_codeField resignFirstResponder];
}

- (void) scanViewController:(QRScanViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue{
    NSLog(@"Scanned QR with value: %@", aScannedValue);
    stationCode = [[NSString alloc] initWithString:aScannedValue];
    [self syncWithStationName];
    [self performSegueWithIdentifier:@"WorkoutStation" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"Scan"]){
        QRScanViewController *vc = (QRScanViewController *)[segue destinationViewController];
        vc.delegate = self;
    }else if([[segue identifier] isEqualToString:@"ShowStations"]){
        MyStationsViewController *vc = (MyStationsViewController *)[segue destinationViewController];
        vc.user = _user;
    }else{
        WorkoutStationViewController *vc = (WorkoutStationViewController *)[segue destinationViewController];
        vc.presets = _presets;
        vc.stationCode = stationCode;
        vc.station = currStation;
        vc.user = _user;
    }
}

#pragma mark UITextFieldDelgate methods

-(void)hideKeyboard{
    [_codeField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
    
}

-(void)animateTextField:(UITextField *)textfield up:(BOOL)up{
    int movementDistance;
    
    if(([[UIScreen mainScreen] bounds].size.height - 568) ? NO:YES){
        // iPhone 5/5s keyboard adjustments
        movementDistance = 100;
    }else{
        movementDistance = 140;
    }
    
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


- (IBAction)scanQR:(id)sender {
    [self performSegueWithIdentifier:@"Scan" sender:self];
}

- (IBAction)searchCode:(id)sender {
    if([_codeField.text length] == 0){
        _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a code before searching" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [_alert show];
    }else{
        stationCode = [[NSString alloc] initWithString:_codeField.text];
        [self syncWithStationName];
        [self performSegueWithIdentifier:@"WorkoutStation" sender:self];
    }
}

- (IBAction)logout:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
