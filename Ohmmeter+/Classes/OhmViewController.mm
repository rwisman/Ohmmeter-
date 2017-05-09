//
//  Created by Ray Wisman on Aug 8, 2011.
//  Copyright 2011 Indiana University SE. All rights reserved.
//

#import "OhmViewController.h"
#include <math.h>


@implementation OhmViewController

@synthesize sendButton;
@synthesize notificationCenter;
@synthesize data;
@synthesize levelTimer;
@synthesize audioSession;
@synthesize recorder;
@synthesize url;

@synthesize OhmLabel;
@synthesize OhmDecimalLabel;
@synthesize timeLabel;
@synthesize dBLabel;
@synthesize equationResultLabel;
@synthesize equationResultDecimalLabel;
@synthesize equationLabel;

@synthesize dBLowTextView;
@synthesize dBHighTextView;

@synthesize dBRangeProgressView;

@synthesize expression;

//NSString *expression=nil;
NSError *error=nil;

UIButton * startStopButton;

float ohms[MAXSAMPLES], collectionTime[MAXSAMPLES];
float startTime;

int ticks = 0;
int n=0;
int volumeUpdates=0;

BOOL start=NO;
BOOL calibrating=NO;
BOOL volumeChange=NO;

float updateTime = 0.5;
double lowPassResults=-20.0;
double calibrationCorrection = 0.0;
double lastCalibrationdB = 0.0;
double decibel;
double OhmSeries;
double result;

MPMusicPlayerController *player;
NSString *s = nil;

void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue)
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    OhmViewController *controller = (OhmViewController *) inUserData;
    
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef) inPropertyValue;
    
    CFNumberRef routeChangeReasonRef =
        (CFNumberRef) CFDictionaryGetValue (
                          routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    
    CFNumberGetValue (
                      routeChangeReasonRef,
                      kCFNumberSInt32Type,
                      &routeChangeReason);
    
    CFStringRef audioRoute;
    UInt32 size;
    size = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &audioRoute);
        
    if(![@"HeadsetInOut" isEqualToString: (NSString *)audioRoute])
        [controller initialize];
}

