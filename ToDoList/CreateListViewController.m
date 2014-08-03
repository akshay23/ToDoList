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

@property (strong, nonatomic) ToDoListTableViewController *toDoListVC;

- (NSMutableArray *)decodeMyArray:(NSMutableArray *)encodedArray;
- (void)showTextBoxesForEditing;
- (void)hideTextBoxesAfterEditing;

@end

@implementation CreateListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![GlobalData getInstance].mainStoryboard)
    {
        // Instantiate new main storyboard instance
        [GlobalData getInstance].mainStoryboard = self.storyboard;
        NSLog(@"mainStoryboard instantiated");
    }
    
    // Load existing to-do lists (if any)
    [self loadLists];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveLists
{
    // Save list (in two steps)
    // Step 1: convert custom objects in array into NSData
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.lists.count];
    for (ListItem *item in self.lists) {
        NSData *itemEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:item];
        [archiveArray addObject:itemEncodedObject];
    }

    // Step 2: Actually save the new array
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archiveArray forKey:@"MyToDoLists"];
    [defaults synchronize];

    NSLog(@"Lists saved");
}

- (void)loadLists
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *listt = [self decodeMyArray:[defaults objectForKey:@"MyToDoLists"]];

    if (listt)
    {
        self.lists = listt;
        NSLog(@"List size is: %d", (int) listt.count);
    }
    else
    {
        self.lists = [[NSMutableArray alloc] init];
        NSLog(@"List of ListItems is nil");
    }
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

- (IBAction)addList:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"List Name" message:@"Please enter list name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setEnablesReturnKeyAutomatically:YES];
    [[alert textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && ![GlobalData stringIsNilOrEmpty:[[alertView textFieldAtIndex:0] text]])
    {
        NSString *listName = [[alertView textFieldAtIndex:0] text];
        ListItem *item = [[ListItem alloc] initWithName:listName];

        if (self.lists == nil)
        {
            NSLog(@"Lists array is nil");
            self.lists = [[NSMutableArray alloc] init];
        }

        [self.lists addObject:item];
        [self.tableView reloadData];

        // Initialize new toDoList view controller instance
        self.toDoListVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"todoListVC"];
        self.toDoListVC.delegate = self;
        self.toDoListVC.list = item;
        [self.toDoListVC initializeView];

        // Save array of lists
        [self saveLists];

        // Navigate to view
        [self.navigationController pushViewController:self.toDoListVC animated:YES];
    }
}

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
        [self saveLists];
    }
}

// Un-hide the UITextView objects in each cell of the table
- (void)showTextBoxesForEditing
{
    for (int i = 0; i < self.lists.count; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        [cell.textLabel setText:@""];
        
        for (UIView *v in cell.contentView.subviews)
        {
            if([v isMemberOfClass:[UITextView class]])
            {
                UITextView *vv = (UITextView *)v;
                [vv setHidden:NO];
            }
        }
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
                [vv setHidden:YES];
                [cell.textLabel setText:vv.text];
                [[self.lists objectAtIndex:i] setName:vv.text];
            }
        }
    }
    
    NSLog(@"Hid all UITextViews from each cell");
}

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
    
    // Delete existing subviews from contentview
//    for (UIView *view in cell.contentView.subviews)
//    {
//        [view removeFromSuperview];
//    }
    
    // Create new UITxtView subvew to allow user to edit list nam
    // Keep hidden until needed
    CGRect frame  = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width - 80, cell.frame.size.height - 3);
    UITextView *txtField =[[UITextView alloc] initWithFrame:frame];
    txtField.text = item.name;
    txtField.editable = YES;
    txtField.font = cell.textLabel.font;
    [txtField setTextColor:cell.textLabel.textColor];
    [txtField setBackgroundColor:cell.backgroundColor];
    [txtField setHidden:YES];
    [[txtField layer] setBorderWidth:1.5];
    [[txtField layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[txtField layer] setCornerRadius:10.0];
    
    [cell.textLabel setText:item.name];
    [cell.contentView addSubview:txtField];

    NSLog(@"Inside CellForRowAtIndexPath");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListItem *item = [self.lists objectAtIndex:indexPath.row];
    self.toDoListVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"todoListVC"];
    self.toDoListVC.delegate = self;
    self.toDoListVC.list = item;

    [self.toDoListVC initializeView];
    [self.navigationController pushViewController:self.toDoListVC animated:YES];
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
        [self.lists removeObjectAtIndex:indexPath.row];
        [self saveLists];
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
