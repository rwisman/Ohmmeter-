//
//  EquationItem.m
//  OhmConvertor
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EquationItem.h"


@implementation EquationItem

@dynamic itemName;
@dynamic comment;
@dynamic equation;
@dynamic dateCreated;
@dynamic selected;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
    [self setDateCreated:t];
}

@end
