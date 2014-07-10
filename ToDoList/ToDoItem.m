//
//  ToDoItem.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem

- (id)initWithNameAndCompleted:(NSString *)name isCompleted:(BOOL)completedd
{
    self.itemName = name;
    self.completed = completedd;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.itemName = [coder decodeObjectForKey:@"ItemName"];
        self.completed = [coder decodeBoolForKey:@"ItemCompleted"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.itemName forKey:@"ItemName"];
    [coder encodeBool:self.completed forKey:@"ItemCompleted"];
}

@end
