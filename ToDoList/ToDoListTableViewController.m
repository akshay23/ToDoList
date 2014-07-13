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

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray *toDoItems;
@property (strong, nonatomic) AddToDoItemViewController *addToDoItemVC;
@property (strong, nonatomic) CreateListViewController *delegate;

- (void)loadList;
- (NSMutableArray *)decodeMyArray:(NSMutableArray *)encodedArray;
- (void)refreshData;

@end

@implementation ToDoListTableViewController

- (id)initWithDelegateAndListItem:(ListItem *)actualList theDelegate:(CreateListViewController *)delegate
{
    self.delegate = delegate;
    self.list = actualList;
    self.title = actualList.name;
    
    // Either create new or load existing list of todo items
    if (!actualList.toDoItems)
    {
        self.toDoItems = [[NSMutableArray alloc] init];
    }
    else
    {
        self.toDoItems = actualList.toDoItems;
    }
    
    // Create new add item VC using main storyboard
    self.addToDoItemVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"addItemVC"];
    self.addToDoItemVC.delegate = self;
    
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create and add the 'Add' button to navigation bar
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addToDoItem:)];
    [self.navigationItem setRightBarButtonItem:add];
    
    // Used for the pull-down refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor purpleColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Set the title to the list name
    [self.navigationController setTitle:self.title];
    
    // Set colour
    [self.tableView setBackgroundColor:self.delegate.tableView.backgroundColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Save list
    [self saveList];
    
    [super viewDidAppear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)addToDoItem:(id)sender
{
    [self.navigationController pushViewController:self.addToDoItemVC animated:YES];
}

- (void)addToArray:(ToDoItem *)item
{
    [self.toDoItems addObject:item];
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
    NSMutableArray *listt = [self decodeMyArray:[defaults objectForKey:self.title]];
    
    if (listt)
    {
        self.toDoItems = listt;
        self.list.toDoItems = self.toDoItems;
        NSLog(@"List size is: %d", (int) listt.count);
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
    [defaults setObject:archiveArray forKey:self.title];
    [defaults synchronize];
    
    // Save to list
    self.list.toDoItems = self.toDoItems;
    
    NSLog(@"List saved");
}

- (void)refreshData
{
    // Load data into list
    [self loadList];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
    [cell setBackgroundColor:self.tableView.backgroundColor];
    
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

@end
