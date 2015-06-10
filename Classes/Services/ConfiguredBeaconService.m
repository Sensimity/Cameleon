//
//  ConfiguredBeaconService.m
//

#import "ConfiguredBeaconService.h"
#import "AppDelegate.h"

@implementation ConfiguredBeaconService

#pragma mark - Custom Accessors

/**
 *  Get all previous configured beaconsettings from Core Data
 *
 *  @return NSArray with all used beaconConfigurations
 */
- (NSArray *)getAllConfiguredBeacons {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConfiguredBeacon" inManagedObjectContext:context];
    NSDictionary *entityProperties = [entity propertiesByName];
    fetchRequest.entity = entity;
    fetchRequest.propertiesToFetch  = [NSArray arrayWithObject:[entityProperties objectForKey:@"uuid"]];
    // Return latest added configuration first
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
    return [context executeFetchRequest:fetchRequest error:nil];
}

/**
 *  Save a beaconConfiguration
 *
 *  @param uuid        the uuid of a beacon
 *  @param majorNumber the majornumber of a beacon
 *  @param minorNumber the minornumber of a beacon
 */
- (void)save:(NSString *)uuid major:(NSInteger)majorNumber minor:(NSInteger)minorNumber {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"ConfiguredBeacon" inManagedObjectContext:context];

    [entity setValue:uuid forKey:@"uuid"];
    [entity setValue:[NSNumber numberWithInteger:majorNumber] forKey:@"major"];
    [entity setValue:[NSNumber numberWithInteger:minorNumber] forKey:@"minor"];
    [entity setValue:[[NSDate alloc] init] forKey:@"date"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end
