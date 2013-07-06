//
//  KPBAppDelegate.m
//  KPBUserDefaultsBackedObjectTests
//
//  Created by Karl on 7/6/13.
//  Copyright (c) 2013 Karl Bode. All rights reserved.
//

#import "KPBAppDelegate.h"

@implementation KPBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
