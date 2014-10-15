//
//  MyStationsViewController.m
//  GymQ
//
//  Created by Dominic Ong on 10/11/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "MyStationsViewController.h"
#import "WorkoutStationViewController.h"
#import "StationCell.h"

@interface MyStationsViewController ()

@property (strong, nonatomic) UIActionSheet *action;
@property (strong, nonatomic) NSMutableArray *stations;
@end

@implementation MyStationsViewController{
    NSInteger selectedRow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _stations = _user[@"stations"];
    NSSortDescriptor *descrip = [NSSortDescriptor sortDescriptorWithKey:@"lastVisit" ascending:YES];
    [_stations sortedArrayUsingDescriptors:@[descrip]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_user[@"stations"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StationCell *cell = (StationCell *)[tableView dequeueReusableCellWithIdentifier:@"Station" forIndexPath:indexPath];
    NSDictionary *station = [_user[@"stations"] objectAtIndex:indexPath.row];
    [cell.nameLabel setText: [station objectForKey:@"stationName"]];
    [cell.numWorkoutsLabel setText:[NSString stringWithFormat:@"%lu workouts",(unsigned long)[[station objectForKey:@"workouts"] count]]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"ShowWorkouts" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        selectedRow = indexPath.row;
        _action = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@?",[[_user[@"stations"] objectAtIndex:selectedRow] objectForKey:@"stationName"]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        [_action showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == _action.destructiveButtonIndex){
        NSLog(@"Deleting");
        [_user[@"stations"] removeObjectAtIndex:selectedRow];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [_user saveInBackground];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"ShowWorkouts"]){
        WorkoutStationViewController *vc = (WorkoutStationViewController *)[segue destinationViewController];
        NSDictionary *station = [_user[@"stations"] objectAtIndex:selectedRow];
        vc.stationCode = [station objectForKey:@"stationName"];
        vc.station = station;
        vc.user = _user;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
