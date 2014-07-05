//
//  CreateListViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 7/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoListTableViewController.h"
#import "ListItem.h"

@interface CreateListViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *lists;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addB;
@property (weak, nonatomic) IBOutlet UINavigationItem *editB;
@property (strong, nonatomic) NSMutableArray *myLists;

- (IBAction)addList:(id)sender;
- (IBAction)editList:(id)sender;

@end