-(void) resetButtons {
	[startStopButton setBackgroundImage:[[UIImage imageNamed:@"start.png"] stretchableImageWithLeftCapWidth:110.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[startStopButton setTitle:@"Record" forState: UIControlStateNormal];
	sendButton.enabled = YES; 	
	lowerButton.enabled = YES;
	higherButton.enabled = YES;
	muchLowerButton.enabled = YES;
	muchHigherButton.enabled = YES;
	fasterButton.enabled = YES;
	slowerButton.enabled = YES; 	
	saveButton.enabled = YES;
	volumeDecreaseButton.enabled = YES;
	volumeIncreaseButton.enabled = YES;
	start=FALSE;
}	

-(void) startCheck {
	if(start) {
		sendButton.enabled = NO;
		lowerButton.enabled = NO;
		higherButton.enabled = NO;
		muchLowerButton.enabled = NO;
		muchHigherButton.enabled = NO;
		fasterButton.enabled = NO;
		slowerButton.enabled = NO; 	
		saveButton.enabled = NO;
        volumeDecreaseButton.enabled = NO;
        volumeIncreaseButton.enabled = NO;
		
		if(data)
			[data release];
		data = [Data alloc];
		n=0; 
		[startStopButton setTitle:@"Stop" forState: UIControlStateNormal];
		[startStopButton setBackgroundImage:[[UIImage imageNamed:@"stop.png"] stretchableImageWithLeftCapWidth:110.0 topCapHeight:0.0] forState:UIControlStateNormal];
		self.data.dataX = collectionTime;
		self.data.dataY = ohms;
		self.data.minTime = 0.0;
		self.data.maxTime = 0.0;
		self.data.minX = 0.0;
		self.data.maxX = 0.0;
		self.data.minY = 0.0;
		self.data.maxY = 0.0;
		self.data.startIndex = 0;
		self.data.endIndex = 0;
	}
	else {
		[self resetButtons];
        [notificationCenter postNotificationName: @"DATACHANGE" object: data];
	}
    
    self.data.expression = expression;
}

#import <mach/mach.h>
#import <mach/mach_host.h>

static unsigned int free_memory () {
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
	vm_size_t pagesize;
	
	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_page_size(host_port, &pagesize); 
	
	vm_statistics_data_t vm_stat;
	
	if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
		return 0;	//NSLog(@"Failed to fetch vm statistics");
	
	// Stats in bytes
//	natural_t mem_used = (vm_stat.active_count +
//						  vm_stat.inactive_count +
//						  vm_stat.wire_count) * pagesize;
	natural_t mem_free = vm_stat.free_count * pagesize;
//	natural_t mem_total = mem_used + mem_free;
//	NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
	return (unsigned int) mem_free;
}

- (void) initialize {
	
	NSError *error=nil;
	
	if(free_memory() < 12000000) {	// About the memory app requirements.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low memory." 
													message:@"Double tap Home to exit other applications before continuing." 
													delegate:nil 
													cancelButtonTitle:@"Continue"
													otherButtonTitles:nil];
		[alert show];
		[alert release];
        alert = nil;
	}
    
    CFStringRef audioRoute;
    UInt32 size;
    size = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &audioRoute);
    
    if( !([@"HeadsetInOut" isEqualToString: (NSString *)audioRoute] )){ //|| [@"Headphone" isEqualToString: (NSString *)audioRoute] ) ) {
  		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Headphone jack not connected.",@"Headphone jack not connected.")
														message:NSLocalizedString(@"Connect to circuit before continuing.",@"Connect to circuit before continuing.")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Continue",@"Continue")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
        alert = nil;
//        return;
	}

    /*  Following added hack for disconnect/reconnect of headphone jack.
        Not sure why but audioRoute needs to be set to speaker then back to default.
 
        Not needed in previous iOS versions, something was changed in AudioSession.
     */
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );

    audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
        
	if(self.levelTimer) {
		[self.levelTimer invalidate]; 
		self.levelTimer = nil;
	}
	
	if( m_bleepMachine) 
		delete m_bleepMachine;

	m_bleepMachine = new BleepMachine; 
	m_bleepMachine->Initialise(); 
	m_bleepMachine->SetWave(sineFrequency, 1 );
	m_bleepMachine->Start();
	
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0 ],					AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless],	AVFormatIDKey,
							  [NSNumber numberWithInt: 1],							AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],			AVEncoderAudioQualityKey,
							  nil];

    if(recorder) {
		if([recorder isRecording]) {
			[recorder stop];			
		}
		[recorder release];
	}
 
	error = nil;
    
    url = [NSURL fileURLWithPath:@"/dev/null"];
	
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error: &error];
	
	if(error) 
		NSLog(@"recorder error %@\n", [error description]);

	if (recorder) {
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;
		[recorder record];
	} else
		NSLog(@"recorder %@",[error description]);
		
	self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: ALPHA target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	start = NO;
    
	[self resetButtons];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	
    ticks++;
	
	[recorder updateMeters];
	
	decibel = [recorder peakPowerForChannel:0];
                                                                            // low-pass filter
	lowPassResults = ALPHA*decibel+(1-ALPHA)*lowPassResults;
    
    OhmSeries = (282.37+calibrationCorrection)*exp(-0.127*lowPassResults);  // Exp
	
    [parser setSymbolValue:OhmSeries forKey:@"R"];
    
    result = [parser evaluate: expression];

	if(isViewVisible && ticks % (int)(updateTime/ALPHA) == 0)  {            // update UI according to updateTime settings
        
        if(lowPassResults <= -2.0 && lowPassResults >= -35.0)
            OhmLabel.textColor = [UIColor whiteColor];
        else if((lowPassResults <= -1.0 && lowPassResults > -2.0) || (lowPassResults >= -45.0 && lowPassResults < -35.0) )
            OhmLabel.textColor = [UIColor yellowColor];
        else if(lowPassResults > -1.0 || lowPassResults < -45.0 )
            OhmLabel.textColor = [UIColor redColor];
 
        if (calibrating) {
            if(lowPassResults <= -10.0 && lowPassResults >= -25.0) {
                dBLowTextView.hidden=YES;
                dBHighTextView.hidden=YES;
                calibrating = NO;
            }
            else if(lowPassResults > -10.0) {
                dBLowTextView.hidden=NO;
                dBHighTextView.hidden=YES;
            }
            else if(lowPassResults < -25.0) {
                dBLowTextView.hidden=YES;
                dBHighTextView.hidden=NO;
            }
        }
        else
        {
            dBLowTextView.hidden=YES;
            dBHighTextView.hidden=YES;            
        }
        
        self.OhmDecimalLabel.textColor = self.OhmLabel.textColor;
        self.equationResultDecimalLabel.textColor = self.OhmLabel.textColor;
        self.equationResultLabel.textColor = self.OhmLabel.textColor;
        
        s = [[NSString alloc] initWithString: @""];
        [OhmDecimalLabel setText: s];
        [s release];
        
        if(lowPassResults > -0.0001 || OhmSeries <= 0.0 || OhmSeries >= 100000000.0 ) {
            s = [[NSString alloc] initWithString: @"-----"];
            self.OhmLabel.text = s;
            [s release];
        }
        else {
            if(OhmSeries < 100000) {
                s = [[NSString alloc]  initWithFormat: @".%.f", (OhmSeries*100-((int)OhmSeries)*100)];
                [OhmDecimalLabel setText: s];
                [s release];
           
                s = [[NSString alloc] initWithFormat: @"%5u",(int)OhmSeries];
            }
            else if(OhmSeries >= 100000 && OhmSeries < 1000000)
                s = [[NSString alloc] initWithFormat: @"%2u.%uk", (int)(OhmSeries/1000), (((int)OhmSeries)%1000)/100];
            else
                s = [[NSString alloc] initWithFormat: @"%2u.%uM", (int)(OhmSeries/1000000), (((int)OhmSeries)%1000000)/100000];
            
            self.OhmLabel.text = s;
            [s release];
        }

        s = [[NSString alloc] initWithString: @""];
        [equationResultDecimalLabel setText: s];
        [s release];
        
        if(lowPassResults > -0.0001 || result >= 100000000.0 || result <= -100000000.0 ) {
            s = [[NSString alloc] initWithString: @"-----"];
            self.equationResultLabel.text = s;
            [s release];
        }
        else {
            if(result < 100000) {
                s = [[NSString alloc]  initWithFormat: @".%.u", abs((int)(result*100-((int)result)*100))];
                [equationResultDecimalLabel setText: s];
                [s release];
                
                s = [[NSString alloc] initWithFormat: @"%5d",(int)result];
            }
            else if(result >= 100000 && result < 1000000)
                s = [[NSString alloc] initWithFormat: @"%2d.%uk", (int)(result/1000), (((int)result)%1000)/100];
            else
                s = [[NSString alloc] initWithFormat: @"%2d.%uM", (int)(result/1000000), (((int)result)%1000000)/100000];
            
            self.equationResultLabel.text = s;
            [s release];
        }
        
        s = [[NSString alloc] initWithFormat: @"%6.2f",lowPassResults];
        self.dBLabel.text = s;
        [s release];
        
        if(volumeChange) {
            volumeUpdates++;
            [dBRangeProgressView setProgress: (abs(lowPassResults)/40.0)];
            if(volumeUpdates == 3) {
                volumeChange = NO;
                volumeUpdates = 0;
            }
        }
        
        if( lowPassResults < -119.0 || lowPassResults > -0.0001)   {           // Audio input limit -120 dB, appears to shut down and require reset
            CFStringRef audioRoute;
            UInt32 size;
            size = sizeof(CFStringRef);
            AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &audioRoute);
            
            if([@"HeadsetInOut" isEqualToString: (NSString *)audioRoute])
                [self initialize];
            return;
        }
    }

    if (!isViewVisible && start && n % (int)(2.0/updateTime) == 0)  			// Execute approximately every 2 seconds
        [notificationCenter postNotificationName: @"DATACHANGE" object: self.data];

    if(start) {
		float currentTime = [recorder currentTime];
		
		if(n==0) {
			collectionTime[n] = 0.0;
			startTime=currentTime;
			self.data.minTime = collectionTime[n];	// alias of:	self.data.dataX = collectionTime
		}
		else {
			if(currentTime-startTime-collectionTime[n-1] < updateTime) return;
			collectionTime[n]=currentTime-startTime;	
		}

		ohms[n] = OhmSeries;					// alias of:	self.data.dataY = ohms

		if(isViewVisible)  {
            NSString *s = [[NSString alloc] initWithFormat: @"%3.2f", collectionTime[n]];
            self.timeLabel.text = s;
            [s release];
		}

		self.data.maxTime = collectionTime[n];
		self.data.endIndex = n;
		
		n++;
		
		if(n==MAXSAMPLES) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum samples recorded." 
															message:@"Email recorded data." 
														   delegate:nil 
												  cancelButtonTitle:@"Continue"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			[self resetButtons]; 	
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
	isViewVisible=YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	isViewVisible=NO;
    [notificationCenter postNotificationName: @"DATACHANGE" object: self.data];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    EquationItem *ei = [ItemsViewController selectedItem];
    NSString *s;
    
    if(ei) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        s = ei.equation==nil ? @"" : ei.equation;
        [standardDefaults setObject: s forKey:@"Equation"];
        s = ei.itemName==nil ? @"" : ei.itemName;
        [standardDefaults setObject: s forKey:@"Name"];
        s = ei.comment==nil ? @"" : ei.comment;
        [standardDefaults setObject: s forKey:@"Comment"];
        
        [standardDefaults synchronize];
        
        expression = ei.equation;
        equationLabel.text = ei.itemName;
        
        self.data.expression = expression;
    }
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)toInterfaceOrientation {
    return  toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	isViewVisible=YES;
    
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.OhmLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.OhmDecimalLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.timeLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.dBLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.equationResultLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    self.equationResultDecimalLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	float calibrationSetting = [defaults floatForKey:@"Calibration"];
	if(calibrationSetting != 0)
		calibrationCorrection = calibrationSetting;

	self.notificationCenter = [NSNotificationCenter defaultCenter];
	
	self.data = nil;
	
	[notificationCenter addObserver: self
						   selector: @selector(updateData:)
							   name: @"DATAREQUEST" 
							 object: nil];
    
    self.OhmLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.OhmLabel.font.pointSize];
    self.OhmDecimalLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.OhmDecimalLabel.font.pointSize];
    self.equationResultDecimalLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.equationResultDecimalLabel.font.pointSize];
    self.equationResultLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.equationResultLabel.font.pointSize];
    self.timeLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.timeLabel.font.pointSize];
    self.dBLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size: self.dBLabel.font.pointSize];

    player = [MPMusicPlayerController iPodMusicPlayer];
    player.volume = 0.5f;
    
	self.audioSession = [AVAudioSession sharedInstance];
	[self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];

	[self.audioSession setDelegate: self];
        
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);

	[self initialize];

	[self startCheck];
    
    parser = [[GCMathParser parser] retain];
    
    //expression = @"(0.001125308852122+0.000234711863267*ln(R)+0.000000085663516*ln(R)^3)^-1-273.15"; //http://www.skyeinstruments.com/wp-content/uploads/Steinhart-Hart-Eqn-for-10k-Thermistors.pdf
    
    equationLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey: @"Name"];
    expression = [[NSUserDefaults standardUserDefaults] stringForKey: @"Equation"];
}

