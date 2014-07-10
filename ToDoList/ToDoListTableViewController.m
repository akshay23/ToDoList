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

@property NSMutableArray *toDoItems;
@property NSString *title;
@property (strong, nonatomic) AddToDoItemViewController *addToDoItemVC;
@property (nonatomic, strong) CreateListViewController *delegate;

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
    self.toDoItems = [[NSMutableArray alloc] init];
    
    // Create new add item VC using main storyboard
    self.addToDoItemVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"addItemVC"];
    self.addToDoItemVC.delegate = self;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(addToDoItem:)];
    
    [self.navigationItem setRightBarButtonItem:add];
    
    // Load data into list (if any)
    //[self loadList];
    
    // Used for the pull-down refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor purpleColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Set the title to the list name
    [self.navigationController setTitle:self.title];
    
    // refresh table and save list
    [self.tableView reloadData];
    [self saveList];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Ohhh YEAHHH!");
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
    
    if (listt && listt.count > 0)
    {
        self.toDoItems = listt;
        NSLog(@"List size is: %d", (int) listt.count);
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
    [defaults setObject:archiveArray forKey:self.title];
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

@end
