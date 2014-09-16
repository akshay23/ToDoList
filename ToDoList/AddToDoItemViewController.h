//
//  AddToDoItemViewController.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"
#import "ToDoListTableViewController.h"

@class ToDoListTableViewController;

@interface AddToDoItemViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

typedef NS_ENUM(NSInteger, SaveMode)
{
    Add = 1,
    Edit = 2
};

@property NSInteger mode;
@property (strong, nonatomic) ToDoItem *toDoItem;
@property (strong, nonatomic) ToDoListTableViewController *delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UITextView *itemTxtField;
@property (strong, nonatomic) IBOutlet UITextView *itemNotesField;
@property (strong, nonatomic) IBOutlet UILabel *lblPicture;
@property (strong, nonatomic) IBOutlet UILabel *lblImgOptional;
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;

- (IBAction)takePicture:(id)sender;
- (void)clearTemps;
@end