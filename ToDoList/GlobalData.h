//
//  GlobalData.h
//  ToDoList
//
//  Created by Akshay Bharath on 7/9/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

// Used for global objects
@interface GlobalData : NSObject
{
    UIStoryboard *mainStoryboard;
}

@property (nonatomic, strong) UIStoryboard *mainStoryboard;
@property (strong,  nonatomic) EKEventStore *eventStore;

// Singleton method
+ (GlobalData *)getInstance;

// Check if string is null or empty
+ (BOOL)stringIsNilOrEmpty:(NSString*)aString;

@end