-(IBAction) startStopButton: (id) sender {
	startStopButton = (UIButton *) sender;
	start = !start;
    self.data.newDataSet=start;
    [notificationCenter postNotificationName: @"DATACHANGE" object: self.data];
	[self startCheck];
}

-(IBAction) disappearTextView: (id) sender {
    dBLowTextView.hidden=YES;
    dBHighTextView.hidden=YES;
    calibrating=NO;
}
-(IBAction) saveButton: (id) sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat: calibrationCorrection forKey:@"Calibration"];
}
-(IBAction) higherButton: (id) sender {
    calibrationCorrection = calibrationCorrection+0.1;
    lastCalibrationdB = lowPassResults;
    calibrating = YES;
}
-(IBAction) lowerButton: (id) sender {
    calibrationCorrection = calibrationCorrection-0.1; // .1 for Exp, .005 for Linear
    lastCalibrationdB = lowPassResults;
    calibrating = YES;
}
-(IBAction) muchHigherButton: (id) sender {
    calibrationCorrection = calibrationCorrection+5;   //5 for Exp, .1 for Linear
    lastCalibrationdB = lowPassResults;
    calibrating = YES;
}
-(IBAction) muchLowerButton: (id) sender {
    calibrationCorrection = calibrationCorrection-5;
    lastCalibrationdB = lowPassResults;
    calibrating = YES;
}

