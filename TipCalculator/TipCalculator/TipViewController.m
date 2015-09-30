//
//  TipViewController.m
//  TipCalculator
//
//  Created by  Minett on 9/26/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsTableViewController.h"
#import "TipThemeSettings.h"

NSString *const kBillAmountCacheTimeKey = @"billAmountCacheKey";
NSString *const kBillAmountCacheTotal = @"billAmountCacheTotal";
NSString *const kHelpfulLinkURL = @"https://www.businessinsider.com/this-is-how-much-you-should-tip-for-every-service-2012-8";
int const kBillAmountCacheTime = 10;
int const kDefaultTip = 18;
int const kDefaultMaxTip = 20;
int const kDefaultMinTip = 15;
int const kMinTipIndex = 0;
int const kTipIndex = 1;
int const kMaxTipIndex = 2;

int const kDragPercentageScalar = 10;

@interface TipViewController ()
@property (weak, nonatomic) IBOutlet UITextField *billInputText;
@property (weak, nonatomic) IBOutlet UILabel *tipAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UIView *tipDragControl;

@property (weak, nonatomic) IBOutlet UILabel *billLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIView *lineSeparatorView;

@property (weak, nonatomic) IBOutlet UIWebView *helpfulTipsWebView;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableArray *tipValues;
@property (strong, nonatomic) NSNumber *currentTipValue;

- (IBAction)onDrag:(UIPanGestureRecognizer *)sender;
- (IBAction)onTap:(id)sender;
- (IBAction)helpTouch:(id)sender;
- (void)updateValuesFromSegmentControl;
@end

@implementation TipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Tip Calculator";
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.helpfulTipsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kHelpfulLinkURL]]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onSettingsButton)];

    [self resetHelpViews];
    [self setTipValuesFromDefaults];

    // If no user defaults are present we want to use the app defined defaults
    // and set the user defaults accordingly
    if(self.tipValues[kMinTipIndex] == 0)
        self.tipValues[kMinTipIndex] = @(kDefaultMinTip);
    
    if(self.tipValues[kTipIndex] == 0) {
        self.tipValues[kTipIndex] = @(kDefaultTip);
        self.currentTipValue = @(kDefaultTip);
    }
    
    if(self.tipValues[kMaxTipIndex] == 0)
        self.tipValues[kMaxTipIndex] = @(kDefaultMaxTip);

    // If this is the first time the app was ever opened set the defaults based on the presets
    // Otherwise this will just re-write the current user defaults
    [self.userDefaults setInteger:[self.tipValues[kTipIndex] integerValue] forKey:[SettingsTableViewController settingsOptionTitles][kTipIndex]];
    [self.userDefaults setInteger:[self.tipValues[kMaxTipIndex] integerValue] forKey:[SettingsTableViewController settingsOptionTitles][kMaxTipIndex]];
    [self.userDefaults setInteger:[self.tipValues[kMinTipIndex] integerValue] forKey:[SettingsTableViewController settingsOptionTitles][kMinTipIndex]];

    //Set Bill amount based on the 10min caching
    [self setupFromBillAmountCaching];
    [self setupSegmentControlWithUpdatedTipValues:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.billInputText becomeFirstResponder];
    [self setupSegmentControlWithUpdatedTipValues:YES];
    [self setupThemesFromDefaults];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.userDefaults setInteger:[self convertToFloatFromCurrencyString:self.billInputText.text] forKey:kBillAmountCacheTotal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onDrag:(UIPanGestureRecognizer *)sender {
    float minDefaultTipAmount = [self.tipValues[kMinTipIndex] floatValue];
    float maxDefaultTipAmount = [self.tipValues[kMaxTipIndex] floatValue];
    float dragPercentage = [sender velocityInView:self.tipDragControl].x / self.tipDragControl.frame.size.width / kDragPercentageScalar;
    float interpolatedTipPercentage;

    if (dragPercentage > 0) {
        interpolatedTipPercentage = [self.currentTipValue floatValue] + (maxDefaultTipAmount - [self.currentTipValue floatValue]) * dragPercentage;
    } else {
        interpolatedTipPercentage = minDefaultTipAmount + ([self.currentTipValue floatValue] - minDefaultTipAmount) * (1.0 + dragPercentage);
    }

    [self updateValuesFromDragControl:round(interpolatedTipPercentage) / 100];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
    if (sender != self.helpfulTipsWebView) {
        [self resetHelpViews];
    }
    [self updateValuesFromSegmentControl];
}

