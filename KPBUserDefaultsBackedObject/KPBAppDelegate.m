#import "KPBAppDelegate.h"
#import "KPBAppPreferences.h"

@implementation KPBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    KPBAppPreferences *preferences = [KPBAppPreferences sharedObject];
    if (preferences.name == nil) {
        preferences.name = @"Hans Wurst";
    }
    
    NSLog(@"name: %@", preferences.name);
    
    KPBAppPreferences *preferences1 = [[KPBAppPreferences alloc] initWithUniqueIdentifier:@"sample_prefs"];
    if (preferences1.name == nil) {
        preferences1.name = @"Peter Pan";
    }
    
    NSLog(@"name: %@", preferences1.name);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
