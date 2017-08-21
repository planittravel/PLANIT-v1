//
//  DateUtil.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "DateUtil.h"
#import "PLANIT_v1-Swift.h"

#define kDateFormatterThreadDictionaryKey @"JRDateFomatter"

@implementation NSDateFormatter (POSIX)

+ (NSDateFormatter *)USPOSIXDateFormatter
{
    NSDateFormatter *posixFormatter = [[NSDateFormatter alloc] init];
    [posixFormatter setCalendar:[DateUtil gregorianCalendar]];
    [posixFormatter setLocale:[DateUtil ENUSPOSIXLocale]];
    [posixFormatter setTimeZone:[DateUtil GMTTimeZone]];
    return posixFormatter;
}

+ (NSDateFormatter *)applicationUIDateFormatter {
    NSDateFormatter *applicationUIDateFormatter = [NSDateFormatter USPOSIXDateFormatter];
    [applicationUIDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:AVIASALES__(@"LANGUAGE", [NSLocale currentLocale].localeIdentifier)]];
    [applicationUIDateFormatter setCalendar:[DateUtil systemCalendar]];
    return applicationUIDateFormatter;
}

+ (NSDateFormatter *)applicationUITimeFormatter {
    NSDateFormatter *applicationUITimeFormatter = [NSDateFormatter applicationUIDateFormatter];
    return applicationUITimeFormatter;
}

@end

@implementation DateUtil

+ (NSCalendar *)systemCalendar
{
    return [NSCalendar autoupdatingCurrentCalendar];
}

+ (NSCalendar *)gregorianCalendar
{
    static NSCalendar *gregorianCalendar;
    if (gregorianCalendar == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCalendar setLocale:[NSLocale currentLocale]];
            [gregorianCalendar setTimeZone:[self GMTTimeZone]];
        });
    }
    return gregorianCalendar;
}

+ (NSLocale *)ENUSPOSIXLocale
{
    static NSLocale *ENUSPOSIXLocale;
    if (ENUSPOSIXLocale == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ENUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        });
    }
    return ENUSPOSIXLocale;
}

+ (NSTimeZone *)GMTTimeZone
{
    static NSTimeZone *GMTTimeZone;
    if (GMTTimeZone == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            GMTTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        });
    }
    return GMTTimeZone;
}

+ (NSTimeZone *)systemTimeZone
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DateUtilSystemTimeZoneDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [NSTimeZone resetSystemTimeZone];
                                                      
                                                      [[NSNotificationCenter defaultCenter]
                                                       postNotificationName:DateUtilSystemTimeZoneDidChangeNotification
                                                       object:nil];
                                                      
    }];
    return [NSTimeZone systemTimeZone];
}

+ (NSLocale *)applicationLocale {
    static NSLocale *applicationLocale;
    if (applicationLocale == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // TODO: generate app locale
            applicationLocale = [NSLocale currentLocale];
        });
    }
    return applicationLocale;
}

+(NSString *)dayMonthStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMM" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+ (NSString *)dayMonthYearStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMMyyyy" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+ (NSString *)dayMonthYearWeekdayStringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMMyyyyEEE" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+ (NSString *)fullDayMonthYearWeekdayStringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMMMyyyyEEEE" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+ (NSString *)rawDayNumberFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:@"d"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)dayNumberFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	[formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"d" options:kNilOptions locale:formatter.locale]];
	NSString *dateString = [formatter stringFromDate:date];
	return dateString;
}

+ (NSArray *)dayMonthYearComponentsFromDate:(NSDate *)date
{
    
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	
	NSString *dateString = [self dayNumberFromDate:date];
    
	[formatter setDateFormat:@"MMM"];
	NSString * monthString = [formatter stringFromDate:date];
	if (monthString.length > 3) {
		monthString = [monthString substringWithRange:NSMakeRange(0, 3)];
	}
    
	NSString *year = [self dateToYearString:date];
	if (dateString && monthString && year) {
		return @[dateString, monthString, year];
	} else {
		return nil;
	}
}

+(NSString *)dayFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	[formatter setDateFormat:@"EEE"];
	NSString *dayCapitalized = [ [formatter stringFromDate:date] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[ [formatter stringFromDate:date] substringToIndex:1] capitalizedString]];
	return dayCapitalized;
}


