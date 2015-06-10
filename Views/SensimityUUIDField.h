//
//  SensimityUUIDField.h
//

#import <Foundation/Foundation.h>
#import "MPGTextField.h"

@interface SensimityUUIDField : MPGTextField

/**
 *  The bottom border layer
 */
@property (strong, nonatomic) CALayer* bottomBorder;

/**
 *  Function to set the regular border color, it is a darkgrey color
 */
- (void) setRegularBorderColor;

/**
 * Function to set the red border color to identify the value was wrong
 */
- (void) setErrorBorderColor;

/**
 *  Refresh the array which delivers the autocomplete data
 */
- (void) refreshAutoCompleteArray;

/**
 *  Get the autocomplete array
 *
 *  @return autoCompletedArray
 */
- (NSArray *) getAutoCompleteArray;

@end
