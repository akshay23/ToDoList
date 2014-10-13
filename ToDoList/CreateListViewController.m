//
//  CreateListViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 7/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CreateListViewController.h"

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
    
    // Create tap recognizer to detect taps on view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    // Add tap recognizer to scrollview, then
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load existing to-do lists (if any)
    [self loadAllLists];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self saveAllLists];
}

// Save a particular list
- (void)saveList:(ListItem *)list
{
    PFQuery *query = [PFQuery queryWithClassName:@"ListItem"];
    [query whereKey:@"listId" equalTo:list.listId];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully completed query.");
            
            PFObject *listItem;
            if (objects.count == 0)
            {
                // Create new entry in Parse
                listItem = [PFObject objectWithClassName:@"ListItem"];
                NSLog(@"New list.");
            }
            else
            {
                // Existing item
                listItem = (PFObject *)[objects objectAtIndex:0];
                NSLog(@"Existing list.");
            }
            
            listItem[@"name"] = list.name;
            listItem[@"listId"] = list.listId;
            listItem[@"order"] = [NSNumber numberWithInteger:list.order];
            
            // Save
            [listItem saveInBackground];
            NSLog(@"Saved to Parse");

        } else {
            // Log details of the failure
            NSLog(@"Error when trying to find list: %@ %@", error, [error userInfo]);
        }
    }];
}

// Delete list
- (void)deleteList:(ListItem *)listItem
{
    PFQuery *query = [PFQuery queryWithClassName:@"ListItem"];
    [query whereKey:@"listId" equalTo:listItem.listId];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully completed query.");
            
            if (objects.count != 0)
            {
                // Delete list
                PFObject *listItem = (PFObject *)[objects objectAtIndex:0];
                
                // Save
                [listItem deleteInBackground];
                NSLog(@"Deleted from Parse");
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error when trying to find list: %@ %@", error, [error userInfo]);
        }
    }];

}

// Save all the lists using CoreData
- (void)saveAllLists
{
    // refresh list ordering
    [self refreshListOrdering];
    
    // Save each list
    for (ListItem *item in self.lists)
    {
        [self saveList:item];
    }
    
    NSLog(@"Lists saved");
}

// Read from CoreData
- (void)loadAllLists
{
    PFQuery *query = [PFQuery queryWithClassName:@"ListItem"];
    [query orderByAscending:@"order"];
    
    NSArray *objects = [query findObjects];
    NSMutableArray *listObjects = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *item in objects)
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
    PFQuery *query = [PFQuery queryWithClassName:@"ListItem"];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully completed query.");

            for (PFObject *obj in objects)
            {
                [obj deleteInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error when trying to find list: %@ %@", error, [error userInfo]);
        }
    }];
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
