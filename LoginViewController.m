//
//  LoginViewController.m
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "LoginViewController.h"
#import "GymQViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginToAccountConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBgToLogoConstraint;
@property (weak, nonatomic) IBOutlet UIView *loginBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameToLogoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordToLogoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmPasswordToLogoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailToLogoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBgHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIAlertView *alert;
@end

@implementation LoginViewController{
    CGFloat originalY;
    CGRect originalLoginBg;
    PFUser *currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    _confirmPasswordField.delegate = self;
    _emailField.delegate = self;
    
    _loginBgView.layer.cornerRadius = 5.0f;
    [_confirmPasswordField setAlpha:0];
    [_emailField setAlpha:0];
    if(([[UIScreen mainScreen] bounds].size.height - 568) ? NO:YES){
        // iPhone 5/5s keyboard adjustments
        //_backgroundImageConstraint.constant = 0;
    }

    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = YES;
    [self.view addGestureRecognizer:_tap];
}

-(void)hideKeyboard{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_confirmPasswordField resignFirstResponder];
    [_emailField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    currentUser = nil;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]){
        [_usernameField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
        [_passwordField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];

}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];

}

-(void)animateTextField:(UITextField *)textfield up:(BOOL)up{
    int movementDistance = 0;

    if(([[UIScreen mainScreen] bounds].size.height - 568) ? NO:YES){
        movementDistance = 120;
    }else{
        movementDistance = 160;
        if(textfield == _emailField ){
            movementDistance = 180;
        }
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    _backgroundImageConstraint.constant = _backgroundImageConstraint.constant + movement;

    [UIView animateWithDuration:.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_usernameField]){
        [_passwordField becomeFirstResponder];
    }else if(_signupButton.hidden){
        [self performSelector:@selector(login:) withObject:self];
    }else{
        if([textField isEqual:_passwordField]){
            [_confirmPasswordField becomeFirstResponder];
        }else if([textField isEqual: _confirmPasswordField]){
            [_emailField becomeFirstResponder];
        }else if([textField isEqual:_emailField]){
            [self performSelector:@selector(signup:) withObject:self];
        }
    }
    return YES;
}

- (IBAction)login:(id)sender {
    [self.view layoutIfNeeded];

    if([[_loginButton currentTitle] isEqualToString:@"Back"]){
        [_accountButton setHidden:NO];
        [_signupButton setHidden:YES];
        [_passwordField setReturnKeyType:UIReturnKeyGo];

        [_usernameField setPlaceholder:@"Username"];

        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];

        [UIView animateWithDuration:0.35 animations:^{
            [_emailField setAlpha:0];
        } completion:nil];
        
        [UIView animateWithDuration:.35 delay:.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_confirmPasswordField setAlpha:0];
        } completion:nil];
        
        [UIView animateWithDuration:.25 delay:.75 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_rememberMeLabel setAlpha:1.0];
            [_rememberMeSwitch setAlpha:1.0];
        } completion:nil];
        
        [UIView animateWithDuration:.75 delay:.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _loginBgToLogoConstraint.constant = 33;
            _loginBgHeightConstraint.constant = 115;
            _loginToAccountConstraint.constant = 10;
            _usernameToLogoConstraint.constant = 53;
            _passwordToLogoConstraint.constant = 98;
            _confirmPasswordToLogoConstraint.constant = 143;
            _emailToLogoConstraint.constant = 188;
            
            [_loginButton setAlpha:1.0];

            [self.view layoutIfNeeded];

        } completion:nil];
    }else{
        [_loginButton setEnabled:NO];
        [_activityView startAnimating];
        [PFUser logInWithUsernameInBackground:_usernameField.text password:_passwordField.text block:^(PFUser *user, NSError *error) {
            if(!error){
                [_activityView stopAnimating];
                [_loginButton setEnabled:YES];
                NSLog(@"Login successful");
                [self saveUsername:_usernameField.text Password:_passwordField.text];
                [_usernameField setText:@""];
                [_passwordField setText:@""];
                [_confirmPasswordField setText:@""];
                [_emailField setText:@""];
                currentUser = user;
                [self performSegueWithIdentifier:@"Login" sender:self];
            }else{
                [_loginButton setEnabled:YES];
                [_activityView stopAnimating];
                NSLog(@"Error logging in: %@", [error description]);
                if([[error description] rangeOfString:@"invalid login credentials"].location != NSNotFound){
                    _alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Invalid credentials" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [_alert show];
                }
            }
        }];
    }
}

