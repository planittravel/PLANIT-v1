//
//  JRFilterTravelSegmentItem.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterItemProtocol.h"
#import "PLANIT_v1-Swift.h"


@class JRFilter;

@interface JRFilterTravelSegmentItem : NSObject <JRFilterItemProtocol>

@property (strong, nonatomic, readonly) JRSDKTravelSegment *travelSegment;

@property (nonatomic, copy) void (^filterAction)();

- (instancetype)initWithTravelSegment:(JRSDKTravelSegment *)travelSegment;

@end
