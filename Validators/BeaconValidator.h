//
//  BeaconValidator.h
//

#import <Foundation/Foundation.h>

@interface BeaconValidator : NSObject

/**
 * Check a string is a valid UUID
 */
-(BOOL)isValidUUID: (NSString *)UUIDString;

/**
 * Check a string is a numeric value
 */
-(BOOL)isValidInt: (NSString *)numericString;

@end
