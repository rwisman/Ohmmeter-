#import <UIKit/UIKit.h>
#import "InfoEquationEditorViewController.h"
#import "EquationItem.h"
#import "EquationItemStore.h"

@class EquationItem;

@interface DetailViewController : UIViewController
    <UINavigationControllerDelegate, UITextFieldDelegate>
{
    /*__weak*/ IBOutlet UITextField *nameField;
    /*__weak*/ IBOutlet UITextView *equationField;
    /*__weak*/ IBOutlet UITextField *commentField;
    /*__weak*/ IBOutlet UIButton *selectedField;
    /*__weak*/ IBOutlet UILabel *dateLabel;
}

- (id)initForNewItem:(BOOL)isNew;

@property (nonatomic, strong) EquationItem *item;

@property (nonatomic, copy) void (^dismissBlock)(void);

- (IBAction)backgroundTapped:(id)sender;
- (IBAction) onInfo:(id) sender;

@end
