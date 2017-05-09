//
//  ItemsViewController.m
//  OhmConvertor
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemsViewController.h"
#import "EquationItemStore.h"
#import "EquationItem.h"
#import "OhmConvertorItemCell.h"

EquationItem *selectedEquationItem=nil;

@implementation ItemsViewController

- (id)init 
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {        
        [[self navigationItem] setTitle:NSLocalizedString(@"Equation Editor", @"Application title")];

        // Create a new bar button item that will send
        // addNewItem: to ItemsViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                             target:self 
                                             action:@selector(addNewItem:)];

        NSArray *buttonItems ;
        buttonItems = [ NSArray arrayWithObjects:[self editButtonItem], bbi, nil];
        [[self navigationItem] setRightBarButtonItems:buttonItems];
        
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle: @"Edit"];
        UIImage *im = [UIImage imageNamed:@"Pencil.png"];
        [tbi setImage:im];
    }

    return self;
}

+ (EquationItem *) selectedItem {
    return selectedEquationItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {
    return  toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"OhmConvertorItemCell" bundle:nil];
    
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"OhmConvertorItemCell"];
}

- (IBAction)addNewItem:(id)sender
{
    // Create a new EquationItem and add it to the store
    EquationItem *newItem = [[EquationItemStore sharedStore] createItem];
        
    DetailViewController *detailViewController = 
            [[DetailViewController alloc] initForNewItem:YES];
    
    [detailViewController setItem: newItem];

    [detailViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];

    UINavigationController *navController = [[UINavigationController alloc] 
                                initWithRootViewController:detailViewController];
        
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];        
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)tableView:(UITableView *)tableView 
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
           toIndexPath:(NSIndexPath *)toIndexPath 
{
    [[EquationItemStore sharedStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

- (void)tableView:(UITableView *)aTableView 
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[EquationItemStore sharedStore] allItems];
    EquationItem *selectedItem = [items objectAtIndex:[indexPath row]];

    // Give detail view controller a pointer to the item object in row
    [detailViewController setItem:selectedItem];
    
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:detailViewController
                                           animated:YES];
}

- (void)tableView:(UITableView *)tableView 
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
     forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        EquationItemStore *ps = [EquationItemStore sharedStore];
        NSArray *items = [ps allItems];
        EquationItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        if([p selected]) {
            OhmConvertorItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OhmConvertorItemCell"];
            [cell setSelectedCell: nil];
            selectedEquationItem=nil;
        }

        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[EquationItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EquationItem *p = [[[EquationItemStore sharedStore] allItems]
                                    objectAtIndex:[indexPath row]];
    OhmConvertorItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OhmConvertorItemCell"];

    [cell setTableView:tableView];
    cell.accessoryView = cell.radioButton;

    [cell.radioButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [[cell nameLabel] setText:[p itemName]];
    [[cell equationLabel] setText:[p equation]];
    [[cell commentLabel] setText:[p comment]];
    
    [[cell radioButton] setSelected: [p selected]];
    if([p selected])
        selectedEquationItem = p;

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

- (void)accessoryButtonTapped: (id)sender {
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:(UITableViewCell *)[sender superview]];
    EquationItem *p = [[[EquationItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    OhmConvertorItemCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:@"OhmConvertorItemCell"];
    
    [cell setTableView:[self tableView]];
    
    selectedEquationItem.selected=NO;
    [OhmConvertorItemCell selectedCell].radioButton.selected=NO;
    p.selected=YES;
//    [cell radioButton].selected=YES;

    [[self tableView] reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

@end
