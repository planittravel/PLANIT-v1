//
//  JRSearchResultsFlightSegmentCellLayoutParameters.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "PLANIT_v1-Swift.h"


@interface JRSearchResultsFlightSegmentCellLayoutParameters : NSObject
@property (assign, nonatomic, readonly) CGFloat departureDateWidth;
@property (assign, nonatomic, readonly) CGFloat departureLabelWidth;
@property (assign, nonatomic, readonly) CGFloat arrivalLabelWidth;
@property (assign, nonatomic, readonly) CGFloat flightDurationWidth;

- (instancetype)initWithDepartureDateWidth:(CGFloat)departureDateWidth
                       departureLabelWidth:(CGFloat)departureLabelWidth
                         arrivalLabelWidth:(CGFloat)arrivalLabelWidth
                       flightDurationWidth:(CGFloat)flightDurationWidth;

+ (instancetype)parametersWithTickets:(NSArray<JRSDKTicket *> *)tickets
                                 font:(UIFont *)font;
@end