+(NSString *)fullDayFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	[formatter setDateFormat:@"EEEE"];
	NSString *dayCapitalized = [ [formatter stringFromDate:date] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[ [formatter stringFromDate:date] substringToIndex:1] capitalizedString]];
	return dayCapitalized;
}

+(NSString *)dayFullMonthStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMMM" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+(NSString *)dayFullMonthYearStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dMMMMyyyy" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}

+(NSString *)shortDayMonthYearStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy" options:kNilOptions locale:formatter.locale]];
    return [formatter stringFromDate:date];
}


+(NSString *)dateToYearString:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	[formatter setDateFormat:@"yyyy"];
	NSString * stringFromDate = [formatter stringFromDate:date];
	return stringFromDate;
}

static id willEnterForegroundNotificationObserver = nil;
static BOOL user24HourTimeCyclePreference = NO;

+(NSString *)dateToTimeString:(NSDate *)date
{
    
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUITimeFormatter];
    }
    
    if (willEnterForegroundNotificationObserver == nil) {//TODO не работает смена формата времени
        void (^update24HourTimeCyclePreference)(void) = ^{
            
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSLocale *prevFormatterLocale = formatter.locale;
            
            [formatter setLocale:[NSLocale currentLocale]];
            
            NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
            NSRange amRange = [stringFromDate rangeOfString:[formatter AMSymbol]];
            NSRange pmRange = [stringFromDate rangeOfString:[formatter PMSymbol]];
            
            if (amRange.location != NSNotFound || pmRange.location != NSNotFound) {
                user24HourTimeCyclePreference = NO;
            } else {
                user24HourTimeCyclePreference = YES;
            }
            
            formatter.locale = prevFormatterLocale;
            
        };
        
        willEnterForegroundNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                                    object:nil
                                                                                                     queue:[NSOperationQueue mainQueue]
                                                                                                usingBlock:^(NSNotification *note) {
                                                                                                    update24HourTimeCyclePreference();
                                                                                                }];
        update24HourTimeCyclePreference();
    }
    
	if (user24HourTimeCyclePreference || [AVIASALES__(@"LANGUAGE", nil) isEqualToString:@"ru"]) {
        
        [formatter setDateFormat:@"HH:mm"];
        
        return [formatter stringFromDate:date];
        
	} else {
        
        [formatter setDateFormat:@"hh:mma"];
        
        NSString *stringFromDate = [formatter stringFromDate:date];
        
        return stringFromDate;
        
	}
    
}

+(NSString *)dateToDateString:(NSDate *)date
{
    
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"d MMM" options:kNilOptions locale:formatter.locale]];
    
    return [formatter stringFromDate:date];
}

+(NSString *)duration:(NSInteger)duration durationStyle:(JRDateUtilDurationStyle)durationStyle
{
	NSInteger hoursInteger = duration / 60;
	NSInteger minutesInteger = duration % 60;
    
    NSString *format = nil;
    
    if (durationStyle == JRDateUtilDurationLongStyle) {
        format = NSLS(@"LONG_TIME_FORMAT");
        minutesInteger -= minutesInteger % 5;
    } else {
        format = NSLS(@"SHORT_TIME_FORMAT");
    }
    
    NSString *hours = [NSString stringWithFormat:hoursInteger <= 9 ? @"0%ld" : @"%ld", (long)hoursInteger];
    NSString *minutes = [NSString stringWithFormat:minutesInteger <= 9 ? @"0%ld" : @"%ld", (long)minutesInteger];
    
	return [NSString stringWithFormat:format, hours, minutes];
}

+(NSInteger)timeInMinutesOfDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
	NSInteger hours = [components hour];
	NSInteger minutes = [components minute];
	NSInteger result = hours * 60 + minutes;
	return result;
}


+(NSDate *)resetTimeForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
	[components setHour:0];
	[components setMinute:0];
	return [gregorian dateFromComponents:components];
}

+(NSDate *) getTimeForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
	return [gregorian dateByAddingComponents:components toDate:[NSDate distantPast] options:0];
}

+(NSDateComponents *)componentsFromDate:(NSDate *)date
{
    NSUInteger timeComps = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday);
    NSDateComponents *components = [[self gregorianCalendar] components:timeComps fromDate:date];
    
    return components;
}

+(NSDate *)dateFromComponents:(NSDateComponents *)components
{
    return [[self gregorianCalendar] dateFromComponents: components];
}


