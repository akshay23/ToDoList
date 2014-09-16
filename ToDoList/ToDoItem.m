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
    self.notes = @"";
    self.itemImage = NULL;
    
    return self;
}

- (id)initWithNameNotesAndCompleted:(NSString *)name notes:(NSString *)theNotes image:(UIImage *)theImage isCompleted:(BOOL)completedd
{
    self.itemName = name;
    self.notes = theNotes;
    self.completed = completedd;
    self.itemImage = theImage;

    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.itemName = [coder decodeObjectForKey:@"ItemName"];
        self.completed = [coder decodeBoolForKey:@"ItemCompleted"];
        self.notes = [coder decodeObjectForKey:@"ItemNotes"];
        self.itemImage = [coder decodeObjectForKey:@"ItemImage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.itemName forKey:@"ItemName"];
    [coder encodeBool:self.completed forKey:@"ItemCompleted"];
    [coder encodeObject:self.notes forKey:@"ItemNotes"];
    [coder encodeObject:self.itemImage forKey:@"ItemImage"];
}

@end
