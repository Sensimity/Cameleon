//
//  SensimityUUIDField.m
//

#import "SensimityUUIDField.h"
#import "AppDelegate.h"
#import "ConfiguredBeaconService.h"
#import "UIColor+ColorExtensions.h"

@interface SensimityUUIDField ()

/**
 *  The array which contains the autocomplete data
 */
@property (strong, nonatomic) NSMutableArray *autoCompleteArray;

@end

@implementation SensimityUUIDField

#pragma mark - Lifecycle

// Add a orange border to the textfields
- (void)drawRect:(CGRect)rect {
    self.bottomBorder = [CALayer layer];
    self.bottomBorder.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1.0f);
    self.bottomBorder.backgroundColor = [UIColor sensimityGreyColor].CGColor;
    [self.layer addSublayer:self.bottomBorder];
    [self refreshAutoCompleteArray];
}

#pragma mark - Custom Accessors

/**
 *  Function to set the regular border color, it is a darkgrey color
 */
- (void) setRegularBorderColor {
    self.bottomBorder.backgroundColor = [UIColor sensimityGreyColor].CGColor;
}

/**
 * Function to set the red border color to identify the value was wrong
 */
- (void) setErrorBorderColor {
    self.bottomBorder.backgroundColor = [UIColor sensimityErrorRedColor].CGColor;
}

/**
 *  Get the autocomplete array
 *
 *  @return autoCompletedArray
 */
- (NSArray *) getAutoCompleteArray {
    return self.autoCompleteArray;
}

#pragma mark - Public

/**
 *  Refresh the array which delivers the autocomplete data
 */
- (void) refreshAutoCompleteArray {
    ConfiguredBeaconService* configuredBeaconService = [[ConfiguredBeaconService alloc] init];
    self.autoCompleteArray = [[NSMutableArray alloc] init];
    for (NSManagedObject* object in [configuredBeaconService getAllConfiguredBeacons]) {
        NSDictionary *autoCompleteItem = [NSDictionary dictionaryWithObjectsAndKeys:[object valueForKey:@"uuid"], @"DisplayText", nil];
        if (![self.autoCompleteArray containsObject:autoCompleteItem]) {
            [self.autoCompleteArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[object valueForKey:@"uuid"], @"DisplayText", nil]];
        }
    }
}

@end