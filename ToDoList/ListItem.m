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
    
    return [self init];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.listId = [coder decodeObjectForKey:@"ItemId"];
        self.name = [coder decodeObjectForKey:@"ItemName"];
        self.toDoItems = [coder decodeObjectForKey:@"ToDoItems"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.listId forKey:@"ItemId"];
    [coder encodeObject:self.name forKey:@"ItemName"];
    [coder encodeObject:self.toDoItems forKey:@"ToDoItems"];
}

- (void)checkId
{
    if ([GlobalData stringIsNilOrEmpty:self.listId])
    {
        self.listId = [[NSUUID UUID] UUIDString];
    }
}

@end
