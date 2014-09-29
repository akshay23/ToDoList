//
//  CreateListViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 7/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CreateListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateListViewController ()

@property (strong, nonatomic) NSMutableDictionary *listToViewDict;

@end

@implementation CreateListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listToViewDict = [[NSMutableDictionary alloc] init];
    
    if (![GlobalData getInstance].mainStoryboard)
    {
        // Instantiate new main storyboard instance
        [GlobalData getInstance].mainStoryboard = self.storyboard;
        NSLog(@"mainStoryboard instantiated");
    }
    
    // Make sure list has unique id
    for (ListItem *lItem in self.lists)
    {
        [lItem checkId];
    }
    
    // Load existing to-do lists (if any)
    [self loadAllLists];
    
    // Create tap recognizer to detect taps on view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    // Add tap recognizer to scrollview, then
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Load existing to-do lists (if any)
    [self loadAllLists];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self saveAllLists];
}

// Save all the lists using NSUserDefaults
// TODO: Use CoreData
- (void)saveAllLists
{
    // Clear all data first
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removePersistentDomainForName:appDomain];
    
    // refresh list ordering
    [self refreshListOrdering];
    
    // Save list (in two steps)
    // Step 1: convert custom objects in array into NSData
//    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.lists.count];
//    for (ListItem *item in self.lists) {
//        NSData *itemEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:item];
//        [archiveArray addObject:itemEncodedObject];
//    }
//
//    // Step 2: Actually save the new array
//    [defaults setObject:archiveArray forKey:@"MyToDoLists"];
//    [defaults synchronize];
    
    for (ListItem *item in self.lists)
    {
//        NSEntityDescription *entityList = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
//        NSManagedObject *newList = [[NSManagedObject alloc] initWithEntity:entityList insertIntoManagedObjectContext:managedObjectContext];
//        [newList setValue:item.name forKey:@"name"];
//        [newList setValue:item.listId forKey:@"listId"];
//        
//        // Save each to-do item
//        for (ToDoItem *todo in item.toDoItems)
//        {
//            NSManagedObject *newToDoItem = [[NSManagedObject alloc] initWithEntity:entityList insertIntoManagedObjectContext:managedObjectContext];
//            [newToDoItem setValue:todo.notes forKey:@"notes"];
//            [newToDoItem setValue:todo.itemName forKey:@"name"];
//            [newToDoItem setValue:todo.reminderDate forKey:@"reminderDate"];
//            [newToDoItem setValue:todo.reminderId forKey:@"reminderId"];
//            [newToDoItem setValue:[NSNumber numberWithBool:todo.completed] forKey:@"completed"];
//            
//            // create relationship
//            NSMutableSet *todos = [newList mutableSetValueForKey:@"todos"];
//            [todos addObject:newToDoItem];
//        }
        
        [self saveList:item];
    }

    NSLog(@"Lists saved");
}

