//
//  CustomTableViewCell.h
//  MyToDoLists
//
//  Created by Akshay Bharath on 8/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface CustomTableViewCell : UITableViewCell
@property BOOL isChecked;
@property (strong, nonatomic) ToDoItem *item;
@property (strong, nonatomic) UIImage *tickImage;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;
@property (strong, nonatomic) IBOutlet UIImageView *tickBoxImage;

@end
