//
//  AppDelegate.m
//  TipCalculator
//
//  Created by  Minett on 9/26/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "AppDelegate.h"
#import "TipViewController.h"
#import "TipThemeSettings.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    TipViewController *tipController = [[TipViewController alloc] init];
    UINavigationController *tipNavigationController = [[UINavigationController alloc] initWithRootViewController:tipController];
    self.window.rootViewController = tipNavigationController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate alloc] init] forKey:kBillAmountCacheTimeKey];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:kThemeKey] isEqualToString:kDarkThemeIdentifier]) {
        [TipThemeSettings setDarkTheme];
        [defaults setObject:kDarkThemeIdentifier forKey:kThemeKey];
    } else {
        [TipThemeSettings setDefaultTheme];
        [defaults setObject:kDefaultThemeIdentifier forKey:kThemeKey];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate alloc] init] forKey:kBillAmountCacheTimeKey];
}

@end
