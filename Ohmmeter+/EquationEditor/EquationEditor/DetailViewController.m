//
//  DetailViewController.m
//  OhmConvertor
//
//  Created by joeconway on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
//#import "InfoViewController.h"

@implementation DetailViewController
@synthesize item;
@synthesize dismissBlock;

-(IBAction) onInfo:(id) sender
{
    InfoEquationEditorViewController *info = [[InfoEquationEditorViewController alloc] init];
    [self presentViewController:info animated:NO completion:nil];       // Display the newly created view window
}

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] 
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                         target:self 
                                         action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];            

            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                         target:self 
                                         action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        }
        else {
            
             UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
             [infoButton addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];             
             [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:infoButton]];
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem:"
                                 userInfo:nil];
    return nil;
}


- (void)setItem:(EquationItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[item itemName]];
}

- (IBAction)save:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}

- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the EquationItem from the store
    [[EquationItemStore sharedStore] removeItem:item];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [nameField setText:[item itemName]];
    [equationField setText:[item equation]];
    [commentField setText:[item comment]];

    // Create a NSDateFormatter that will turn a date into a simple date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    // Use filtered NSDate object to set dateLabel contents
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[item dateCreated]];
    [dateLabel setText:[dateFormatter stringFromDate:date]];

    // Change the navigation item to display name of item
    [[self navigationItem] setTitle:[item itemName]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {    
    return  toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *clr = nil;  
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
    } else {
        clr = [UIColor groupTableViewBackgroundColor];
    }
    [[self view] setBackgroundColor:clr];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES; 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Clear first responder
    [[self view] endEditing:YES];

    // "Save" changes to item
    [item setItemName:[nameField text]];
    [item setEquation:[equationField text]];
    [item setComment:[commentField text]];
}

- (IBAction)backgroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
    NSLog(@"%@", [self presentingViewController]);
}


@end
