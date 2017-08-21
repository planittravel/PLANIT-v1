//
//  JRFilterTask.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterTicketBounds.h"
#import <HotellookSDK/HotellookSDK.h>
#import <AviasalesSDK/AviasalesSDK.h>


@protocol JRFilterTaskDelegate<NSObject>

@required
- (void)filterTaskDidFinishWithTickets:(NSOrderedSet<JRSDKTicket *> *)filteredTickets;

@end


@interface JRFilterTask : NSObject

+ (instancetype)filterTaskForTickets:(NSOrderedSet<JRSDKTicket *> *)ticketsToFilter
                        ticketBounds:(JRFilterTicketBounds *)ticketBounds
                 travelSegmentBounds:(NSArray *)travelSegmentBounds
                        taskDelegate:(id<JRFilterTaskDelegate>)delegate;

- (void)performFiltering;

@end
