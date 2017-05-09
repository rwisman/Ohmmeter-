//
//  OhmConvertorItemCell.h
//  OhmConvertor
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface OhmConvertorItemCell : UITableViewCell

@property (assign, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic) IBOutlet UITextView *equationLabel;
@property (assign, nonatomic) IBOutlet UILabel *commentLabel;
@property (assign, nonatomic) IBOutlet UIButton *radioButton;
@property (assign, nonatomic) UITableView *tableView;

- (IBAction)toggleRadioButton:(id)sender;

- (BOOL) isSelectedCell;

+ (OhmConvertorItemCell *) selectedCell;

-(void) setSelectedCell: (OhmConvertorItemCell *) reference ;

@end


