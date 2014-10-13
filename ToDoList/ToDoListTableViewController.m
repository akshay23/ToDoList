//
//  ToDoListTableViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ToDoListTableViewController.h"

@interface ToDoListTableViewController ()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray *toDoItems;

@end

@implementation ToDoListTableViewController

@synthesize tableView;

- (void)initializeView
{
    self.title = self.list.name;
    
    // Either create new or load existing list of todo items
    if (!self.list.toDoItems)
    {
        self.toDoItems = [[NSMutableArray alloc] init];
    }
    else
    {
        self.toDoItems = self.list.toDoItems;
    }
    
    // Create new add item VC using main storyboard
    self.addToDoItemVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"addItemVC"];
    self.addToDoItemVC.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeView];
    
    // Create and add the 'Add' button to navigation bar
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addToDoItem:)];
    [self.navigationItem setRightBarButtonItem:add];
    
    // Used for the pull-down refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor purpleColor];
    [refreshControl addTarget:self action:@selector(confirmRefreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Set the title to the list name
    [self.navigationController setTitle:self.title];
    
    // Set colour
    [self.tableView setBackgroundColor:self.delegate.tableView.backgroundColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Clear temp data
    [self.addToDoItemVC clearTemps];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load all items for list
    [self loadAllItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self saveAllItems];
}

// Push to the AddToDoItemVC to Add new item
- (void)addToDoItem:(id)sender
{
    self.addToDoItemVC.mode = Add;
    self.addToDoItemVC.toDoItem = nil;
    [self.navigationController pushViewController:self.addToDoItemVC animated:YES];
}

// Save to Core Data.
- (void)saveItem:(ToDoItem *)item
{
    PFQuery *query = [PFQuery queryWithClassName:@"ToDoItem"];
    [query whereKey:@"itemId" equalTo:item.itemId];
    [query orderByAscending:@"order"];
    
    NSArray *objects = [query findObjects];
    NSLog(@"Successfully completed query.");
    
    PFObject *listItem;
    if (objects.count == 0)
    {
        // Create new entry in Parse
        listItem = [PFObject objectWithClassName:@"ToDoItem"];
        [item setOrder:self.toDoItems.count];
        [self.toDoItems addObject:item];
        NSLog(@"New to-do item created.");
    }
    else
    {
        // Update item
        listItem = (PFObject *)[objects objectAtIndex:0];
        NSLog(@"Existing to-do item retrieved.");
    }
    
    // Add the details
    NSNumber *nn = [NSNumber numberWithInteger:item.order];
    listItem[@"itemId"] = item.itemId;
    listItem[@"listId"] = self.list.listId;
    listItem[@"name"] = item.itemName;
    listItem[@"notes"] = item.notes;
    listItem[@"completed"] = [NSNumber numberWithBool:item.completed];
    listItem[@"order"] = nn;
    
    if (item.reminderDate)
    {
        listItem[@"reminderDate"] = item.reminderDate;
    }
    
    if (item.reminderId)
    {
        listItem[@"reminderId"] = item.reminderId;
    }
    
    if (item.itemImage.length != 0)
    {
        listItem[@"image"] = item.itemImage;
    }
    
    // Save
    [listItem saveInBackground];
    NSLog(@"Saved to Parse");

}

// Delete to-do item from Core Data
- (void)deleteItem:(ToDoItem *)item
{
    PFQuery *query = [PFQuery queryWithClassName:@"ToDoItem"];
    [query whereKey:@"itemId" equalTo:item.itemId];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully completed query.");
            
            if (objects.count != 0)
            {
                // Delete list
                PFObject *todoItem = (PFObject *)[objects objectAtIndex:0];
                
                // Save
                [todoItem deleteInBackground];
                NSLog(@"Deleted from Parse");
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error when trying to find item: %@ %@", error, [error userInfo]);
        }
    }];

}

// Save all to-do items to CoreData
- (void)saveAllItems
{
    // Refresh list ordering
    [self refreshListOrdering];
    
    // Save each item
    for (ToDoItem *item in self.toDoItems)
    {
        [self saveItem:item];
    }
}

