//
//  SensimityTextField.h
//

#import <UIKit/UIKit.h>
#import "MPGTextField.h"

@interface SensimityTextField : UITextField

@property (strong, nonatomic) CALayer* bottomBorder;

- (void) setRegularBorderColor;
- (void) setErrorBorderColor;

@end
