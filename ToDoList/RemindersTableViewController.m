//
//  RemindersTableViewController.m
//  MyToDoLists
//
//  Created by Akshay Bharath on 9/18/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "RemindersTableViewController.h"

@implementation RemindersTableViewController

- (void)viewDidLoad
{
    // Initialize event store
    if (![GlobalData getInstance].eventStore)
    {
        // Instantiate new event store instance
        [GlobalData getInstance].eventStore = [[EKEventStore alloc] init];
        
        [[GlobalData getInstance].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            // handle access here
        }];
        
        NSLog(@"eventStore instantiated and access granted");
    }
    
//    EKEvent *event = [EKEvent eventWithEventStore:[GlobalData getInstance].eventStore];
//    event.title  = [NSString stringWithFormat:@"%@%@", @"Reminder: ", self.itemTxtField.text];
//    
//    // Reminder is set for 1 hr from now
//    NSDate *date = [NSDate date];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setHour:1];
//    NSDate *startDte= [calendar dateByAddingComponents:components toDate:date options:0];
//    event.startDate = startDte;
//    
//    // Save to event store
//    [[GlobalData getInstance].eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:NULL];
}

@end
