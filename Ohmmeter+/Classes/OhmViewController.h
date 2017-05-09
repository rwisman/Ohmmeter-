//
//  Created by Ray Wisman on Aug 8, 2011.
//

// % change/sample in low-pass filter

const double ALPHA = 0.01;

// Frequency of sine wave generated and output to audio

#define sineFrequency 199.0

//#define timeInterval ALPHA

#define samplingRate 2000.0

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>
#import <AudioToolbox/AudioToolbox.h>

#import "Data.h"
#include "BleepMachine.h"
#import "InfoViewController.h"
#import "GCMathParser.h"
#import "EquationItemStore.h"
#import "EquationItem.h"
#import "ItemsViewController.h"

@interface OhmViewController  : UIViewController <MFMailComposeViewControllerDelegate, AVAudioSessionDelegate, AVAudioPlayerDelegate> {
	IBOutlet UIButton *sendButton;
	IBOutlet UIButton *higherButton;
	IBOutlet UIButton *lowerButton;
	IBOutlet UIButton *muchHigherButton;
	IBOutlet UIButton *muchLowerButton;
	IBOutlet UIButton *fasterButton;
	IBOutlet UIButton *slowerButton;
	IBOutlet UIButton *saveButton;
	IBOutlet UIButton *volumeIncreaseButton;
	IBOutlet UIButton *volumeDecreaseButton;
	IBOutlet UIButton *disappearTextView;
    AVAudioRecorder *recorder;
    NSURL *url;
    
    IBOutlet UILabel *OhmLabel;
    IBOutlet UILabel *OhmDecimalLabel;

    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *dBLabel;
    IBOutlet UILabel *equationLabel;
    IBOutlet UILabel *equationResultLabel;
    IBOutlet UILabel *equationResultDecimalLabel;
    
    IBOutlet UITextView *dBLowTextView;
    IBOutlet UITextView *dBHighTextView;

    IBOutlet UIProgressView *dBRangeProgressView;

	NSNotificationCenter *notificationCenter;
	BleepMachine * m_bleepMachine;
	AVAudioSession *audioSession;
	NSTimer *levelTimer;
	BOOL isViewVisible;
    GCMathParser*	parser;
    
    NSString *expression;
}

@property (readwrite, assign, nonatomic) Data *data;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, assign) NSNotificationCenter *notificationCenter;
@property (nonatomic, assign) AVAudioSession *audioSession;
@property (nonatomic, assign) NSTimer *levelTimer;
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) IBOutlet UILabel *OhmLabel;
@property (nonatomic, retain) IBOutlet UILabel *OhmDecimalLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *dBLabel;
@property (nonatomic, retain) IBOutlet UILabel *equationLabel;
@property (nonatomic, retain) IBOutlet UILabel *equationResultLabel;
@property (nonatomic, retain) IBOutlet UILabel *equationResultDecimalLabel;
@property (nonatomic, retain) IBOutlet UITextView *dBLowTextView;
@property (nonatomic, retain) IBOutlet UITextView *dBHighTextView;
@property (nonatomic, retain) IBOutlet UIProgressView *dBRangeProgressView;

@property (nonatomic, copy) NSString *expression;

-(IBAction) startStopButton: (id) sender; 
-(IBAction) sendButton: (id) sender;
-(IBAction) higherButton: (id) sender;
-(IBAction) lowerButton: (id) sender;
-(IBAction) muchHigherButton: (id) sender;
-(IBAction) muchLowerButton: (id) sender;
-(IBAction) fasterButton: (id) sender;
-(IBAction) slowerButton: (id) sender;
-(IBAction) saveButton: (id) sender;
-(IBAction) volumeIncreaseButton: (id) sender;
-(IBAction) volumeDecreaseButton: (id) sender;
-(IBAction) onInfo:(id) sender;
-(IBAction) disappearTextView:(id) sender;

@end

