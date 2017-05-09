#import "DataPlotController.h"

@implementation DataPlotController

-(void) updatePlot: (NSNotification *) notification { 
	
	self.data = (Data *)[ notification object ];
	self.xData = data.dataX;
	self.yData = data.dataY;
    self.expression = data.expression;
	
//    NSLog(@"1. self.data.newDataSet %x sizeChanged %x",self.data.newDataSet,sizeChanged);
    if(self.data.newDataSet)
        sizeChanged=NO;
//    NSLog(@"2. self.data.newDataSet %x sizeChanged %x",self.data.newDataSet,sizeChanged);
	[self updatePlot ];
}

@end
