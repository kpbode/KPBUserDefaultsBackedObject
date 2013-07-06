#import "KPBUserDefaultsBackedObject.h"

@interface KPBAppPreferences : KPBUserDefaultsBackedObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL hasInitialized;
@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) short bla;

@end
