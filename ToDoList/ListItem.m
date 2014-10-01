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
    self.listId = [[NSUUID UUID] UUIDString];
    self.name = name;
    self.toDoItems = [[NSMutableArray alloc] init];
    self.order = 0;
    
    return [self init];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.listId = [coder decodeObjectForKey:@"ItemId"];
        self.name = [coder decodeObjectForKey:@"ItemName"];
        self.toDoItems = [coder decodeObjectForKey:@"ToDoItems"];
        self.order = [coder decodeIntegerForKey:@"ItemOrder"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.listId forKey:@"ItemId"];
    [coder encodeObject:self.name forKey:@"ItemName"];
    [coder encodeObject:self.toDoItems forKey:@"ToDoItems"];
    [coder encodeInteger:self.order forKey:@"ItemOrder"];
}

- (void)checkId
{
    if ([GlobalData stringIsNilOrEmpty:self.listId])
    {
        self.listId = [[NSUUID UUID] UUIDString];
    }
}

@end