// Load all to-do items from CoreData
- (void)loadAllItems
{
    PFQuery *query = [PFQuery queryWithClassName:@"ToDoitem"];
    [query whereKey:@"listId" equalTo:self.list.listId];
    [query orderByAscending:@"order"];
    
    NSArray *objects = [query findObjects];
    NSMutableArray *itemObjects = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *item in objects)
    {
        ToDoItem *i = [[ToDoItem alloc] initWithNameNotesAndCompleted:[item valueForKey:@"name"] notes:[item valueForKey:@"notes"] image:[UIImage imageWithData:[item valueForKey:@"image"]] isCompleted:[[item valueForKey:@"completed"] boolValue]];
        NSNumber *n = [item valueForKey:@"order"];
        [i setOrder:[n integerValue]];
        [i setItemId:[item valueForKey:@"itemId"]];
        [i setReminderDate:[item valueForKey:@"reminderDate"]];
        [i setReminderId:[item valueForKey:@"reminderId"]];
        [itemObjects addObject:i];
    }
    
    if (itemObjects)
    {
        self.toDoItems = itemObjects;
        NSLog(@"Items count is: %d", (int) itemObjects.count);
    }
    else
    {
        self.toDoItems = [[NSMutableArray alloc] init];
        NSLog(@"List of TodoItems is nil");
    }
}

// Make sure user does indeed want to clear finished items
- (void)confirmRefreshData
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                               message:@"Are you sure you want to clear the checked items ?"
                                               delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self refreshData];
    }
    
    [self.refreshControl endRefreshing];
}

// Refresh the data and reload table
- (void)refreshData
{
    // Find the things to remove
    NSMutableArray *toDelete = [NSMutableArray array];
    for (ToDoItem *item in self.toDoItems)
    {
        if (item.completed)
        {
            [toDelete addObject:item];
            [self deleteItem:item];
        }
    }

    // Remove the completed items from local array
    [self.toDoItems removeObjectsInArray:toDelete];

    [self saveAllItems];
    [self.tableView reloadData];

    NSLog(@"Data has been refreshed");
}

// Shake to go back to previous view
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Make sure the to-do item ordering is correct
- (void)refreshListOrdering
{
    NSInteger listOrder = 0;
    for (ToDoItem *item in self.toDoItems)
    {
        [item setOrder:listOrder];
        listOrder++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.toDoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] init];
    }
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    if ([[self.toDoItems objectAtIndex:indexPath.row] isKindOfClass:[ToDoItem class]] &&
        [GlobalData stringIsNilOrEmpty:[[self.toDoItems objectAtIndex:indexPath.row] itemName]])
    {
        cell.cellLabel.text = @"";
        [cell.tickBoxImage setHidden:YES];
        [cell.infoButton setHidden:YES];
    }
    else
    {
        cell.item = toDoItem;
        cell.cellLabel.text = toDoItem.itemName;
        cell.delegate = self;
        [cell.tickBoxImage setHidden:NO];
        [cell.infoButton setHidden:NO];
        
        [cell setSelected:toDoItem.completed animated:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self saveAllItems];   // Save list
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

// Override to support editing the table view.
// Delete from Core Data
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source and from Core Data
        [[self.toDoItems objectAtIndex:indexPath.row] deleteReminder];
        [[self.toDoItems objectAtIndex:indexPath.row] setItemImage:nil];
        [self deleteItem:[self.toDoItems objectAtIndex:indexPath.row]];
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Save list
        [self saveAllItems];
    }
}

// Override to support rearranging the table view.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    ToDoItem *object = [self.toDoItems objectAtIndex:fromIndexPath.row];
    [self.toDoItems removeObjectAtIndex:fromIndexPath.row];
    [self.toDoItems insertObject:object atIndex:toIndexPath.row];
}

// This method is called when the long press gesture is triggered starting the re-ording process.
// You insert a blank row object into your data source and return the object you want to save for
// later. This method is only called once.
- (ToDoItem *)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToDoItem *object = [self.toDoItems objectAtIndex:indexPath.row];
    [self.toDoItems replaceObjectAtIndex:indexPath.row withObject:[[ToDoItem alloc] init]];
    return object;
}

// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    [self.toDoItems replaceObjectAtIndex:indexPath.row withObject:object];
    
    // Save list
    [self saveAllItems];
}

@end
