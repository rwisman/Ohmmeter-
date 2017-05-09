#define MAXSAMPLES	172800

@interface Data  : NSObject {
	float			minX, maxX, minY, maxY;
	int				startIndex, endIndex;
	Boolean			newDataSet;
	float			*dataX, *dataY; 
}

@property(readwrite, nonatomic) float minX; 
@property(readwrite, nonatomic) float maxX;
@property(readwrite, nonatomic) float minY;
@property(readwrite, nonatomic) float maxY;
@property(readwrite, nonatomic) float minTime;
@property(readwrite, nonatomic) float maxTime;
@property(readwrite, nonatomic) int startIndex;
@property(readwrite, nonatomic) int endIndex;
@property(readwrite, nonatomic) Boolean newDataSet;
@property(readwrite, nonatomic) float *dataX;
@property(readwrite, nonatomic) float *dataY;
@property(readwrite, nonatomic, retain) NSString *expression;
@end

