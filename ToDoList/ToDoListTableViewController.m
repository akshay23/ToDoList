//
//  ToDoListTableViewController.m
//  ToDoList
//
//  Created by Akshay Bharath on 6/2/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoItem.h"
#import "AddToDoItemViewController.h"

@interface ToDoListTableViewController ()

- (void)loadList;
- (NSMutableArray *)decodeMyArray:(NSMutableArray *)encodedArray;
- (void)saveList;
- (void)refreshData;

@property NSMutableArray *toDoItems;
@property CreateListViewController *delegate;
@property NSString *title;

@end

@implementation ToDoListTableViewController

- (id)initWithDelegateAndTitle:(NSString *)title theDelegate:(CreateListViewController *)delegate
{
    self.delegate = delegate;
    self.title = title;
    
    return self;
}

- (id)initWithDelegateAndListItem:(ListItem *)list theDelegate:(CreateListViewController *)delegate
{
    self.delegate = delegate;
    self.item = list;
    self.title = list.name;
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(addItem:)];
    
    [self.navigationItem setRightBarButtonItem:add];
    
    // Load data into list (if any)
    [self loadList];
    
    // Used for the pull-down refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor purpleColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self.navigationController setTitle:self.title];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadList
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *list = [self decodeMyArray:[defaults objectForKey:@"UnsavedItems"]];
    
    if (list && list.count > 0)
    {
        self.toDoItems = list;
        NSLog(@"List size is: %d", (int) list.count);
    }
    else
    {
        self.toDoItems = [[NSMutableArray alloc] init];
        NSLog(@"List is empty on load");
    }
}

- (NSMutableArray *)decodeMyArray:(NSMutableArray *)encodedArray
{
    if (!encodedArray) return nil;
    
    NSMutableArray *decoded = [NSMutableArray arrayWithCapacity:encodedArray.count];
    for (NSData *item in encodedArray) {
        ToDoItem *decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        if (!decodedObject.completed)
        {
            [decoded addObject:decodedObject];
        }
    }
    
    return decoded;
}

- (void)saveList
{
    // Save list (in two steps)
    // Step 1: convert custom objects in array into NSData
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.toDoItems.count];
    for (ToDoItem *item in self.toDoItems) {
        NSData *itemEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:item];
        [archiveArray addObject:itemEncodedObject];
    }
    
    // Step 2: Actually save the new array
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archiveArray forKey:@"UnsavedItems"];
    [defaults synchronize];
    
    NSLog(@"List saved");
}

- (void)refreshData
{
    // Load data into list
    [self loadList];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    AddToDoItemViewController *source = [segue sourceViewController];
    ToDoItem *todoItem = source.toDoItem;
    
    if (todoItem != nil)
    {
        [self.toDoItems addObject:todoItem];
        [self.tableView reloadData];
        
        NSLog(@"List size is: %d", (int) self.toDoItems.count);
        
        // Save list
        [self saveList];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor greenColor]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [self saveList];   // Save list
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    NSString *todoItem = nil;
    if (idx && view)
    {
        ToDoItem *item = [self.toDoItems objectAtIndex:idx.row];
        todoItem = item.itemName;
    }
    
    return todoItem;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSIndexPath *indexPath = nil;
    if (identifier && view)
    {
        NSPredicate *todoPred = [NSPredicate predicateWithFormat:@"itemName == %@", identifier];
        NSInteger row = [self.toDoItems indexOfObjectPassingTest:
                         ^(id obj, NSUInteger idx, BOOL *stop)
                         {
                             return [todoPred evaluateWithObject:obj];
                         }];
        
        if (row != NSNotFound)
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        }
    }
    
    return indexPath;
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
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [self saveList];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