// Save a particular list
- (void)saveList:(ListItem *)list
{
    NSError *error = nil;
    NSArray *result = [self findlist:list];
    
    if (result.count == 0)  // List does not exist
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        NSEntityDescription *entityList = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
        NSManagedObject *newList = [[NSManagedObject alloc] initWithEntity:entityList insertIntoManagedObjectContext:managedObjectContext];
        NSNumber *nn = [NSNumber numberWithInteger:list.order];
        [newList setValue:list.name forKey:@"name"];
        [newList setValue:list.listId forKey:@"listId"];
        [newList setValue:nn forKey:@"order"];
        
        if (![newList.managedObjectContext save:&error])
        {
            NSLog(@"Unable to save new list.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
    else  // List exists
    {
        NSManagedObject *listObject = (NSManagedObject *)[result objectAtIndex:0];
        NSNumber *nn = [NSNumber numberWithInteger:list.order];
        [listObject setValue:list.name forKey:@"name"];
        [listObject setValue:nn forKey:@"order"];
        
        if (![listObject.managedObjectContext save:&error]) {
            NSLog(@"Unable to update existing list.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}

// Read from CoreData
- (void)loadAllLists
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setEntity:entityDesc];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *listObjects = [NSMutableArray arrayWithCapacity:objects.count];
    for (NSManagedObject *item in objects)
    {
        ListItem *i = [[ListItem alloc] initWithName:[item valueForKey:@"name"]];
        NSNumber *n = [item valueForKey:@"order"];
        [i setOrder:[n integerValue]];
        [i setListId:[item valueForKey:@"listId"]];
        [listObjects addObject:i];
    }
    
    if (listObjects)
    {
        self.lists = listObjects;
        NSLog(@"List size is: %d", (int) listObjects.count);
    }
    else
    {
        self.lists = [[NSMutableArray alloc] init];
        NSLog(@"List of ListItems is nil");
    }
}

// Delete all lits from store (core data)
- (void)deleteAllLists
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (id listItem in objects)
    {
        [managedObjectContext deleteObject:listItem];
    }
}

// Delete list
- (void)deleteList:(ListItem *)listItem
{
    NSArray *result = [self findlist:listItem];
    
    if (result && result.count == 1)
    {
        NSError *error;
        NSManagedObject *listObject = (NSManagedObject *)[result objectAtIndex:0];
        [listObject.managedObjectContext deleteObject:listObject];
        
        if (![listObject.managedObjectContext save:&error])
        {
            NSLog(@"Unable to delete list.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
    else
    {
        NSLog(@"Could not find list in Core Data");
    }
}

// Find a list in Core Data
- (NSArray *)findlist:(ListItem *)listItem
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    // Check to see if list exists, else create new entry
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"listId like[c] %@", listItem.listId];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSArray *retList = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (!retList)
    {
        NSLog(@"Error when trying to find list!");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }

    return retList;
}

// Decodes each item in the input array using NSKeyedUnarchiver
// into a ListItem
- (NSMutableArray *)decodeMyArray:(NSMutableArray *)encodedArray
{
    if (!encodedArray) return nil;

    NSMutableArray *decoded = [NSMutableArray arrayWithCapacity:encodedArray.count];
    for (NSData *item in encodedArray) {
        ListItem *decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        [decoded addObject:decodedObject];
    }

    return decoded;
}

// Show alertview where user can enter new list name
- (IBAction)addList:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Create New List" message:@"Please enter list name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setEnablesReturnKeyAutomatically:YES];
    [[alert textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [alert show];
}

// Take action based on which button in alert view was pressed
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && ![GlobalData stringIsNilOrEmpty:[[alertView textFieldAtIndex:0] text]])
    {
        NSString *listName = [[alertView textFieldAtIndex:0] text];
        ListItem *item = [[ListItem alloc] initWithName:listName];
        [item setOrder:self.lists.count];

        if (self.lists == nil)
        {
            NSLog(@"Lists array is nil");
            self.lists = [[NSMutableArray alloc] init];
        }

        [self.lists addObject:item];

        // Initialize new toDoList view controller instance
        ToDoListTableViewController *newVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"todoListVC"];
        newVC.delegate = self;
        newVC.list = item;
        [newVC initializeView];
        [self.listToViewDict setObject:newVC forKey:item.listId];

        // Save array of lists
        [self saveList:item];

        // Navigate to view
        [self.navigationController pushViewController:newVC animated:YES];
    }
}

// Go into edit mode and add UITextViews into each cell so
// user can edit list name
- (IBAction)editList:(id)sender
{
    if (![self.tableView isEditing])
    {
        // Enter edit mode
        [self.tableView setEditing:YES animated:YES];
        [[self.navigationItem leftBarButtonItem] setTitle:@"Done"];
        [[self.navigationItem rightBarButtonItem] setEnabled:NO];
        
        // Show textboxes in cells for editing
        [self showTextBoxesForEditing];
    }
    else
    {
        // Hide textboxes
        [self hideTextBoxesAfterEditing];
        
        // Exit edit mode
        [self.tableView setEditing:NO animated:YES];
        [[self.navigationItem leftBarButtonItem] setTitle:@"Edit"];
        [[self.navigationItem rightBarButtonItem] setEnabled:YES];
        
        // Save array of lists
        [self saveAllLists];
    }
}

// Un-hide the UITextView objects in each cell of the table
- (void)showTextBoxesForEditing
{
    for (int i = 0; i < self.lists.count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        ListItem *lItem = [self.lists objectAtIndex:path.row];
        [cell.textLabel setText:@""];
        
        [self addTextViewIntoCell:cell itemBeingAdded:lItem];
    }
    
    NSLog(@"Showed UITextViews in each cell");
}

// Re-hide the UITextView objects and change name of each objec in array
- (void)hideTextBoxesAfterEditing
{
    for (int i = 0; i < self.lists.count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];

        for (UIView *v in cell.contentView.subviews)
        {
            if([v isMemberOfClass:[UITextView class]])
            {
                UITextView *vv = (UITextView *)v;
                
                if (vv.text.length != 0)
                {
                    [cell.textLabel setText:vv.text];
                    [[self.lists objectAtIndex:i] setName:vv.text];
                }
                else
                {
                    [cell.textLabel setText:[[self.lists objectAtIndex:i] name]];
                }

                [vv removeFromSuperview];
            }
        }
    }
    
    NSLog(@"Removed all UITextViews from each cell");
}