-(void)saveUsername:(NSString *)username Password:(NSString *)password {
    if([_rememberMeSwitch isOn]){
        // Remember user
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    }
}

- (IBAction)signup:(id)sender {
    
    if([_usernameField.text length] == 0 || [_passwordField.text length] == 0 || [_confirmPasswordField.text length] == 0 || [_emailField.text length] == 0){
        _alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill in all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [_alert show];
    }else{
        if([_passwordField.text isEqualToString:_confirmPasswordField.text]){
            PFUser *newUser = [PFUser user];
            newUser.username = _usernameField.text;
            newUser.password = _passwordField.text;
            newUser.email = _emailField.text;
            newUser[@"workouts"] = @[];
            newUser[@"stations"] = @[];
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    NSLog(@"Signup successful");
                    currentUser = newUser;
                    _alert = [[UIAlertView alloc] initWithTitle:@"Yay!" message:@"You have succesfully signed up for GymQ. Please login now." delegate:self cancelButtonTitle:@"Thanks" otherButtonTitles: nil];
                    [_alert show];
                    [_confirmPasswordField setText:@""];
                    [_emailField setText:@""];
                    [self hideKeyboard];
                    [self performSelector:@selector(login:) withObject:sender];
                }else{
                    NSLog(@"Error signing up: %@",[error description]);
                    _alert = [[UIAlertView alloc] initWithTitle:@"Error Signing Up" message:@"Error msg" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [_alert show];
                }
            }];
            
        }else{
            _alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your passwords did not match" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [_alert show];
        }
    }
}

- (IBAction)makeAccount:(id)sender {
    [self.view layoutIfNeeded];
    
    [_passwordField setReturnKeyType:UIReturnKeyNext];
    originalY = _loginButton.center.y;
    originalLoginBg = _loginBgView.layer.frame;
    
    [_loginButton setTitle:@"Back" forState:UIControlStateNormal];
    [_loginButton setEnabled:NO];
    [_accountButton setHidden:YES];
    [_signupButton setHidden:NO];
    
    [_usernameField setPlaceholder:@"Desired Username"];

    [UIView animateWithDuration:0.75f animations:^{
        [_loginButton setAlpha:.25];
        
        _loginBgToLogoConstraint.constant = 8;
        _usernameToLogoConstraint.constant = 28;
        _loginBgHeightConstraint.constant = 205;
        _loginToAccountConstraint.constant = 360;
        _passwordToLogoConstraint.constant = 73;
        _confirmPasswordToLogoConstraint.constant = 118;
        _emailToLogoConstraint.constant = 163;
         
        [_usernameField setAlpha:1.0];
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:.25 animations:^{
        [_rememberMeLabel setAlpha:0.0];
        [_rememberMeSwitch setAlpha:0.0];
    }];
    
    [UIView animateWithDuration:.5 delay:.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_confirmPasswordField setAlpha:1.0];
    } completion:^(BOOL finished){
        [_loginButton setEnabled:YES];
    }];
    
    [UIView animateWithDuration:.5 delay:.35 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_emailField setAlpha:1.0];
    } completion:^(BOOL finished){
        [_loginButton setEnabled:YES];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"Login"]){
        GymQViewController *vc = (GymQViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        vc.user = currentUser;
    }
}

@end
