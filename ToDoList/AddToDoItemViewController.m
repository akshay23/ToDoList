//
//  AddToDoItemViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "AddToDoItemViewController.h"

@interface AddToDoItemViewController ()

@property NSString *tmpItemName;
@property NSString *tmpNotes;

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
    
    // The rounded corner part, where you specify the view's corner radius
    self.itemTxtField.layer.cornerRadius = 5;
    self.itemTxtField.clipsToBounds = YES;
    
    // Make the border look like the item name textfield
    [self.itemNotesField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.itemNotesField.layer setBorderWidth:2.0];
    
    // The rounded corner part, where you specify the view's corner radius
    self.itemNotesField.layer.cornerRadius = 5;
    self.itemNotesField.clipsToBounds = YES;
    
    // Set view colour
    [self.view setBackgroundColor:self.delegate.tableView.backgroundColor];
    
    // Crate tap recognizer to detect taps on scrollview
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    // Add tap recognizer to scrollview, then
    [self.mainScrollView addGestureRecognizer:tapGesture];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If in edit mode, then display text in txtbox
    if (self.mode == Edit)
    {
        self.itemTxtField.text = self.toDoItem.itemName;
        self.itemNotesField.text = self.toDoItem.notes;

        if (self.toDoItem.itemImage)
        {
            [self.itemImage setHidden:NO];
            [self.itemImage setImage:self.toDoItem.itemImage];
            [self.itemImage setFrame:CGRectMake(self.itemImage.frame.origin.x, self.itemImage.frame.origin.y, 280, 200)];
        }
    }
    else
    {
        self.itemNotesField.text = self.tmpNotes;
        self.itemTxtField.text = self.tmpItemName;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.itemTxtField resignFirstResponder];
    [self.itemNotesField resignFirstResponder];
    [self.itemImage setImage:NULL];
}

- (void)viewDidLayoutSubviews
{
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.bounds.size.width, self.mainScrollView.bounds.size.height)];
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
            self.toDoItem = [[ToDoItem alloc] initWithNameNotesAndCompleted:self.itemTxtField.text notes:self.itemNotesField.text image:self.itemImage.image isCompleted:NO];
            [self.delegate addToArray:self.toDoItem];
        }
        else
        {
            self.toDoItem.itemName = self.itemTxtField.text;
            self.toDoItem.notes = self.itemNotesField.text;
            self.toDoItem.itemImage = self.itemImage.image;
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
- (void)hideKeyboard
{
    [self.itemNotesField resignFirstResponder];
    [self.itemTxtField resignFirstResponder];
}

// Clear the temp variables
- (void)clearTemps
{
    self.tmpNotes = @"";
    self.tmpItemName = @"";
}

// Method that gets called when camera button is tapped
- (IBAction)takePicture:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Save all text from text boxes
        self.tmpItemName = self.itemTxtField.text;
        self.tmpNotes = self.itemNotesField.text;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.itemImage.image = chosenImage;
    self.itemImage.hidden = NO;
    
    self.toDoItem.itemImage = self.itemImage.image;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
