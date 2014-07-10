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

@class CreateListViewController;

@interface ToDoListTableViewController : UITableViewController

@property (strong, nonatomic) ListItem *list;

- (id)initWithDelegateAndListItem:(ListItem *)actualList theDelegate:(CreateListViewController *)delegate;
- (void)addToArray:(ToDoItem *)item;
- (void)saveList;

@end
