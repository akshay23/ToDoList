//
//  ToDoItem.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem

- (id)init
{
    self.itemId = [[NSUUID UUID] UUIDString];
    self.itemName = @"";
    self.completed = NO;
    self.notes = @"";
    self.itemImage = nil;
    self.reminderDate = nil;
    self.reminderChanged = NO;
    self.order = 0;
    
    return self;
}

- (id)initWithNameNotesAndCompleted:(NSString *)name notes:(NSString *)theNotes image:(UIImage *)theImage isCompleted:(BOOL)completedd
{
    self.itemId = [[NSUUID UUID] UUIDString];
    self.itemName = name;
    self.notes = theNotes;
    self.completed = completedd;
    self.itemImage = [NSData dataWithData:UIImagePNGRepresentation(theImage)];
    self.reminderDate = nil;
    self.reminderChanged = NO;
    self.order = 0;

    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.itemId = [coder decodeObjectForKey:@"ItemId"];
        self.itemName = [coder decodeObjectForKey:@"ItemName"];
        self.completed = [coder decodeBoolForKey:@"ItemCompleted"];
        self.notes = [coder decodeObjectForKey:@"ItemNotes"];
        self.itemImage = [coder decodeObjectForKey:@"ItemImage"];
        self.reminderId = [coder decodeObjectForKey:@"ItemReminderID"];
        self.reminderChanged = [coder decodeBoolForKey:@"ItemReminderChanged"];
        self.reminderDate = [coder decodeObjectForKey:@"ItemReminderDate"];
        self.order = [coder decodeIntegerForKey:@"ItemOrder"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.itemId forKey:@"ItemId"];
    [coder encodeObject:self.itemName forKey:@"ItemName"];
    [coder encodeBool:self.completed forKey:@"ItemCompleted"];
    [coder encodeObject:self.notes forKey:@"ItemNotes"];
    [coder encodeObject:self.itemImage forKey:@"ItemImage"];
    [coder encodeObject:self.reminderId forKey:@"ItemReminderID"];
    [coder encodeObject:self.reminderDate forKey:@"ItemReminderDate"];
    [coder encodeBool:self.reminderChanged forKey:@"ItemReminderChanged"];
    [coder encodeInteger:self.order forKey:@"ItemOrder"];
}

// Create the actual reminder
// Return NO if we can't create
- (BOOL)createReminder
{
    self.reminderChanged = NO;

    if (self.reminderId)
    {
        if ([self deleteReminder])
        {
            self.reminderId = nil;
        }
    }
    
    if (self.reminderDate)
    {
        EKEventStore *myEventStore = [GlobalData getInstance].eventStore;
        EKEvent *reminder = [EKEvent eventWithEventStore:myEventStore];
        reminder.title  = [NSString stringWithFormat:@"Reminder: %@", self.itemName];
        reminder.calendar = [myEventStore defaultCalendarForNewEvents];
        reminder.startDate = self.reminderDate;
        reminder.endDate = self.reminderDate;
        EKAlarm *alrm = [EKAlarm alarmWithAbsoluteDate:self.reminderDate];
        [reminder addAlarm:alrm];
        NSError *err;
        
        [myEventStore saveEvent:reminder span:EKSpanThisEvent commit:YES error:&err];

        if (err)
        {
            self.reminderDate = nil;
            NSLog(@"Error when trying to save event %@:", [err localizedDescription]);
            return NO;
        }
        
        self.reminderId = [[NSString alloc] initWithFormat:@"%@", reminder.eventIdentifier];
        NSLog(@"Event created successfully!");
    }

    return YES;
}

// Delete event from calendar (if exists)
// Return NO if we couldn't delete
- (BOOL)deleteReminder
{
    if (self.reminderId)
    {
        EKEventStore *myEventStore = [GlobalData getInstance].eventStore;
        EKEvent *reminder = [myEventStore eventWithIdentifier:self.reminderId];
        NSError *err;
        BOOL success = [myEventStore removeEvent:reminder span:EKSpanThisEvent error:&err];
        NSLog( @"Reminder deleted success value: %d", success);
        
        return success;
    }
    
    return YES;
}

@end
