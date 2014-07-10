//
//  ToDoListTableViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GlobalData.h"
#import "CreateListViewController.h"
#import "ListItem.h"

@class CreateListViewController;

@interface ToDoListTableViewController : UITableViewController

@property ListItem *list;

- (id)initWithDelegateAndListItem:(ListItem *)list theDelegate:(CreateListViewController *)delegate;
@end
