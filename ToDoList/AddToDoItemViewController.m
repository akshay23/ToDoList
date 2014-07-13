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
    
    // Create and add the 'Done' button to navigation bar
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(addItem:)];
    [self.navigationItem setRightBarButtonItem:done];
    
    // Set view colour
    [self.view setBackgroundColor:self.delegate.tableView.backgroundColor];

}

- (void)viewDidAppear:(BOOL)animated
{
    // Set focus on text field
    [self.itemTxtField becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.itemTxtField.text = @"";
    [self.itemTxtField resignFirstResponder];
    
    [super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)addItem:(id)sender
{
    if (![GlobalData stringIsNilOrEmpty:self.itemTxtField.text])
    {
        ToDoItem *listItem = [[ToDoItem alloc] initWithNameAndCompleted:self.itemTxtField.text isCompleted:NO];
        [self.delegate addToArray:listItem];
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
