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

- (void)refreshData;

@end

@implementation ToDoListTableViewController

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

- (void)refreshData
{
    // Find the things to remove
    NSMutableArray *toDelete = [NSMutableArray array];
    for (ToDoItem *item in self.toDoItems)
        if (item.completed)
            [toDelete addObject:item];
    
    // Remove the completed items from local array
    [self.toDoItems removeObjectsInArray:toDelete];
    
    [self.delegate saveLists];
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
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:2.0 blue:0.5 alpha:1.0]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setBackgroundColor:self.tableView.backgroundColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.delegate saveLists];   // Save list
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
        [self.delegate saveLists];
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
