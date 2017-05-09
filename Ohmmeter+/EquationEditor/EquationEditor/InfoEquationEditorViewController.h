//
//  InfoEquationEditorViewController.h
//  Ohmmeter+
//
//  Created by Raymond Wisman on 7/28/13.
//
//

#import <UIKit/UIKit.h>

@interface InfoEquationEditorViewController : UIViewController  {
    IBOutlet UITextView *infoEquationEditorTextView;
}
@property (nonatomic, retain) IBOutlet UITextView *infoEquationEditorTextView;

-(IBAction) onInfoEquationEditorDone:(id) sender;
@end
