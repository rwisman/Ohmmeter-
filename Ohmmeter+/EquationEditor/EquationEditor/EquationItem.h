//
//  EquationItem.h
//  OhmConvertor
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EquationItem : NSManagedObject

@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * equation;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic) BOOL selected;
@end
