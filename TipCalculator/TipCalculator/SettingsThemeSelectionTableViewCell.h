//
//  SettingsThemeSelectionTableViewCell.h
//  TipCalculator
//
//  Created by  Minett on 10/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsThemeSelectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *themeSettingTitle;
@property (weak, nonatomic) IBOutlet UISwitch *themeSettingSwitch;

@end
