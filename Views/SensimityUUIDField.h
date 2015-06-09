//
//  SensimityUUIDField.h
//

#import <Foundation/Foundation.h>
#import "MPGTextField.h"

@interface SensimityUUIDField : MPGTextField

@property (strong, nonatomic) CALayer* bottomBorder;

- (void) setRegularBorderColor;
- (void) setErrorBorderColor;

@end
