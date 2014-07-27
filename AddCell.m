//
//  AddCell.m
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "AddCell.h"

@implementation AddCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
