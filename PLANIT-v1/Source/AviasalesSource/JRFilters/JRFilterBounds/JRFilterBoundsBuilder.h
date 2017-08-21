//
//  JRFilterBoundsBuilder.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import <AviasalesSDK/AviasalesSDK.h>

@class JRFilterTicketBounds;

@interface JRFilterBoundsBuilder : NSObject

@property (nonatomic, assign, readonly) BOOL isSimpleSearch;

@property (nonatomic, strong, readonly) JRFilterTicketBounds *ticketBounds;
@property (nonatomic, strong, readonly) NSArray *travelSegmentsBounds;

- (instancetype)initWithSearchResults:(nonnull NSOrderedSet <JRSDKTicket *> *)tickets forSearchInfo:(nonnull JRSDKSearchInfo *)searchInfo;

@end
