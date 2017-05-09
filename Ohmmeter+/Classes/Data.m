//
//  Created by Ray Wisman on Aug 11, 2010.
//

#import "Data.h"

@implementation Data

@synthesize dataX;
@synthesize dataY;
@synthesize minX;
@synthesize maxX;
@synthesize minY;
@synthesize maxY;
@synthesize minTime;
@synthesize maxTime;
@synthesize newDataSet;
@synthesize startIndex;
@synthesize endIndex;

- (void)dealloc {
    [super dealloc];
}

@end