- (IBAction)helpTouch:(id)sender {
    [UIView animateWithDuration:0.5
                     animations:^{
                        CGRect webViewFrame = self.helpfulTipsWebView.frame;
                        self.helpButton.alpha = 0;
                        //TODO: This should be device agnostic
                        self.helpfulTipsWebView.frame = CGRectMake(webViewFrame.origin.x, 450, webViewFrame.size.width, 275);
                     }
                     completion:^(BOOL finished) {
                        [self.helpButton setHidden:YES];
                     }];
}

- (void)resetHelpViews {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [self.helpfulTipsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kHelpfulLinkURL]]];
                         [self.helpButton setHidden:NO];
                         self.helpButton.alpha = 1;
                         [self.helpfulTipsWebView setTransform:CGAffineTransformMakeTranslation(0, self.view.frame.size.height/2)];
                     }
                     completion:nil];
}

- (void)setupThemesFromDefaults {
    self.view.backgroundColor = [TipThemeSettings backgroundColor];
    self.billInputText.backgroundColor = [TipThemeSettings backgroundColor];
    self.billInputText.textColor = [TipThemeSettings textInputColor];
    self.billLabel.textColor = [TipThemeSettings labelColor];
    self.tipPercentageLabel.textColor = [TipThemeSettings labelColor];
    self.tipAmountLabel.textColor = [TipThemeSettings labelColor];
    self.totalLabel.textColor = [TipThemeSettings labelColor];
    self.totalAmountLabel.textColor = [TipThemeSettings labelColor];
    self.tipControl.tintColor = [TipThemeSettings segmentControlColor];
    self.tipDragControl.backgroundColor = [TipThemeSettings backgroundColor];
    self.lineSeparatorView.backgroundColor = [TipThemeSettings lineSeparatorColor];
}

- (void)setTipValuesFromDefaults {
    NSInteger defaultMinTip = [self.userDefaults integerForKey:[SettingsTableViewController settingsOptionTitles][kMinTipIndex]];
    NSInteger defaultTip = [self.userDefaults integerForKey:[SettingsTableViewController settingsOptionTitles][kTipIndex]];
    NSInteger defaultMaxTip = [self.userDefaults integerForKey:[SettingsTableViewController settingsOptionTitles][kMaxTipIndex]];
    
    self.currentTipValue = @(defaultTip);
    self.tipValues = [[NSMutableArray alloc] initWithArray: @[@(defaultMinTip), @(defaultTip), @(defaultMaxTip)]];
}

- (void)setupSegmentControlWithUpdatedTipValues:(BOOL)updateTipValues {
    if (updateTipValues)
        [self setTipValuesFromDefaults];

    [self.tipControl setTitle:[NSString stringWithFormat:@"%ld%%", (long)[self.tipValues[kMinTipIndex] integerValue]] forSegmentAtIndex:kMinTipIndex];
    [self.tipControl setTitle:[NSString stringWithFormat:@"%ld%%", (long)[self.tipValues[kTipIndex] integerValue]] forSegmentAtIndex:kTipIndex];
    [self.tipControl setTitle:[NSString stringWithFormat:@"%ld%%", (long)[self.tipValues[kMaxTipIndex] integerValue]] forSegmentAtIndex:kMaxTipIndex];
    [self.tipControl setSelectedSegmentIndex:kTipIndex];
    [self updateCurrentTipValue];
    [self updateValuesFromSegmentControl];
}

