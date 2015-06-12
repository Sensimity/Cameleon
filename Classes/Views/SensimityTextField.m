//
//  SensimityTextField.m
//

#import "SensimityTextField.h"
#import "UIColor+ColorExtensions.h"

@implementation SensimityTextField

#pragma mark - Lifecycles

/**
 *  Add a orange border to the textfields
 *
 *  @param rect The rect which should be drawn
 */
- (void)drawRect:(CGRect)rect {
    self.bottomBorder = [CALayer layer];
    self.bottomBorder.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1.0f);
    self.bottomBorder.backgroundColor = [UIColor sensimityGreyColor].CGColor;
    [self.layer addSublayer:self.bottomBorder];
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

@end
