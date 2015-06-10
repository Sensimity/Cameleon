//
//  SensimityTextField.h
//

#import <UIKit/UIKit.h>
#import "MPGTextField.h"

@interface SensimityTextField : UITextField<UIGestureRecognizerDelegate>

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

@end
