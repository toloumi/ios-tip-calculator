//
//  TipThemeSettings.h
//  TipCalculator
//
//  Created by  Minett on 10/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kThemeKey;
extern NSString *const kDefaultThemeIdentifier;
extern NSString *const kDarkThemeIdentifier;

@interface TipThemeSettings : NSObject
+ (void)setDefaultTheme;
+ (void)setDarkTheme;
+ (UIColor *)backgroundColor;
+ (UIColor *)labelColor;
+ (UIColor *)segmentControlColor;
+ (UIColor *)textBackgroundColor;
+ (UIColor *)cellBackgroundColor;
+ (UIColor *)tableBackgroundColor;
+ (UIColor *)textInputColor;
+ (UIColor *)lineSeparatorColor;
@end
