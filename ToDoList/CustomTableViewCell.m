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
    if (self.selected == selected) return;

    // Configure the view for the selected state
    UIImage *image = nil;
    if (isChecked)
    {
        image = [UIImage imageNamed: @"checkbox_empty.png"];
        isChecked = NO;
    }
    else
    {
        image = [UIImage imageNamed: @"checkbox_full.png"];
        isChecked = YES;
    }
    
    [self.tickBoxImage setImage:image];
}

@end
