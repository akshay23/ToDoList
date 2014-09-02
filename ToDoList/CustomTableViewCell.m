//
//  CustomTableViewCell.m
//  MyToDoLists
//
//  Created by Akshay Bharath on 8/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize isChecked, item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"Cell init");
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    
    if (isChecked)
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_full.png"];
    }
    else
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_empty.png"];
    }
    
    [self.tickBoxImage setImage:self.tickImage];
    
    NSLog(@"I am awake");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected) return;

    // Configure the view for the selected state
    if (isChecked)
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_empty.png"];
        isChecked = NO;
    }
    else
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_full.png"];
        isChecked = YES;
    }
    
    [self.tickBoxImage setImage:self.tickImage];
}

@end
