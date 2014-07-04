//
//  ListItem.h
//  ToDoList
//
//  Created by Akshay Bharath on 7/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToDoItem.h"

@interface ListItem : NSObject

@property NSString *name;
@property NSMutableArray *toDoItems;

- (id)initWithName:(NSString *)name;

@end
