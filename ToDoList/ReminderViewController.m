//
//  ReminderViewController.m
//  MyToDoLists
//
//  Created by Akshay Bharath on 9/18/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ReminderViewController.h"

@implementation ReminderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize event store
    if (![GlobalData getInstance].eventStore)
    {
        // Instantiate new event store instance
        [GlobalData getInstance].eventStore = [[EKEventStore alloc] init];
        
        [[GlobalData getInstance].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted)
            {
                self.accessGranted = NO;
                NSLog(@"eventStore instantiated and access NOT granted");
            }
            else
            {
                self.accessGranted = YES;
                NSLog(@"eventStore instantiated and access granted");
            }
        }];
    }
    
    // Create and add the 'Set' button to navigation bar
    UIBarButtonItem *set = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setItem:)];
    [self.navigationItem setRightBarButtonItem:set];
    
    // Set border for date picker
    [self.datePicker.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.datePicker.layer setBorderWidth:2.0];
    
    // Round the corners of the button
    self.btnDeleteReminder.layer.cornerRadius = 5;
    self.btnDeleteReminder.clipsToBounds = YES;
    
    // Add custom left navi button
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:left];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupInitialStates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!self.toDoItem.reminderDate)
    {
        [self.datePicker setDate:[NSDate date]];
        [self.txtMessage setText:@"There is NO reminder set for this to-do item."];
    }
    
    [super viewDidDisappear:animated];
}

// Show message in text view based on to-do item's reminder date
- (void)setupInitialStates
{
    [self.datePicker setLocale:[NSLocale currentLocale]];

    if (!self.accessGranted)      // Access to calendar was not granted
    {
        [self.txtMessage setTextColor:[UIColor redColor]];
        [self.txtMessage setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.txtMessage setText:@"In order to set reminders, we require access to your calendar!"];
        [self.btnDeleteReminder setHidden:YES];
        
        [self.navigationController.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    else
    {
        [self.txtMessage setTextColor:[UIColor purpleColor]];
        [self.txtMessage setFont:[UIFont boldSystemFontOfSize:17.0f]];

        if (self.toDoItem.reminderDate && [self.toDoItem.reminderDate compare:[NSDate date]] == NSOrderedDescending)
        {
            [self setTextViewMessage];
            [self.datePicker setDate:self.toDoItem.reminderDate];
            [self.btnDeleteReminder setHidden:NO];
        }
        else
        {
            // Existing reminder is old. Lets delete it.
            if (self.toDoItem.reminderDate)
            {
                [self.toDoItem deleteReminder];
                self.toDoItem.reminderDate = nil;
                self.toDoItem.reminderId = nil;
            }
            
            [self.datePicker setDate:[NSDate date]];
            [self.txtMessage setText:@"There is NO reminder set for this to-do item."];
            [self.btnDeleteReminder setHidden:YES];
        }
        
        [self.navigationController.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

// Set reminder (but dont actually create in calendar)
- (void)setItem:(id)sender
{
    if (self.toDoItem.reminderDate && ([self.datePicker.date compare:self.toDoItem.reminderDate] != NSOrderedSame) && ([self.datePicker.date compare:[NSDate date]] == NSOrderedDescending))
    {
        self.toDoItem.reminderDate = self.datePicker.date;
        self.toDoItem.reminderChanged = YES;
        [self setTextViewMessage];
    }
    else if ((self.toDoItem.reminderDate && ([self.datePicker.date compare:[NSDate date]] == NSOrderedAscending)) || (!self.toDoItem.reminderDate && ([self.datePicker.date compare:[NSDate date]] == NSOrderedAscending)))
    {
        [self.txtMessage setTextColor:[UIColor redColor]];
        [self.txtMessage setText:@"The reminder has to be for some time in the future!"];
        [self.delegate setTempDate:nil];
    }
    else if (!self.toDoItem.reminderDate && ([self.datePicker.date compare:[NSDate date]] == NSOrderedDescending))
    {
        self.toDoItem.reminderDate = self.datePicker.date;
        self.toDoItem.reminderChanged = YES;
        [self setTextViewMessage];
    }
}

// Pops controller with custom animation
- (void)goBack:(id)sender
{
    [self doCustomViewTransition];
    
}

// Format the reminder date into MM-dd-yyyy at HH:mm a format
- (void)setTextViewMessage
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyy 'at' HH:mm a"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.toDoItem.reminderDate];
    NSString *formatted = [[NSString alloc] initWithFormat:@"Reminder for this to-do item is set for %@", formattedDateString];
    [self.txtMessage setTextColor:[UIColor purpleColor]];
    [self.txtMessage setText:formatted];
    [self.btnDeleteReminder setHidden:NO];
    [self.delegate setTempDate:self.toDoItem.reminderDate];
}

// Delete reminder from calendar (if possible)
- (IBAction)deleteReminder:(id)sender
{
    if ([self.toDoItem deleteReminder])
    {
        self.toDoItem.reminderDate = nil;
        self.toDoItem.reminderId = nil;
        [self setupInitialStates];
        [self.btnDeleteReminder setHidden:YES];
    }
    else
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not delete reminder!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }
}

// Allows user to shake phone to go back to previous view
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self doCustomViewTransition];
    }
}

// Custom transition
- (void)doCustomViewTransition
{
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                     }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
