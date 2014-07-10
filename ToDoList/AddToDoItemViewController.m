//
//  AddToDoItemViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "AddToDoItemViewController.h"

@interface AddToDoItemViewController ()

@end

@implementation AddToDoItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set focus on text field
    [self.itemTxtField becomeFirstResponder];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(addItem:)];
    
    [self.navigationItem setRightBarButtonItem:add];

}

- (void)addItem:(id)sender
{
    if (![GlobalData stringIsNilOrEmpty:self.itemTxtField.text])
    {
        ToDoItem *listItem = [[ToDoItem alloc] initWithNameAndCompleted:self.itemTxtField.text isCompleted:NO];
        [self.delegate addToArray:listItem];
        [self.delegate saveList];
        [self.delegate.tableView reloadData];
        
        self.itemTxtField.text = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
