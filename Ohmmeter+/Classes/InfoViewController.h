//
//  InfoViewController.h
//  Ohm linear
//
//  Created by Raymond Wisman on 3/6/13.
//
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController {
    IBOutlet UITextView *infoTextView;
    IBOutlet UIButton *infoButton;
}
@property (nonatomic, retain) IBOutlet UITextView *infoTextView;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

-(IBAction) onDone:(id) sender;
@end
