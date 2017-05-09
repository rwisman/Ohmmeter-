//
//  EquationItemStore.h
//  OhmConvertor
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EquationItem;

@interface EquationItemStore : NSObject
{
    NSMutableArray *allItems;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (EquationItemStore *)sharedStore;

- (void)removeItem:(EquationItem *)p;

- (NSArray *)allItems;

- (EquationItem *)createItem;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges;

- (void)loadAllItems;

@end
