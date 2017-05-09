//
//  OhmConvertorItemCell.m
//  OhmConvertor
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OhmConvertorItemCell.h"

@implementation OhmConvertorItemCell
@synthesize equationLabel;
@synthesize commentLabel;
@synthesize nameLabel;
@synthesize tableView;
@synthesize radioButton;

static OhmConvertorItemCell * selectedCell=nil;

- (IBAction)toggleRadioButton:(id)sender
{
    if(selectedCell.radioButton != radioButton) selectedCell.radioButton.selected=NO;
    [radioButton setSelected: !radioButton.selected];
    if(radioButton.selected) selectedCell = self;
}

- (BOOL) isSelectedCell {
    return self==selectedCell;
}

+ (OhmConvertorItemCell*) selectedCell {
    return selectedCell;
}

-(void) setSelectedCell: (OhmConvertorItemCell *) reference {
    selectedCell=reference;
};

@end
