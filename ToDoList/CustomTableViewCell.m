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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (self.item.completed)
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_full.png"];
    }
    else
    {
        self.tickImage = [UIImage imageNamed: @"checkbox_empty.png"];
    }
    
    self.isChecked = self.item.completed;
    
    [self.tickBoxImage setImage:self.tickImage];
}

@end
