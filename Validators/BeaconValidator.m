//
//  BeaconValidator.m
//

#import "BeaconValidator.h"

@implementation BeaconValidator

/**
 * Check a string is a valid UUID
 */
-(BOOL)isValidUUID: (NSString *)UUIDString
{
    NSUUID* UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    if(UUID)
        return true;
    else
        return false;
}

/**
 * Check a string is a numeric value
 */
-(BOOL)isValidInt: (NSString *)numericString
{
    if ([numericString isEqualToString:@"0"]) {
        return 1;
    } else if ([numericString intValue] == 0) {
        return 0;
    } else {
        return 1;
    }
}

@end
