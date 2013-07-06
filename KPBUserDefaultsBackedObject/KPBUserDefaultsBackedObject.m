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
        [classObjectsContainer setObject:container forKey:objectKey];
    }
    
    if (value == nil) {
        [container removeObjectForKey:key];
    } else {
        container[key] = value;
    }
    
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

id automaticGetter(id self, SEL _cmd) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = NSStringFromSelector(_cmd);
    
    return [userDefaults objectForKey:key forUserDefaultsBackedObject:self];
}

void automaticSetter(id self, SEL _cmd, id value) {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *key = [NSStringFromSelector(_cmd) mutableCopy];
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    NSString *firstCharacter = [[key substringToIndex:1] lowercaseString];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    
    [userDefaults setObject:value forKey:key forUserDefaultsBackedObject:self];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selector = NSStringFromSelector(sel);
    if ([selector hasPrefix:@"set"]) {
        class_addMethod(self, sel, (IMP) automaticSetter, "v@:@");
    } else {
        class_addMethod(self, sel, (IMP) automaticGetter, "@@:");
    }
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
