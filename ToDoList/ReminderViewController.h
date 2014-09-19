//
//  ReminderViewController.h
//  MyToDoLists
//
//  Created by Akshay Bharath on 9/18/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalData.h"
#import "AddToDoItemViewController.h"

@class AddToDoItemViewController;

@interface ReminderViewController : UIViewController

@property BOOL accessGranted;
@property (strong, nonatomic) ToDoItem *toDoItem;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UITextView *txtMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteReminder;

- (IBAction)deleteReminder:(id)sender;

@end