+(NSDate *)systemTimeZoneResetTimeForDate:(NSDate *)date
{
    return [self resetTimeForDate:date timeZone:[NSTimeZone systemTimeZone]];
}

+(NSDate *)resetTimeForDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone
{
    NSCalendar * gregorian = [DateUtil gregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:timeZone ? [date dateByAddingTimeInterval:[timeZone secondsFromGMT]] : date];
    [components setHour:0];
    [components setMinute:0];
    return [gregorian dateFromComponents:components];
}

+(NSDate *)gmtTimeZoneResetTimeForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
	[components setHour:0];
	[components setMinute:0];
	return [gregorian dateFromComponents:components];
}

+(NSDate *)firstDayOfMonth:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
	[components setDay:1];
	return [gregorian dateFromComponents:components];
}

+(NSInteger)dayOfMonthNumber:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitDay) fromDate:date];
	return [components day];
}

+(NSInteger)monthNumber:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitMonth) fromDate:date];
	return [components month];
}

+(NSDate *)dateNumberToNSDate:(NSNumber *)dateNumber_
                     forMonth:(NSDate *)month_
{
    
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
    
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:month_];
	components.day = [dateNumber_ integerValue];
    
	//NSDate *dateWithNumber = [firstDateOfMonth dateByAddingTimeInterval:86400*[dateNumber_ intValue]];//-1];
    
	return [gregorian dateFromComponents:components]; //dateWithNumber;
}

+(NSDate *)addNumberOfDays:(NSInteger)daysToAdd toDate:(NSDate *)date; {
	NSDate *now = date;
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setDay:daysToAdd];
	NSDate *newDate = [[DateUtil gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
	return newDate;
}



+(NSDate *)nextMonthForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
	components.month++;
	NSDate * res = [gregorian dateFromComponents:components];
	return res;
}

+(NSDate *)prevMonthForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
	components.month--;
	NSDate * res = [gregorian dateFromComponents:components];
	return res;
}

+(NSDate *)nextYearDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
	components.year++;
	NSDate * res = [gregorian dateFromComponents:components];
	return res;
}

+(NSDate *) seasonForDate:(NSDate *)date
{
	NSCalendar * calendar = [DateUtil gregorianCalendar];
	NSDateComponents * comps = [calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
	if (comps.month < 3) {
		comps.year -= 1;
	}
	comps.month %= 12;
	comps.month /= 3;
	comps.month *= 3;
	if (comps.month == 0) {
		comps.month = 12;
	}
	return [calendar dateFromComponents:comps];
}

+(NSDate *)systemTimeZoneNextYearDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[date dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]]];
	components.year++;
	NSDate * res = [gregorian dateFromComponents:components];
	return res;
}

+(NSDate *)nextDayForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
	components.day++;
	NSDate *res = [gregorian dateFromComponents:components];
	return res;
}

+(NSDate *)prevDayForDate:(NSDate *)date
{
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents * components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
	components.day--;
	NSDate * res = [gregorian dateFromComponents:components];
	return res;
}


+ (BOOL) isSameMonthAndYear: (NSDate *)date1 with: (NSDate *)date2
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	[formatter setDateFormat:@"yyyy-MM"];
	return [[formatter stringFromDate:date1] isEqualToString:[formatter stringFromDate:date2]];
}

+ (BOOL) isSameDayAndMonthAndYear: (NSDate *)date1 with: (NSDate *)date2
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:@"dd-yyyy-MM"];
    return [[formatter stringFromDate:date1] isEqualToString:[formatter stringFromDate:date2]];
}

+(NSDate *)today
{
	NSDate *date = [NSDate date];
	NSDate *result = [self systemTimeZoneResetTimeForDate:date];
	return result;
}

+ (NSDate *)beginningOfWeek {
    NSDate *today = [DateUtil today];
    NSCalendar *gregorian = [DateUtil gregorianCalendar];
    
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday
                                                       fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - [DateUtil gregorianCalendar].firstWeekday)];
    
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract
                                                         toDate:today options:0];
    
    return beginningOfWeek;
}

+ (NSDate *)firstAvalibleForSearchDate {
    return [DateUtil resetTimeForDate:[NSDate date] timeZone:[NSTimeZone timeZoneWithName:@"US/Samoa"]];
}

+ (NSInteger) daysBetweenDate:(NSDate *)date andOtherDate:(NSDate *) otherDate
{
	NSTimeInterval time = [date timeIntervalSinceDate:otherDate];
	return fabs(time / 60 / 60/ 24);
}

