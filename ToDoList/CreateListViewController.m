//
//  CreateListViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 7/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CreateListViewController.h"

@interface CreateListViewController ()

@end

@implementation CreateListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addList:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"List Name" message:@"Please enter list name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *listName = [[alertView textFieldAtIndex:0] text];
        ListItem *item = [[ListItem alloc] initWithName:listName];
        
        if (self.lists == nil)
        {
            self.lists = [[NSMutableArray alloc] init];
        }
        
        [self.lists addObject:item];
        ToDoListTableViewController *todoList = [[ToDoListTableViewController alloc] initWithDelegateAndListItem:item theDelegate:self];
        [self.navigationController pushViewController:todoList animated:YES];
    }
}

- (IBAction)editList:(id)sender
{
}

@end
