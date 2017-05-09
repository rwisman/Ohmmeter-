//
//  AppDelegate.m
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//
//  Modified by Ray Wisman on July 31, 2010.
//                            July 21, 2013
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		[window setFrame: CGRectMake(0, 0, 320, 480)];
	}else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[window setFrame: CGRectMake(0, 0, 768, 1024)];
	}
	
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults registerDefaults:@{@"Name" : @"Ohms", @"Equation" : @"R",  @"Comment":@"None"}];
    [standardDefaults synchronize];

    
    // View Controllers for tabController (one viewController per tab)
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    NSArray *currentControllers = [tabBarController viewControllers];
    
    [viewControllers addObject: [currentControllers objectAtIndex:0]];
    [viewControllers addObject: [currentControllers objectAtIndex:1]];
 
    ItemsViewController *thirdView = [[ItemsViewController alloc] init];
    UINavigationController *navController = [[ UINavigationController alloc] initWithRootViewController: thirdView];
    [thirdView release];

    [viewControllers addObject:navController];
    
    [tabBarController setViewControllers:viewControllers];

    [window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
    
    [viewControllers release];
    [tabBarController release];
    [navController release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
/*    BOOL success = [[EquationItemStore sharedStore] saveChanges];
    if(success) {
        NSLog(@"Saved all of the EquationItems");
    } else {
        NSLog(@"Could not save any of the EquationItems");
    }
 */
}

-(void)dealloc {
    [window release];
    [super dealloc];
}

@end

