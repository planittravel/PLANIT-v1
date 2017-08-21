//
//  DateUtil.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

#define DateUtilSystemTimeZoneDidChangeNotification @"DateUtilSystemTimeZoneDidChangeNotification"

typedef NS_ENUM (NSInteger, JRDateUtilDurationStyle) {
    JRDateUtilDurationShortStyle        = 0,
    JRDateUtilDurationLongStyle         = 1
};

@interface NSDateFormatter (POSIX)

+ (NSDateFormatter *)USPOSIXDateFormatter;
+ (NSDateFormatter *)applicationUIDateFormatter;

@end

@interface DateUtil : NSObject

+ (NSCalendar *)gregorianCalendar;
+ (NSCalendar *)systemCalendar;

+ (NSLocale *)ENUSPOSIXLocale;
+ (NSLocale *)applicationLocale;

+ (NSTimeZone *)GMTTimeZone;
+ (NSTimeZone *)systemTimeZone;

+ (BOOL)isSameDayAndMonthAndYear:(NSDate *)date1 with:(NSDate *)date2;
+ (BOOL)isSameMonthAndYear:(NSDate *)date1 with:(NSDate *)date2;
+ (BOOL)isTodayDate:(NSDate *)date;
+ (BOOL)isYesterdayDate:(NSDate *)date;

+ (NSArray *)dayMonthYearComponentsFromDate:(NSDate *)date;
+ (NSDate *)seasonForDate:(NSDate *)date;
+ (NSDate *)addNumberOfDays:(NSInteger)daysToAdd toDate:(NSDate *)date;
+ (NSDate *)adjustGMTDate:(NSDate *)date forTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)adjustDateToGMT:(NSDate *)date originalDateTimeZone:(NSTimeZone *)originalDateTimeZone;

+ (NSDate *)beginningOfWeek;
+ (NSDate *)dateFromComponents:(NSDateComponents *)components;
+ (NSDate *)dateFromDate:(NSString *)date andTime:(NSString *)time;
+ (NSDate *)dateFromDateString:(NSString *)date;
+ (NSDate *)firstAvalibleForSearchDate;
+ (NSDate *)firstDayOfMonth:(NSDate *)date;
+ (NSDate *)gmtTimeZoneResetTimeForDate:(NSDate *)date;
+ (NSDate *)nextDayForDate:(NSDate *)date;
+ (NSDate *)nextMonthForDate:(NSDate *)date;
+ (NSDate *)nextYearDate:(NSDate *)date;
+ (NSDate *)prevDayForDate:(NSDate *)date;
+ (NSDate *)resetTimeForDate:(NSDate *)date;
+ (NSDate *)systemTimeZoneResetTimeForDate:(NSDate *)date;
+ (NSDate *)today;

+ (NSDateComponents *)componentsFromDate:(NSDate *)date;

+ (NSInteger)monthNumber:(NSDate *)date;
+ (NSInteger)dayOfMonthNumber:(NSDate *)date;

+ (NSString *)datesIntervalStringWithSameMonth:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSString *)dateToTimeString:(NSDate *)date;
+ (NSString *)dateToDateString:(NSDate *)date;
+ (NSString *)dateToYearString:(NSDate *)date;
+ (NSString *)dayFromDate:(NSDate *)date;
+ (NSString *)dayFullMonthStringFromDate:(NSDate *)date;
+ (NSString *)dayFullMonthYearStringFromDate:(NSDate *)date;
+ (NSString *)shortDayMonthYearStringFromDate:(NSDate *)date;
+ (NSString *)dayMonthStringFromDate:(NSDate *)date;
+ (NSString *)dayMonthYearStringFromDate:(NSDate *)date;
+ (NSString *)dayMonthYearWeekdayStringFromDate:(NSDate *)date;
+ (NSString *)fullDayMonthYearWeekdayStringFromDate:(NSDate *)date;
+ (NSString *)rawDayNumberFromDate:(NSDate *)date;
+ (NSString *)dayNumberFromDate:(NSDate *)date;
+ (NSString *)duration:(NSInteger)duration durationStyle:(JRDateUtilDurationStyle)durationStyle;
+ (NSString *)fastDayMonthString:(NSDate *)date;
+ (NSString *)fullDayFromDate:(NSDate *)date;
+ (NSString *)monthName:(NSDate *)date;
+ (NSString *)shortDatesIntervalStringWithSameMonth:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSString *)stringForSpeakDayMonthYearDayOfWeek:(NSDate *)date;

+ (NSDate *)borderDate;
+ (NSInteger)hl_daysBetweenDate:(NSDate *)date andOtherDate:(NSDate *)otherDate;
+ (NSDate *)dateIn30Days:(NSDate *)date;
+ (NSDate *)firstDayOfNextMonthForDate:(NSDate*)date;
+ (NSDate *)setTimeForDate:(NSDate *)date time:(NSDate *)time;

@end
