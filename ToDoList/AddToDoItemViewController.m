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
    
    // Create and add the 'Save' button to navigation bar
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveItem:)];
    [self.navigationItem setRightBarButtonItem:save];
    
    // Make the item name textbox border a little thicker
    [self.itemTxtField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.itemTxtField.layer setBorderWidth:2.0];
    
    // Make the border look like the item name textfield
    [self.itemNotesField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.itemNotesField.layer setBorderWidth:2.0];
    
    // The rounded corner part, where you specify the view's corner radius
    self.itemNotesField.layer.cornerRadius = 5;
    self.itemNotesField.clipsToBounds = YES;
    
    // Set view colour
    [self.view setBackgroundColor:self.delegate.tableView.backgroundColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // If in add mode, then set focus on txt field
    if (self.mode == Add)
    {
        // Set focus on text field
        [self.itemTxtField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If in edit mode, then display text in txtbox
    if (self.mode == Edit)
    {
        self.itemTxtField.text = self.toDoItem.itemName;
        self.itemNotesField.text = self.toDoItem.notes;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.itemTxtField.text = @"";
    self.itemNotesField.text = @"";
    [self.itemTxtField resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// Either add new item or save changes to existing item
- (void)saveItem:(id)sender
{
    if (![GlobalData stringIsNilOrEmpty:self.itemTxtField.text])
    {
        if (self.mode == Add)
        {
            self.toDoItem = [[ToDoItem alloc] initWithNameNotesAndCompleted:self.itemTxtField.text notes:self.itemNotesField.text isCompleted:NO];
            [self.delegate addToArray:self.toDoItem];
        }
        else
        {
            self.toDoItem.itemName = self.itemTxtField.text;
            self.toDoItem.notes = self.itemNotesField.text;
        }

        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate.delegate saveLists];
        [self.delegate.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Allows user to shake phone to go back to previous view
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Allows user to tap anywhere on the background/view to dismiss keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.itemNotesField isFirstResponder] && [touch view] != self.itemNotesField)
    {
        [self.itemNotesField resignFirstResponder];
    }
    else if ([self.itemTxtField isFirstResponder] && [touch view] != self.itemTxtField)
    {
        [self.itemTxtField resignFirstResponder];
    }

    [super touchesBegan:touches withEvent:event];
}

@end