+ (NSString *)monthName:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	NSCalendar * gregorian = [DateUtil gregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitMonth) fromDate:date];
	NSArray * monthArr = [formatter standaloneMonthSymbols];
	return monthArr[components.month-1];
}

+ (NSString *)fastDayMonthString:(NSDate *)date {
    if (![date isKindOfClass:[NSDate class]]) {
        return nil;
    }
    struct tm *timeinfo;
    char buffer[80];
    
    time_t rawtime = [date timeIntervalSince1970];
    timeinfo = gmtime(&rawtime);
    
    strftime(buffer, 80, "%d%m", timeinfo);
    
    NSString *timeInfoString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    
    return timeInfoString;
}


+ (BOOL)date:(NSDate *)date isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSCalendarUnit dateComponents;

    dateComponents = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

    NSDateComponents *components1 = [[DateUtil gregorianCalendar] components:dateComponents fromDate:date];
	NSDateComponents *components2 = [[DateUtil gregorianCalendar] components:dateComponents fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

+ (BOOL)isTodayDate:(NSDate *)date
{
	return [self date:date isEqualToDateIgnoringTime:[DateUtil today]];
}

+ (BOOL)isTomorrowDate:(NSDate *)date
{
	return [self date:date isEqualToDateIgnoringTime:[DateUtil nextDayForDate:[DateUtil today]]];
}

+ (BOOL)isYesterdayDate:(NSDate *)date {
    return [self date:date isEqualToDateIgnoringTime:[DateUtil prevDayForDate:[DateUtil today]]];
}

+ (NSString *)datesIntervalStringWithSameMonth:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSString *datesString = @"";
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
	if (fromDate) {
		datesString = [NSString stringWithFormat:@"%@, %@, %@", [DateUtil dayMonthStringFromDate:fromDate], [DateUtil dayFromDate:fromDate], [DateUtil dateToYearString:fromDate]];
	}
	if (fromDate && toDate) {
        [formatter setDateFormat:@"Myyy"];
        if ([[formatter stringFromDate:fromDate] isEqualToString:[formatter stringFromDate:toDate]]) {
            datesString = [NSString stringWithFormat:@"%@, %@ — %@, %@, %@", [DateUtil dayNumberFromDate:fromDate], [DateUtil dayFromDate:fromDate], [DateUtil dayMonthStringFromDate:toDate], [DateUtil dayFromDate:toDate], [DateUtil dateToYearString:toDate]];
            return [datesString lowercaseString];
        }
        
        [formatter setDateFormat:@"yyyy"];
        if ([[formatter stringFromDate:fromDate] isEqualToString:[formatter stringFromDate:toDate]]) {
            datesString = [NSString stringWithFormat:@"%@, %@ — %@, %@, %@", [DateUtil dayMonthStringFromDate:fromDate], [DateUtil dayFromDate:fromDate], [DateUtil dayMonthStringFromDate:toDate], [DateUtil dayFromDate:toDate], [DateUtil dateToYearString:toDate]];
            return [datesString lowercaseString];
        }
        
        datesString = [NSString stringWithFormat:@"%@, %@, %@ — %@, %@, %@", [DateUtil dayMonthStringFromDate:fromDate], [DateUtil dayFromDate:fromDate], [DateUtil dateToYearString:fromDate], [DateUtil dayMonthStringFromDate:toDate], [DateUtil dayFromDate:toDate], [DateUtil dateToYearString:toDate]];
        
	}
    
    return [datesString lowercaseString];
}

+ (NSString *)shortDatesIntervalStringWithSameMonth:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSString *datesString = @"";
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    if (fromDate) {
        datesString = [DateUtil dayMonthStringFromDate:fromDate];
    }
    if (fromDate && toDate) {
        [formatter setDateFormat:@"Myyy"];
        if ([[formatter stringFromDate:fromDate] isEqualToString:[formatter stringFromDate:toDate]]) {
            datesString = [NSString stringWithFormat:@"%@ — %@", [DateUtil dayNumberFromDate:fromDate], [DateUtil dayMonthStringFromDate:toDate]];
            return [datesString lowercaseString];
        }
        
        datesString = [NSString stringWithFormat:@"%@ — %@", [DateUtil dayMonthStringFromDate:fromDate], [DateUtil dayMonthStringFromDate:toDate]];
        return [datesString lowercaseString];
        
    }
    
    return [datesString lowercaseString];
}