- (void)updateCurrentTipValue {
    self.tipPercentageLabel.text = [NSString stringWithFormat:@"%@%%", self.currentTipValue];
}

- (void)setupFromBillAmountCaching {
    NSDate *lastBillAmountCacheTime = [self.userDefaults objectForKey:kBillAmountCacheTimeKey];
    NSDate *currentTime = [[NSDate alloc] init];
    
    // Clear Defaults after 10 minutes
    if (lastBillAmountCacheTime == nil || [self minutesBetweenDate:lastBillAmountCacheTime andDate:currentTime] >= kBillAmountCacheTime) {
        [self.userDefaults setObject:currentTime forKey:kBillAmountCacheTimeKey];
        [self.userDefaults setInteger:0 forKey:kBillAmountCacheTotal];
    }
    
    float billAmount = [self.userDefaults integerForKey:kBillAmountCacheTotal];
    self.billInputText.text = [self convertToCurrencyStringFromFloat:billAmount includingSeparators:NO];
}

- (void)updateValuesFromSegmentControl {
    float billAmount = [self convertToFloatFromCurrencyString:self.billInputText.text];
    float tipAmount = billAmount * [self.tipValues[self.tipControl.selectedSegmentIndex] floatValue] / 100;
    float totalAmount = billAmount + tipAmount;

    self.currentTipValue = @([self.tipValues[self.tipControl.selectedSegmentIndex] floatValue]);
    self.billInputText.text = [self convertToCurrencyStringFromFloat:billAmount includingSeparators:NO];
    self.tipAmountLabel.text = [self convertToCurrencyStringFromFloat:tipAmount includingSeparators:YES];
    self.totalAmountLabel.text = [self convertToCurrencyStringFromFloat:totalAmount includingSeparators:YES];

    [self updateCurrentTipValue];
}

- (void)updateValuesFromDragControl:(float)dragControlTipValue{
    float billAmount = [self convertToFloatFromCurrencyString:self.billInputText.text];
    float tipAmount = billAmount * dragControlTipValue;
    float totalAmount = billAmount + tipAmount;

    self.currentTipValue = @(dragControlTipValue * 100);
    self.billInputText.text = [self convertToCurrencyStringFromFloat:billAmount includingSeparators:NO];
    self.tipAmountLabel.text = [self convertToCurrencyStringFromFloat:tipAmount includingSeparators:YES];
    self.totalAmountLabel.text = [self convertToCurrencyStringFromFloat:totalAmount includingSeparators:YES];

    [self updateCurrentTipValue];
}

- (NSString *)convertToCurrencyStringFromFloat:(float)amount includingSeparators:(BOOL)includeSeparators {
    return [[self numberFormatterInCurrentLocaleWithSeparator:includeSeparators] stringFromNumber:@(amount)];
}

- (float)convertToFloatFromCurrencyString:(NSString *)currencyString {
    return [[[self numberFormatterInCurrentLocaleWithSeparator:YES] numberFromString:currencyString] floatValue];
}

- (NSNumberFormatter *)numberFormatterInCurrentLocaleWithSeparator:(BOOL)includeSeparators {
    NSNumberFormatter *numFormater = [[NSNumberFormatter alloc] init];
    NSLocale *localeForCurrency = [NSLocale localeWithLocaleIdentifier:[self.userDefaults objectForKey:@"userLocale"]];
    if (localeForCurrency == nil) {
        localeForCurrency = [NSLocale currentLocale];
    }
    
    // Set this based on user selection in settings or default to US
    [numFormater setLocale:localeForCurrency];
    [numFormater setUsesGroupingSeparator:includeSeparators];
    [numFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return numFormater;
}

- (void)onSettingsButton {
    [self.navigationController pushViewController:[[SettingsTableViewController alloc] init] animated:YES];
}

- (NSInteger)minutesBetweenDate:(NSDate*)fromDate andDate:(NSDate*)toDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:fromDate toDate:toDate options:0];
    return components.minute;
}
@end
