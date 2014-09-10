//
//  ToDoItem.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject <NSCoding>

@property BOOL completed;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *notes;
@property (readonly) NSDate *creationDate;

- (id)initWithNameAndCompleted:(NSString *)name isCompleted:(BOOL)completedd;
- (id)initWithNameNotesAndCompleted:(NSString *)name notes:(NSString *)theNotes isCompleted:(BOOL)completedd;

@end
