//
//  ItemsViewController.h
//  OhmConvertor
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EquationItem.h"
#import "DetailViewController.h"

@interface ItemsViewController : UITableViewController {}

- (IBAction)addNewItem:(id)sender;
+ (EquationItem *) selectedItem;

@end
