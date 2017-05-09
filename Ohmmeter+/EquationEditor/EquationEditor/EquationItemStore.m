//
//  EquationItemStore.m
//  OhmConvertor
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EquationItemStore.h"
#import "EquationItem.h"

@implementation EquationItemStore

+ (EquationItemStore *)sharedStore
{
    static EquationItemStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
        
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init 
{
    self = [super init];
    if(self) {                
        // Read in OhmConvertor.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog(@"model = %@", model);
        
        NSPersistentStoreCoordinator *psc = 
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?    
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;

        if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]] ) {
            // If there’s no Data Store present (which is the case when the app first launches),
            // identify the sqlite file we added in the
            // Bundle Resources, copy it into the Documents directory, and make it the Data Store.
            NSString *sqlitePath = [[NSBundle mainBundle] pathForResource:@"OhmConvertor" ofType:@"sqlite" inDirectory: nil];
//            NSString *sqlitePath = [[NSBundle mainBundle] pathForResource: @”App_Name” ofType: @”sqlite” inDirectory: nil];
            [[NSFileManager defaultManager] copyItemAtPath:sqlitePath toPath:[storeURL path] error:&error];
        }
       
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType 
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAllItems];        
    }
    return self;
}
/*
 if (__persistentStoreCoordinator != nil) {
 return__persistentStoreCoordinator;
 }
 NSURL *storeURL = [[selfapplicationDocumentsDirectory] URLByAppendingPathComponent:@”App_Name.sqlite”];
 
 // Add the below code
 // Check if a data store already exists in the documents directory.
 
 if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]] ) {
 // If there’s no Data Store present (which is the case when the app first launches), identify the sqlite file we added in the
 // Bundle Resources, copy it into the Documents directory, and make it the Data Store.
    NSString *sqlitePath = [[NSBundle mainBundle] pathForResource:@”App_Name” ofType:@”sqlite” inDirectory:nil];
    NSError *anyError = nil;
    BOOL success = [[NSFileManager defaultManager]
    copyItemAtPath:sqlitePath toPath:[storeURL path] error:&anyError];
 */

- (void)loadAllItems 
{
    if (!allItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"EquationItem"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor 
                                sortDescriptorWithKey:@"itemName"
                                ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask, YES);
 
       // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];

    return [documentDirectory stringByAppendingPathComponent:@"OhmConvertor.sqlite"];
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

- (void)removeItem:(EquationItem *)p
{
    [context deleteObject:p];
    [allItems removeObjectIdenticalTo:p];
}

- (NSArray *)allItems
{
    return allItems;
}

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    EquationItem *p = [allItems objectAtIndex:from];

    // Remove p from array
    [allItems removeObjectAtIndex:from];

    // Insert p in array at new location
    [allItems insertObject:p atIndex:to];
}

- (EquationItem *)createItem
{
    EquationItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"EquationItem"
                                                inManagedObjectContext:context];
    
    [allItems addObject:p];
   
    return p;
}
@end
