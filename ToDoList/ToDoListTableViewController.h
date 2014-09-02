//
//  ToDoListTableViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CreateListViewController.h"
#import "ListItem.h"
#import "ToDoItem.h"
#import "AddToDoItemViewController.h"
#import "CustomTableViewCell.h"

@class AddToDoItemViewController;
@class CreateListViewController;

@interface ToDoListTableViewController : UITableViewController

@property (strong, nonatomic) ListItem *list;
@property (strong, nonatomic) CreateListViewController *delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)initializeView;
- (void)addToArray:(ToDoItem *)item;

@end
