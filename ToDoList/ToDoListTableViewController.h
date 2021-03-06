//
//  ToDoListTableViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateListViewController.h"
#import "ListItem.h"
#import "ToDoItem.h"
#import "AddToDoItemViewController.h"
#import "CustomTableViewCell.h"
#import "BVReorderTableView.h"
#import <Parse/Parse.h>

@class AddToDoItemViewController;
@class CreateListViewController;

@interface ToDoListTableViewController : UITableViewController

@property (strong, nonatomic) ListItem *list;
@property (strong, nonatomic) CreateListViewController *delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AddToDoItemViewController *addToDoItemVC;

- (void)initializeView;
- (void)saveItem:(ToDoItem *)item;

@end
