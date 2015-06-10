//
//  BeaconValidator.h
//

#import <Foundation/Foundation.h>

@interface BeaconValidator : NSObject

/**
 *  Check a string is a valid UUID
 *
 *  @param UUIDString The string must be validated
 *
 *  @return YES if uuid is valid, otherwise it returns NO
 */
-(BOOL)isValidUUID: (NSString *)UUIDString;

/**
 *  Validator to check a String is an integer
 *
 *  @param numericString The stringing must be validated
 *
 *  @return YES if numericstring is an int, otherwise it returns NO
 */
-(BOOL)isValidInt: (NSString *)numericString;

@end
