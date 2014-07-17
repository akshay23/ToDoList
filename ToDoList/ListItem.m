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
    
    return [self init];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"ItemName"];
        self.toDoItems = [coder decodeObjectForKey:@"ToDoItems"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"ItemName"];
    [coder encodeObject:self.toDoItems forKey:@"ToDoItems"];
}

@end
