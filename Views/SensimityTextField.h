//
//  SensimityTextField.h
//

#import <UIKit/UIKit.h>

@interface SensimityTextField : UITextField

@property (strong, nonatomic) CALayer* bottomBorder;

- (void) setRegularBorderColor;
- (void) setErrorBorderColor;

@end
