//
//  SensimityTextField.m
//

#import "SensimityTextField.h"

@implementation SensimityTextField

// Add a orange border to the textfields
- (void)drawRect:(CGRect)rect {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 1, self.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1].CGColor;
    [self.layer addSublayer:bottomBorder];
}

@end
