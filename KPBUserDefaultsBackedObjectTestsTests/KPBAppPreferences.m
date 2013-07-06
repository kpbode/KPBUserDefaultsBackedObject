#import "KPBAppPreferences.h"

@interface KPBAppPreferences ()

@property (nonatomic, strong) NSData *sizeData;

@end

@implementation KPBAppPreferences

@dynamic name;
@dynamic count;
@dynamic hasInitialized;
@dynamic floatValue;
@dynamic doubleValue;
@dynamic size; @dynamic sizeData;
@dynamic bla;

- (CGSize)size
{
    return *(CGSize *) self.sizeData.bytes;
}

- (void)setSize:(CGSize)size
{
    self.sizeData = [NSData dataWithBytes:&size length:sizeof(CGSize)];
}

@end
