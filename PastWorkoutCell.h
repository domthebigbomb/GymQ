//
//  PastWorkoutCell.h
//  GymQ
//
//  Created by Dominic Ong on 7/26/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastWorkoutCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UILabel *setsRepsLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;

@end
