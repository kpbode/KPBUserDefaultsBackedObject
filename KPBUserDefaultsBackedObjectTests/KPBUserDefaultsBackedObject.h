#import <Foundation/Foundation.h>

@interface KPBUserDefaultsBackedObject : NSObject

/**
 
 Delivers a single object which is stored as class name -> sharedObject
 
 **/
+ (instancetype)sharedObject;

/**
 
 Delivery an object which is stored as class name -> uniqueIdentifier
 
 **/
- (id)initWithUniqueIdentifier:(NSString *)uniqueIdentifier;

@end
