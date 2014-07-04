//
//  ListItem.m
//  ToDoList
//
//  Created by Akshay Bharath on 7/4/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ListItem.h"

@implementation ListItem

- (id)initWithName:(NSString *)name
{
    self.name = name;
    self.toDoItems = [[NSMutableArray alloc] init];
    
    return self;
}

@end
