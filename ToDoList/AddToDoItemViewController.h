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

@interface AddToDoItemViewController : UIViewController

@property ToDoItem *toDoItem;
@property (nonatomic, strong)  ToDoListTableViewController *delegate;
@property (weak, nonatomic) IBOutlet UITextField *itemTxtField;

@end
