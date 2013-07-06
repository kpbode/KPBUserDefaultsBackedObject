#import "KPBUserDefaultsBackedObject.h"
#import <objc/runtime.h>

@interface KPBUserDefaultsBackedObject ()

@property (nonatomic, copy) NSString *uniqueIdentifier;

- (NSString *)objectKey;

@end

static NSString * const SharedObjectKey = @"SharedObject";

@interface NSUserDefaults (KPBUserDefaultsBackedObjectAdditions)

- (id)objectForKey:(NSString *)key forUserDefaultsBackedObject:(KPBUserDefaultsBackedObject *)userDefaultsBackedObject;

- (void)setObject:(id)value forKey:(NSString *)key forUserDefaultsBackedObject:(KPBUserDefaultsBackedObject *)userDefaultsBackedObject;

@end

@implementation NSUserDefaults (KPBUserDefaultsBackedObjectAdditions)

- (id)objectForKey:(NSString *)key forUserDefaultsBackedObject:(KPBUserDefaultsBackedObject *)userDefaultsBackedObject {
    
    if (key == nil) return nil;
    
    NSString *classObjectsContainerKey = NSStringFromClass([userDefaultsBackedObject class]);
    NSMutableDictionary *classObjectsContainer = [[self objectForKey:classObjectsContainerKey] mutableCopy];
    if (classObjectsContainer == nil) return nil;
    
    NSString *objectKey = userDefaultsBackedObject.objectKey;
    NSMutableDictionary *container = classObjectsContainer[objectKey];
    if (container == nil) return nil;
    
    return container[key];
}

- (void)setObject:(id)value forKey:(NSString *)key forUserDefaultsBackedObject:(KPBUserDefaultsBackedObject *)userDefaultsBackedObject {
    
    if (key == nil) return;
    
    NSString *classObjectsContainerKey = NSStringFromClass([userDefaultsBackedObject class]);
    NSMutableDictionary *classObjectsContainer = [[self objectForKey:classObjectsContainerKey] mutableCopy];
    if (classObjectsContainer == nil) {
        classObjectsContainer = [NSMutableDictionary dictionary];
    }
    
    NSString *objectKey = userDefaultsBackedObject.objectKey;
    NSMutableDictionary *container = [classObjectsContainer[objectKey] mutableCopy];
    if (container == nil) {
        container = [NSMutableDictionary dictionary];
    }
    
    if (value == nil) {
        [container removeObjectForKey:key];
    } else {
        container[key] = value;
    }
    
    [classObjectsContainer setObject:container forKey:objectKey];
    [self setObject:classObjectsContainer forKey:classObjectsContainerKey];
    [self synchronize];
}

@end



@implementation KPBUserDefaultsBackedObject

+ (instancetype)sharedObject {
    static KPBUserDefaultsBackedObject *sharedObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[[self class] alloc] init];
    });
    return sharedObject;
}

id dynamicGetter(id self, SEL _cmd) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = NSStringFromSelector(_cmd);
    return [userDefaults objectForKey:key forUserDefaultsBackedObject:self];
}

void dynamicSetter(id self, SEL _cmd, id value) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [[self class] propertyNameForSelector:_cmd];
    [userDefaults setObject:value forKey:key forUserDefaultsBackedObject:self];
}

NSInteger dynamicIntegerGetter(id self, SEL _cmd) {
    return [dynamicGetter(self, _cmd) integerValue];
}

void dynamicIntegerSetter(id self, SEL _cmd, NSInteger value) {
    dynamicSetter(self, _cmd, @(value));
}

char dynamicCharGetter(id self, SEL _cmd) {
    return [dynamicGetter(self, _cmd) charValue];
}

void dynamicCharSetter(id self, SEL _cmd, char value) {
    dynamicSetter(self, _cmd, @(value));
}

float dynamicFloatGetter(id self, SEL _cmd) {
    return [dynamicGetter(self, _cmd) floatValue];
}

void dynamicFloatSetter(id self, SEL _cmd, float value) {
    dynamicSetter(self, _cmd, @(value));
}

double dynamicDoubleGetter(id self, SEL _cmd) {
    return [dynamicGetter(self, _cmd) doubleValue];
}

void dynamicDoubleSetter(id self, SEL _cmd, double value) {
    dynamicSetter(self, _cmd, @(value));
}

short dynamicShortGetter(id self, SEL _cmd) {
    return [dynamicGetter(self, _cmd) shortValue];
}

void dynamicShortSetter(id self, SEL _cmd, short value) {
    dynamicSetter(self, _cmd, @(value));
}

BOOL isSetter(SEL selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    return [selectorString hasPrefix:@"set"];
}

+ (NSString *)propertyNameForSelector:(SEL)selector {
    NSString *selectorString = NSStringFromSelector(selector);
    if (!isSetter(selector)) return selectorString;
    
    NSMutableString *propertyName = [selectorString mutableCopy];
    
    [propertyName deleteCharactersInRange:NSMakeRange(propertyName.length - 1, 1)];
    [propertyName deleteCharactersInRange:NSMakeRange(0, 3)];
    NSString *firstCharacter = [[propertyName substringToIndex:1] lowercaseString];
    [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    
    return propertyName;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    NSString *propertyType;
    
    objc_property_t property = class_getProperty([self class], [[[self class] propertyNameForSelector:sel] UTF8String]);
    NSString *propertyAttributesString = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSArray *propertyAttributes = [propertyAttributesString componentsSeparatedByString:@","];
    for (NSString *propertyAttribute in propertyAttributes) {
        if ([propertyAttribute hasPrefix:@"T"]) {
            propertyType = [propertyAttribute substringFromIndex:1];
        }
    }
    
    BOOL setter = isSetter(sel);
    
    IMP implementation;
    NSString *typesString;
    
    if ([@"i" isEqualToString:propertyType]) {
        implementation = setter ? (IMP) dynamicIntegerSetter : (IMP) dynamicIntegerGetter;
        typesString = setter ? @"v@:i" : @"i@:";
    } else if ([@"c" isEqualToString:propertyType]) {
        implementation = setter ? (IMP) dynamicCharSetter : (IMP) dynamicCharGetter;
        typesString = setter ? @"v@:c" : @"i@:";
    } else if ([@"f" isEqualToString:propertyType]) {
        implementation = setter ? (IMP) dynamicFloatSetter : (IMP) dynamicFloatGetter;
        typesString = setter ? @"v@:f" : @"i@:";
    } else if ([@"d" isEqualToString:propertyType]) {
        implementation = setter ? (IMP) dynamicDoubleSetter : (IMP) dynamicDoubleGetter;
        typesString = setter ? @"v@:d" : @"i@:";
    } else if ([@"s" isEqualToString:propertyType]) {
        implementation = setter ? (IMP) dynamicShortSetter : (IMP) dynamicShortGetter;
        typesString = setter ? @"v@:s" : @"s@:";
    } else {
        implementation = setter ? (IMP) dynamicSetter : (IMP) dynamicGetter;
        typesString = setter ? @"v@:@" : @"@@:";
    }
    
    class_addMethod(self, sel, implementation, [typesString UTF8String]);

    return YES;
}

- (id)initWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    self = [super init];
    if (self) {
        self.uniqueIdentifier = uniqueIdentifier;
    }
    return self;
}

- (NSString *)objectKey {
    
    if (self.uniqueIdentifier == nil) return SharedObjectKey;
    
    return self.uniqueIdentifier;
}

@end
