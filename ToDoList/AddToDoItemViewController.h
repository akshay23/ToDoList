//
//  AddToDoItemViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"
#import "ToDoListTableViewController.h"

@class ToDoListTableViewController;

@interface AddToDoItemViewController : UIViewController

typedef NS_ENUM(NSInteger, SaveMode)
{
    Add = 1,
    Edit = 2
};

@property NSInteger mode;
@property (strong, nonatomic) ToDoItem *toDoItem;
@property (strong, nonatomic) ToDoListTableViewController *delegate;
@property (strong, nonatomic) IBOutlet UITextField *itemTxtField;

@end