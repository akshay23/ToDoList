//
//  ToDoItem.h
//  ToDoList
//
//  Created by Akshay Bharath on 6/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject <NSCoding>

@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

- (id)initWithNameAndCompleted:(NSString *)name isCompleted:(BOOL)completedd;

@end
