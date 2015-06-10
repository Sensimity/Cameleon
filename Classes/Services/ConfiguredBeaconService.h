//
//  ConfiguredBeaconService.h
//

#import <Foundation/Foundation.h>

@interface ConfiguredBeaconService : NSObject

/**
 *  Get all previous configured beaconsettings from Core Data
 *
 *  @return NSArray with all used beaconConfigurations
 */
- (NSArray *)getAllConfiguredBeacons;

/**
 *  Save a beaconConfiguration
 *
 *  @param uuid        the uuid of a beacon
 *  @param majorNumber the majornumber of a beacon
 *  @param minorNumber the minornumber of a beacon
 */
- (void)save:(NSString *)uuid major:(NSInteger)majorNumber minor:(NSInteger)minorNumber;

@end
