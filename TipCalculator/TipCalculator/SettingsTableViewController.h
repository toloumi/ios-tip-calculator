//
//  SettingsTableViewController.h
//  TipCalculator
//
//  Created by  Minett on 9/27/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kUserLocaleKey;

@interface SettingsTableViewController : UITableViewController
+ (NSArray *)settingsOptionTitles;
@end
