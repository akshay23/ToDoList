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

@property ListItem *item;

- (id)initWithDelegateAndTitle:(NSString *)title theDelegate:(CreateListViewController *)delegate;
- (id)initWithDelegateAndListItem:(ListItem *)list theDelegate:(CreateListViewController *)delegate;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@end
