#import "KPBUserDefaultsBackedObjectTestsTests.h"
#import "KPBAppPreferences.h"

@implementation KPBUserDefaultsBackedObjectTestsTests

- (void)setUp
{
    [super setUp];

    KPBAppPreferences *preferences = [KPBAppPreferences sharedObject];
    preferences.name = @"Hans Wurst";
    preferences.count = 12;
    preferences.hasInitialized = YES;
    preferences.floatValue = 1.3f;
    preferences.doubleValue = 2.121212;
    preferences.size = CGSizeMake(200.f, 300.f);
    preferences.bla = 1;
    
}

- (void)testExample
{
    
    KPBAppPreferences *preferences = [KPBAppPreferences sharedObject];
    STAssertNotNil(preferences, @"sharedObject should not be nil");
    
    STAssertEqualObjects(@"Hans Wurst", preferences.name, @"");
    STAssertEquals(12, preferences.count, @"");
    STAssertEquals(YES, preferences.hasInitialized, @"");
    STAssertEquals(1.3f, preferences.floatValue, @"");
    STAssertEquals(2.121212, preferences.doubleValue, @"");
    
    STAssertEquals(200.f, preferences.size.width, @"");
    STAssertEquals(300.f, preferences.size.height, @"");
    
    STAssertEquals((short) 1, preferences.bla, @"");
    
}

@end
