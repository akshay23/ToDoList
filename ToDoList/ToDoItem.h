//
//  ToDoItem.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "GlobalData.h"

@interface ToDoItem : NSObject <NSCoding>

@property BOOL completed;
@property BOOL reminderChanged;
@property NSInteger order;
@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) NSData *itemImage;
@property (readonly) NSDate *creationDate;
@property (strong, nonatomic) NSDate *reminderDate;
@property (strong, nonatomic) NSString *reminderId;

- (id)init;
- (id)initWithNameNotesAndCompleted:(NSString *)name notes:(NSString *)theNotes image:(UIImage *)theImage isCompleted:(BOOL)completedd;

- (BOOL)createReminder;
- (BOOL)deleteReminder;

@end
