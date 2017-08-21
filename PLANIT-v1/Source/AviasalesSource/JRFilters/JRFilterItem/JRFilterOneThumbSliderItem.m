//
//  JRFilterOneThumbSliderItem.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//


#import "PLANIT_v1-Swift.h"

#import "JRFilterOneThumbSliderItem.h"
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "JRDefines.h"

#import "DateUtil.h"

#include <stdlib.h>


@implementation JRFilterOneThumbSliderItem

- (instancetype)initWithMinValue:(float)minValue maxValue:(float)maxValue currentValue:(float)currentValue {
    self = [super init];
    if (self) {
        _minValue = minValue;
        _maxValue = maxValue;
        _currentValue = currentValue;
    }
    
    return self;
}

#pragma - mark JRFilterItemProtocol

- (NSString *)tilte {
    return @"";
}

- (NSAttributedString *)attributedStringValue {
    return [[NSAttributedString alloc] initWithString:@""];
}

@end


@implementation JRFilterPriceItem

#pragma - mark JRFilterItemProtocol

- (NSString *)tilte {
    return NSLS(@"JR_FILTER_PRICE_FILTER");
}

- (NSAttributedString *)attributedStringValue {
    JRSDKCurrency const userCurrency = [AviasalesSDK sharedInstance].currencyCode;
    NSNumber *priceInUserCurrency = [AviasalesNumberUtil convertPrice:@(self.currentValue) fromCurrency:@"usd" to:userCurrency];
    NSString *priceString = [AviasalesNumberUtil formatPrice:priceInUserCurrency];
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLS(@"JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO"), priceString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    return attributedText;
}

@end


@implementation JRFilterTotalDurationItem

#pragma - mark JRFilterItemProtocol

- (NSString *)tilte {
    return NSLS(@"JR_FILTER_TOTAL_DURATION");
}

- (NSAttributedString *)attributedStringValue {
    NSString *timeString = [DateUtil duration:self.currentValue durationStyle:JRDateUtilDurationLongStyle];
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLS(@"JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO"), timeString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    return attributedText;
}

@end
