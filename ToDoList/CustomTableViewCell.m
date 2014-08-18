//
//  CustomTableViewCell.m
//  MyToDoLists
//
//  Created by Akshay Bharath on 8/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize isChecked;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIImage *image = nil;
    if (isChecked)
    {
        image = [UIImage imageNamed: @"checkbox_empty.png"];
        isChecked = false;
    }
    else
    {
        image = [UIImage imageNamed: @"checkbox_full.png"];
        isChecked = true;
    }
    
    [self.tickBoxImage setImage:image];
}

@end
