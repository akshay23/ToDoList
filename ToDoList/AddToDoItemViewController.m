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
@property NSDate *tmpReminder;
@property NSData *tmpImage;

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
    
    // Border thing again
    [self.itemImage.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.itemImage.layer setBorderWidth:2.0];
    
    // Set view colour
    [self.view setBackgroundColor:self.delegate.tableView.backgroundColor];
    
    // Crate tap recognizer to detect taps on scrollview
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    // Add tap recognizer to scrollview, then
    [self.mainScrollView addGestureRecognizer:tapGesture];
    
    // Round the corners of the reminders and reset buttons
    self.btnReset.layer.cornerRadius = 5;
    self.btnReminders.layer.cornerRadius = 5;
    self.btnReset.clipsToBounds = YES;
    self.btnReminders.clipsToBounds = YES;
    
    // Set camera button icon
    [self.btnCamera setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [self.btnCamera setImage:[UIImage imageNamed:@"camera_icon_press.png"] forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If in edit mode, then display text in txtbox
    if (self.mode == Edit)
    {
        self.itemTxtField.text = self.toDoItem.itemName;
        self.itemNotesField.text = self.toDoItem.notes;
        
        if (![self.tmpNotes  isEqual: @""])
        {
            self.itemNotesField.text = self.tmpNotes;
        }
        
        if (![self.tmpItemName  isEqual: @""])
        {
            self.itemTxtField.text = self.tmpItemName;
        }

        if (self.toDoItem.itemImage)
        {
            [self.itemImage setImage:[UIImage imageWithData:self.toDoItem.itemImage]];
        }
        
        if (self.tmpImage)
        {
            [self.itemImage setImage:[UIImage imageWithData:self.tmpImage]];
        }
        else if (!self.tmpImage && !self.toDoItem.itemImage)
        {
            [self.itemImage setImage:nil];
        }
        
        // Reminder date is in the past, so delete it
        if ([self.toDoItem.reminderDate compare:[NSDate date]] == NSOrderedAscending)
        {
            [self.toDoItem deleteReminder];
            self.toDoItem.reminderDate = nil;
            self.toDoItem.reminderId = nil;
        }
    }
    else
    {
        if (!self.toDoItem)
        {
            self.toDoItem = [[ToDoItem alloc] init];
        }

        self.itemNotesField.text = self.tmpNotes;
        self.itemTxtField.text = self.tmpItemName;
        
        if (self.tmpImage)
        {
           self.itemImage.image = [UIImage imageWithData:self.tmpImage];
        }

        if (self.tmpReminder)
        {
            self.toDoItem.reminderDate = self.tmpReminder;
        }
    }
    
    // Set button text if reminder date is not nil
    if (self.toDoItem.reminderDate)
    {
        [self.btnReminders setTitle:@"Edit Reminder" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnReminders setTitle:@"Add Reminder" forState:UIControlStateNormal];
    }
    
    // Scroll to top
    [self.mainScrollView setContentOffset:CGPointMake(0, -self.mainScrollView.contentInset.top) animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.itemTxtField resignFirstResponder];
    [self.itemNotesField resignFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.bounds.size.width, self.mainScrollView.bounds.size.height + 50)];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Either add new item or save changes to existing item
- (void)saveItem:(id)sender
{
    if (![GlobalData stringIsNilOrEmpty:self.itemTxtField.text])
    {
        if (self.mode == Add)
        {
            if (!self.toDoItem)
            {
                self.toDoItem = [[ToDoItem alloc] initWithNameNotesAndCompleted:self.itemTxtField.text notes:self.itemNotesField.text image:self.itemImage.image isCompleted:NO];
            }
            else
            {
                self.toDoItem.itemName = self.itemTxtField.text;
                self.toDoItem.itemImage = [NSData dataWithData:UIImagePNGRepresentation(self.itemImage.image)];
                self.toDoItem.notes = self.itemNotesField.text;
            }
        }
        else
        {
            self.toDoItem.itemName = self.itemTxtField.text;
            self.toDoItem.notes = self.itemNotesField.text;
            self.toDoItem.itemImage = [NSData dataWithData:UIImagePNGRepresentation(self.itemImage.image)];
        }
        
        [self saveReminder];
        
        [self.delegate saveItem:self.toDoItem];
        
        if (self.mode == Add)
        {
            self.toDoItem = nil;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    self.tmpReminder = nil;
    self.tmpImage = nil;
    self.itemImage.image = nil;
}

// Set the temp date
- (void)setTempDate:(NSDate *)date
{
    self.tmpReminder = date;
}

// Method that gets called when camera button is tapped
- (IBAction)takePicture:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Picture" message:@"Please pick where to import from" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera", @"Photo Library", nil];
    [alert show];
}

// Redirect based on which button in alertview was pressed
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"User wants to import from Camera");
        [self getPicFromCamera];
    }
    else if (buttonIndex == 2)
    {
        NSLog(@"User wants to import from Photo Library");
        [self getPicFromPhotoLibrary];
    }
}

// Use camera to take picture
- (void)getPicFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
        self.tmpReminder = self.toDoItem.reminderDate;

        [self presentViewController:picker animated:YES completion:nil];
    }
}

// Get picture from photo library
- (void)getPicFromPhotoLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    // Save all text from text boxes
    self.tmpItemName = self.itemTxtField.text;
    self.tmpNotes = self.itemNotesField.text;
    self.tmpReminder = self.toDoItem.reminderDate;

    [self presentViewController:picker animated:YES completion:nil];
}

// Reset all fields
- (IBAction)resetFields:(id)sender
{
    self.itemTxtField.text = @"";
    self.itemNotesField.text = @"";
    self.itemImage.image = nil;
}

// Show the ReminderVC
- (IBAction)addReminder:(id)sender
{
    if (!self.reminderVC)
    {
        self.reminderVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"reminderVC"];
        self.reminderVC.delegate = self;
    }

    self.reminderVC.toDoItem = self.toDoItem;

    // Save all text from text boxes
    self.tmpItemName = self.itemTxtField.text;
    self.tmpNotes = self.itemNotesField.text;
    self.tmpImage = [NSData dataWithData:UIImagePNGRepresentation(self.itemImage.image)];
    
    // Custom view transition
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:self.reminderVC animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
    
}

// Tell todo item to save reminder if changed
- (void)saveReminder
{
    if (self.toDoItem.reminderChanged)
    {
        if (![self.toDoItem createReminder])    // Could not create reminder
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create reminder!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [myAlertView show];
        }
    }
}

// User finished picking image from image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.itemImage.image = chosenImage;
    self.itemImage.hidden = NO;
    self.tmpImage = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// User cancelled image pick process
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