-(IBAction) fasterButton: (id) sender {
	if(updateTime-0.1 >= 0.1) updateTime=updateTime - 0.1;
}

-(IBAction) slowerButton: (id) sender {
	if(updateTime < 1.0) updateTime=updateTime + 0.1;
}	

-(IBAction) volumeIncreaseButton: (id) sender {
    player.volume = player.volume + 0.1f;
    calibrating = NO;
    volumeChange = YES;
}

-(IBAction) volumeDecreaseButton: (id) sender {
    player.volume = player.volume - 0.1f;
    calibrating = NO;
    volumeChange = YES;
}

-(IBAction) onInfo:(id) sender
{
    InfoViewController *info = [[InfoViewController alloc] init];
    [self presentViewController:info animated:NO completion:nil];       // Display the newly created view window
    [info release];
}

-(IBAction) sendButton: (id) sender {
	if(![MFMailComposeViewController canSendMail]) {
		UIAlertView *cantMailAlert=[[UIAlertView alloc] 
								   initWithTitle:@"Can't mail" 
								   message:@"This device not configured for email."
								   delegate: NULL
								   cancelButtonTitle:@"Dismiss"
								   otherButtonTitles:NULL];
		[cantMailAlert show];
		[cantMailAlert release];
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *fileName = [defaults stringForKey:@"File"];
	if(!fileName)
		fileName = @"Ohmmeter.csv";
	NSString *email = [defaults stringForKey:@"email"];
	NSArray *recipients; 
	if(!email)
		recipients = [[NSArray alloc] initWithObjects: nil];
	else 
		recipients = [[NSArray alloc] initWithObjects: email, nil];
	
	NSMutableString *string = [[NSMutableString alloc] init];
	[string appendFormat:@"%@ %@\n",@"time, Ohms, ", equationLabel.text];
	
	for(int i=0;i<n;i++) {
        [parser setSymbolValue: ohms[i] forKey:@"R"];
        
 		[string appendFormat:@"%f,%f, %f\n",collectionTime[i], ohms[i], [parser evaluate: expression]];
    }
	
	NSData* csvData;
	csvData = [string dataUsingEncoding: NSASCIIStringEncoding];
	
	MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailController setSubject:@"Ohmmeter data"];
	[mailController setToRecipients:recipients];
	[mailController setCcRecipients:nil];
	[mailController setBccRecipients:nil];
	[mailController setMessageBody:nil isHTML:NO];
	[mailController addAttachmentData:csvData mimeType:@"text/csv" fileName: fileName];
	mailController.mailComposeDelegate=self;
	[self presentModalViewController:mailController animated:YES];
	[string release];
	[recipients release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}

-(void) updateData: (NSNotification *) notification { 
	if(self.data == nil) return;
	[notificationCenter postNotificationName: @"DATACHANGE" object: self.data];		
}

- (void)didReceiveMemoryWarning {
	if(self.levelTimer) {
		[self.levelTimer invalidate];
		self.levelTimer = nil;
	}

	if(recorder) {
		if([recorder isRecording]) {
			[recorder stop];
		}
		[recorder release];
	}
	
	if( m_bleepMachine) 
		delete m_bleepMachine;

	if(audioSession) [audioSession release];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low memory warning." 
													message:@"Email recorded data and exit." 
                                                    delegate:nil 
                                                    cancelButtonTitle:@"Continue"
                                                    otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self resetButtons];
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {}

- (void)dealloc {
	if(recorder) [recorder release];
	if(m_bleepMachine) delete m_bleepMachine;
	if(levelTimer) [levelTimer invalidate];
	if(data) [data release];
	if(audioSession) [audioSession release];
	[notificationCenter release];
    if(parser) [parser release];

    [super dealloc];
}

@end
