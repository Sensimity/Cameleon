//
// UIColor+ColorExtensions.m
//

#import "UIColor+ColorExtensions.h"

@implementation UIColor (ColorExtensions)

+ (UIColor *) sensimityErrorRedColor
{
    return [UIColor redColor];
}

+ (UIColor *) sensimityGreyColor
{
    return [UIColor colorWithRed:0.255 green:0.259 blue:0.255 alpha:1];
}

+ (UIColor *) sensimityBackgroundColor
{
    return [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
}

+ (UIColor *) sensimityYellowColor
{
    return [UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1];
}

+ (UIColor *) sensimityBrownColor
{
    return [UIColor colorWithRed:0.325 green:0.337 blue:0.353 alpha:1];
}

@end