// Allows user to tap anywhere on the background/view to dismiss keyboard
- (void)hideKeyboard
{
    for (int i = 0; i < self.lists.count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        
        for (UIView *v in cell.contentView.subviews)
        {
            if([v isMemberOfClass:[UITextView class]])
            {
                [v resignFirstResponder];
            }
        }
    }
}

// Add new textview into given tableview cell
- (void)addTextViewIntoCell:(UITableViewCell *)cell itemBeingAdded:(ListItem *)item
{
    // Create new UITxtView subvew to allow user to edit list nam
    // Keep hidden until needed
    CGRect frame  = CGRectMake(cell.contentView.frame.origin.x - 40, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    UITextView *txtField =[[UITextView alloc] initWithFrame:frame];
    txtField.text = item.name;
    txtField.editable = YES;
    txtField.userInteractionEnabled = YES;
    txtField.font = cell.textLabel.font;
    [txtField setTextColor:cell.textLabel.textColor];
    [txtField setBackgroundColor:cell.backgroundColor];
    [[txtField layer] setBorderWidth:1.5];
    [[txtField layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[txtField layer] setCornerRadius:10.0];
    
    // Add UITextView to contentView
    [cell.contentView addSubview:txtField];
}

// Make sure the list ordering is correct
- (void)refreshListOrdering
{
    NSInteger listOrder = 0;
    for (ListItem *item in self.lists)
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
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ListItem *item = [self.lists objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell.textLabel setText:item.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListItem *item = [self.lists objectAtIndex:indexPath.row];
    
    if (!self.listToViewDict[item.listId])
    {
        ToDoListTableViewController *newVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"todoListVC"];
        newVC.delegate = self;
        newVC.list = item;

        [newVC initializeView];
        [self.listToViewDict setObject:newVC forKey:item.listId];

        [self.navigationController pushViewController:newVC animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:[self.listToViewDict objectForKey:item.listId] animated:YES];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ListItem *removed = [self.lists objectAtIndex:indexPath.row];
        for (ToDoItem *item in removed.toDoItems)
        {
            [item deleteReminder];
            [item setItemImage:nil];
        }

        [self.lists removeObjectAtIndex:indexPath.row];
        [self deleteList:removed];
        removed = nil;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    ListItem *temp = [self.lists objectAtIndex:fromIndexPath.row];
    [self.lists removeObjectAtIndex:fromIndexPath.row];
    [self.lists insertObject:temp atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end
