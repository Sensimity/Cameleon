//
//  BeaconValidator.m
//

#import "BeaconValidator.h"

@implementation BeaconValidator

#pragma mark - Validators

/**
 *  Check a string is a valid UUID
 *
 *  @param UUIDString The string must be validated
 *
 *  @return YES if uuid is valid, otherwise it returns NO
 */
-(BOOL)isValidUUID: (NSString *)UUIDString
{
    NSUUID* UUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    if(UUID)
        return YES;
    else
        return NO;
}

/**
 *  Validator to check a String is an integer
 *
 *  @param numericString The stringing must be validated
 *
 *  @return YES if numericstring is an int, otherwise it returns NO
 */
-(BOOL)isValidInt: (NSString *)numericString
{
    if ([numericString isEqualToString:@"0"]) {
        return YES;
    } else if ([numericString intValue] == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
