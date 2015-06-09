//
//  SensimityUUIDField.h
//

#import <Foundation/Foundation.h>
#import "MPGTextField.h"

@interface SensimityUUIDField : MPGTextField<MPGTextFieldDelegate, UITextFieldDelegate>

@property (strong, nonatomic) CALayer* bottomBorder;

- (void) setRegularBorderColor;
- (void) setErrorBorderColor;
- (void) refreshAutoCompleteArray;

@end
