//
//  TipThemeSettings.m
//  TipCalculator
//
//  Created by  Minett on 10/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "TipThemeSettings.h"

NSString *const kThemeKey = @"DefaultThemeKey";
NSString *const kDefaultThemeIdentifier = @"DefaultThemeId";
NSString *const kDarkThemeIdentifier = @"DarkThemeId";

@implementation TipThemeSettings
    static UIColor *kMainBackgroundColor;
    static UIColor *kMainLabelColor;
    static UIColor *kSegmentControlColor;
    static UIColor *kLineSeparatorColor;
    static UIColor *kTextInputColor;
    static UIColor *kTextBackgroundColor;
    static UIColor *kCellBackgroundColor;
    static UIColor *kTableBackgroundColor;

+ (void)setDefaultTheme {
    kMainBackgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    kMainLabelColor = [[UIColor alloc] initWithRed:0.0 green:0.38 blue:0.48 alpha:1];
    kSegmentControlColor = [[UIColor alloc] initWithRed:0.0 green:0.38 blue:0.48 alpha:1];
    kTextBackgroundColor = [UIColor whiteColor];
    kCellBackgroundColor = [UIColor whiteColor];
    kTableBackgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    kTextInputColor = [[UIColor alloc] initWithRed:0.0 green:0.38 blue:0.48 alpha:1];
    kLineSeparatorColor = [[UIColor alloc] initWithRed:0.0 green:0.38 blue:0.48 alpha:1];
}

+ (void)setDarkTheme {
    kMainBackgroundColor = [UIColor grayColor];
    kMainLabelColor = [UIColor blackColor];
    kSegmentControlColor = [UIColor blackColor];
    kTextBackgroundColor = [UIColor lightGrayColor];
    kCellBackgroundColor = [UIColor lightGrayColor];
    kTableBackgroundColor = [UIColor blackColor];
    kTextInputColor = [UIColor blackColor];
    kLineSeparatorColor = [UIColor blackColor];
}

+ (UIColor *)backgroundColor {
    return kMainBackgroundColor;
}

+ (UIColor *)labelColor {
    return kMainLabelColor;
}

+ (UIColor *)segmentControlColor {
    return kSegmentControlColor;
}

+ (UIColor *)textBackgroundColor {
    return kTextBackgroundColor;
}

+ (UIColor *)cellBackgroundColor {
    return kCellBackgroundColor;
}

+ (UIColor *)tableBackgroundColor {
    return kTableBackgroundColor;
}

+ (UIColor *)textInputColor {
    return kTextInputColor;
}

+ (UIColor *)lineSeparatorColor {
    return kTextInputColor;
}

@end
