#import "CorePlot-CocoaTouch.h"
#import "Data.h"
#import "GCMathParser.h"

#define numberDataPointstoPlot	250
#define interval	(int)((end-start) / numberDataPointstoPlot + 1)		

@interface PlotController : UIViewController <CPPlotDataSource>
{
	CPXYGraph *graph;
	
	float *yData, *xData;
	
	int start, end;
	
	IBOutlet UISlider *startSlider, *endSlider;
    IBOutlet UIButton *ohmButton, *functionButton;

	Data *data;
	
	NSNotificationCenter *notificationCenter;
	
	Boolean sizeChanged, plotData;

	BOOL isViewVisible;
    
    NSString * expression;

    GCMathParser*	parser;
}

@property (nonatomic, assign) IBOutlet UISlider *startSlider;
@property (nonatomic, assign) IBOutlet UISlider *endSlider;
@property (nonatomic, assign) IBOutlet UIButton *ohmButton;
@property (nonatomic, assign) IBOutlet UIButton *functionButton;

@property(readwrite, nonatomic) float *xData;
@property(readwrite, nonatomic) float *yData;
@property(readwrite, nonatomic) int start;
@property(readwrite, nonatomic) int end;
@property(readwrite, nonatomic) Boolean sizeChanged;
@property(readwrite, nonatomic) Boolean plotOhm, plotFunction;

@property(readwrite, assign, nonatomic) NSNotificationCenter *notificationCenter;
@property(readwrite, assign, nonatomic) Data *data;
@property(readwrite, assign, nonatomic) NSString * expression;
@property(readwrite, retain, nonatomic) CPScatterPlot *ohmPlot, *functionPlot;

-(IBAction) endSizeSliderAction: (id) sender;
-(IBAction) startSizeSliderAction: (id) sender;
-(IBAction) startSizeSliderAction: (id) sender;
-(IBAction) toggleOhmButton: (id) sender;
-(IBAction) toggleFunctionButton: (id) sender;
-(void) updatePlot;

@end
