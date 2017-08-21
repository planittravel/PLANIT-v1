//
//  JRDatePickerMonthHeaderReusableView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerMonthHeaderReusableView.h"
#import "JRViewController.h"
#import "DateUtil.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "PLANIT_v1-Swift.h"

static const NSInteger kWeekDayLabelTagOffset = 1000;

@interface JRDatePickerMonthHeaderReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *monthYearLabel;

@end

@implementation JRDatePickerMonthHeaderReusableView

- (void)awakeFromNib {
	[super awakeFromNib];

    self.monthYearLabel.textColor = [JRColorScheme darkTextColor];
    for (NSInteger i = 0; i < 7; i++) {
        NSInteger labelTag = i + kWeekDayLabelTagOffset;
        UILabel *weekdayLabel = (UILabel *)[self viewWithTag:labelTag];
        weekdayLabel.textColor = [JRColorScheme lightTextColor];
    }
    
	[self updateView];
}

- (void)setMonthItem:(JRDatePickerMonthItem *)monthItem {
	_monthItem = monthItem;
	[self updateView];
}

- (NSString *)getMonthYearString {
	NSDate *date = _monthItem.firstDayOfMonth;
	NSString *monthYearString = nil;
	if (date) {
		NSString *monthName = [DateUtil monthName:date];
		NSString *year = [DateUtil dayMonthYearComponentsFromDate:date][2];
		monthYearString = [[NSString stringWithFormat:@"%@ %@", monthName, year] uppercaseString];
	}
	return monthYearString;
}

- (void)updateView {
	NSString *monthYearString;
	monthYearString = [self getMonthYearString];
	[_monthYearLabel setText:monthYearString];
    
    
	for (NSString *weekday in _monthItem.weekdays) {
		NSUInteger labelTag = [_monthItem.weekdays indexOfObject:weekday] + kWeekDayLabelTagOffset;
		UILabel *weekdayLabel = (UILabel *)[self viewWithTag:labelTag];
		[weekdayLabel setText:[weekday lowercaseString]];
	}
}

@end
