//
//  SettingsTableViewController.m
//  TipCalculator
//
//  Created by  Minett on 9/27/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsTipValueTableViewCell.h"
#import "SettingsLocaleTableViewCell.h"
#import "TipThemeSettings.h"
#import "SettingsThemeSelectionTableviewCell.h"

NSString *const kValueCellIdentifier = @"SettingsValueCell";
NSString *const kThemeCellIdentifier = @"SettingsThemeCell";
NSString *const kLocaleCellIdentifier = @"SettingsLocaleCell";
NSString *const kUserLocaleKey = @"userLocale";

@interface SettingsTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property(assign) int currentLocaleSelection;
@property(weak, nonatomic) NSUserDefaults *userDefaults;
@property(strong, nonatomic) NSMutableArray *tipAmountFields;
@property(strong, nonatomic) NSArray *availableLocales;

- (void)synchronizeDataSource;
@end

@implementation SettingsTableViewController

+ (NSArray *)settingsOptionTitles {
    return @[@"Min Tip Amount", @"Default Tip Amount",  @"Max Tip Amount"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.availableLocales = [[NSLocale availableLocaleIdentifiers] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.tipAmountFields = [[NSMutableArray alloc] init];
    self.currentLocaleSelection = (int)[self.availableLocales indexOfObject:[self.userDefaults objectForKey:kUserLocaleKey]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsTipValueTableViewCell" bundle:nil] forCellReuseIdentifier:kValueCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsThemeSelectionTableViewCell" bundle:nil] forCellReuseIdentifier:kThemeCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsLocaleTableViewCell" bundle:nil] forCellReuseIdentifier:kLocaleCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [self synchronizeDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [TipThemeSettings tableBackgroundColor];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    
    switch (section) {
        case 0:
            title = @"Default Tip Values";
            break;
            
        case 1:
            title = @"Default Theme Settings";
            break;
            
        case 2:
            title = @"Default Locale";
            break;
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[SettingsTableViewController settingsOptionTitles] count];
    } else if (section == 1) {
        return 1;
    } else {
        return self.availableLocales.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SettingsTipValueTableViewCell *cell = (SettingsTipValueTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kValueCellIdentifier forIndexPath:indexPath];
    
        if (cell == nil)
            cell = [[SettingsTipValueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kValueCellIdentifier];
        
        NSInteger tipSettingsValue = [self.userDefaults integerForKey:[SettingsTableViewController settingsOptionTitles][indexPath.row]];
        
        cell.cellTitleLabel.text = [SettingsTableViewController settingsOptionTitles][indexPath.row];
        cell.cellValueTextField.text = [@(tipSettingsValue) stringValue];
        
        [self.tipAmountFields insertObject:cell.cellValueTextField atIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.cellTitleLabel.textColor = [TipThemeSettings labelColor];
        cell.cellValueTextField.backgroundColor = [TipThemeSettings textBackgroundColor];
        cell.cellValueTextField.textColor = [TipThemeSettings textInputColor];
        cell.backgroundColor = [TipThemeSettings cellBackgroundColor];
        
        return cell;
    } else if (indexPath.section == 1) {
        SettingsThemeSelectionTableViewCell *cell = (SettingsThemeSelectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kThemeCellIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.themeSettingTitle.text = @"Dark Theme";
            cell.themeSettingSwitch.on = [[self.userDefaults objectForKey:kThemeKey] isEqualToString:kDarkThemeIdentifier];
            [cell.themeSettingSwitch addTarget:self action:@selector(themeColorChanged:) forControlEvents:UIControlEventValueChanged];
        }
        
        cell.themeSettingTitle.textColor = [TipThemeSettings labelColor];
        cell.backgroundColor = [TipThemeSettings cellBackgroundColor];
        return cell;
    } else {
        SettingsLocaleTableViewCell *cell = (SettingsLocaleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLocaleCellIdentifier forIndexPath:indexPath];
    
        if (cell == nil)
            cell = [[SettingsLocaleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLocaleCellIdentifier];
        
        NSLocale *currentLocale = [NSLocale currentLocale];
        
        cell.cellTitleLabel.text = [currentLocale displayNameForKey:NSLocaleIdentifier value:self.availableLocales[indexPath.row]];

        if (self.currentLocaleSelection == indexPath.row) {
            NSLog(@"Check");
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        cell.cellTitleLabel.textColor = [TipThemeSettings labelColor];
        cell.backgroundColor = [TipThemeSettings cellBackgroundColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        // Set the locale in the userDefaults and mark an x on the cell
        [self.userDefaults setObject:self.availableLocales[indexPath.row] forKey:kUserLocaleKey];
        SettingsLocaleTableViewCell *selectedCell = (SettingsLocaleTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        SettingsLocaleTableViewCell *prevSelectedCell = (SettingsLocaleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentLocaleSelection inSection:indexPath.section]];
        prevSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentLocaleSelection = (int)indexPath.row;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)themeColorChanged:(id)sender {
    UISwitch *themeSwitch = (UISwitch *)sender;
    if (themeSwitch.on) {
        [TipThemeSettings setDarkTheme];
        [self.userDefaults setObject:kDarkThemeIdentifier forKey:kThemeKey];
    } else {
        [TipThemeSettings setDefaultTheme];
        [self.userDefaults setObject:kDefaultThemeIdentifier forKey:kThemeKey];
    }

    [self.tableView reloadData];
    [self viewWillAppear:YES];
}

- (void)synchronizeDataSource {
    [self.userDefaults setInteger:[((UITextField *)self.tipAmountFields[0]).text integerValue] forKey:[SettingsTableViewController settingsOptionTitles][0]];
    [self.userDefaults setInteger:[((UITextField *)self.tipAmountFields[1]).text integerValue] forKey:[SettingsTableViewController settingsOptionTitles][1]];
    [self.userDefaults setInteger:[((UITextField *)self.tipAmountFields[2]).text integerValue] forKey:[SettingsTableViewController settingsOptionTitles][2]];
    [self.userDefaults synchronize];
}
@end
