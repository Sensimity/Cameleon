//
//  SensimityUUIDField.m
//  Sensimity Chameleon
//
//  Created by William Rijksen on 09-06-15.
//  Copyright (c) 2015 Sensimity. All rights reserved.
//

#import "SensimityUUIDField.h"

@implementation SensimityUUIDField

// Add a orange border to the textfields
- (void)drawRect:(CGRect)rect {
    _bottomBorder = [CALayer layer];
    _bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 1, self.frame.size.width, 1.0f);
    _bottomBorder.backgroundColor = [UIColor colorWithRed:0.255 green:0.259 blue:0.255 alpha:1].CGColor;
    [self.layer addSublayer:_bottomBorder];
}

// Set regular Sensimity brown color bottom border
- (void) setRegularBorderColor {
    _bottomBorder.backgroundColor = [UIColor colorWithRed:0.255 green:0.259 blue:0.255 alpha:1].CGColor;
}

// Set error red color bottom border
- (void) setErrorBorderColor {
    _bottomBorder.backgroundColor = [UIColor redColor].CGColor;
}

@end