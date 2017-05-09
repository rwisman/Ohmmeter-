//
//  AppDelegate.h
//  CPTestApp-iPhone
//
//  Toolbar icons in the application are courtesy of Joseph Wain / glyphish.com
//  See the license file in the GlyphishIcons directory for more information on these icons

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>
#import "EquationItemStore.h"
#import "ItemsViewController.h"


@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