+ (NSDate *)adjustGMTDate:(NSDate *)date forTimeZone:(NSTimeZone *)timeZone
{
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter USPOSIXDateFormatter];
    }
    [dateFormatter setDateFormat:@"z"];
    [dateFormatter setTimeZone:timeZone];
    
    NSString *timeZoneString = [dateFormatter stringFromDate:date];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:@"dd MM yyyy HH:mm:ss"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd MM yyyy HH:mm:ss z"];
    NSDate *newDate;
    NSString *startStringForFormatter = [NSString stringWithFormat:@"%@ %@", dateString, timeZoneString];
    newDate = [dateFormatter dateFromString:startStringForFormatter];
    
    return newDate;
}

+ (NSDate *)adjustDateToGMT:(NSDate *)date originalDateTimeZone:(NSTimeZone *)originalDateTimeZone
{
    if (![date isKindOfClass:[NSDate class]]) {
        return nil;
    }
    
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter USPOSIXDateFormatter];
    }
    
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    [dateFormatter setDateFormat:@"z"];
    [dateFormatter setTimeZone:gmtTimeZone];
    
    NSString *timeZoneString = [dateFormatter stringFromDate:date];
    [dateFormatter setTimeZone:originalDateTimeZone];
    [dateFormatter setDateFormat:@"dd MM yyyy HH:mm:ss"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd MM yyyy HH:mm:ss z"];
    [dateFormatter setTimeZone:gmtTimeZone];
    
    NSDate *newDate;
    NSString *startStringForFormatter = [NSString stringWithFormat:@"%@ %@", dateString, timeZoneString];
    newDate = [dateFormatter dateFromString:startStringForFormatter];
    
    return newDate;
}

+ (NSDate *)dateFromDate:(NSString *)date andTime:(NSString *)time {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter USPOSIXDateFormatter];
    }
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTimeString = [NSString stringWithFormat:@"%@ %@", date, time];
    return [formatter dateFromString:dateTimeString];
}

+ (NSDate *)dateFromDateString:(NSString *)date {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter USPOSIXDateFormatter];
    }
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:date];
}

+ (NSString *)stringForSpeakDayMonthYearDayOfWeek:(NSDate *)date
{
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [NSDateFormatter applicationUIDateFormatter];
    }
    [formatter setDateFormat:@"dd MMMM yyyy, EEEE"];
    return [formatter stringFromDate:date];
}

#pragma mark - Hotellook stuff

+ (NSDate *)borderDate
{
    NSDate *localDate = [NSDate date];
    NSTimeZone *lastAvailableTimeZone = [NSTimeZone timeZoneWithName:@"UTC-14"];

    NSTimeInterval offsetSeconds = [lastAvailableTimeZone secondsFromGMT];
    NSDate *borderDate = [localDate dateByAddingTimeInterval:offsetSeconds];

    NSCalendar* gregorian = [DateUtil gregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:borderDate];
    [components setHour:0];
    [components setMinute:0];

    return [gregorian dateFromComponents:components];
}

+ (NSInteger)hl_daysBetweenDate:(NSDate *)date andOtherDate:(NSDate *)otherDate
{
    NSCalendar *cal = [DateUtil gregorianCalendar];
    NSDate *normDate = [self resetTimeForDate:date];
    NSDate *normOtherDate = [self resetTimeForDate:otherDate];
    NSDateComponents * components = [cal components:NSCalendarUnitDay fromDate:normDate toDate:normOtherDate options:0];

    return components.day;
}

+ (NSDate *)dateIn30Days:(NSDate *)date
{
    NSCalendar *cal = [DateUtil gregorianCalendar];
    NSDateComponents * components = [cal components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    components.day += 30;

    return [cal dateFromComponents:components];
}

+ (NSDate *)firstDayOfNextMonthForDate:(NSDate *)date
{
    NSCalendar *cal = [DateUtil gregorianCalendar];
    NSDateComponents * components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    components.month++;
    NSDate *res = [cal dateFromComponents:components];

    return res;
}

+ (NSDate *)setTimeForDate:(NSDate *)date time:(NSDate *)time
{
    NSCalendar *calendar = [DateUtil gregorianCalendar];
    return [calendar dateBySettingHour:time.hour minute:time.minute second:time.second ofDate:date options:0];
}

@end
