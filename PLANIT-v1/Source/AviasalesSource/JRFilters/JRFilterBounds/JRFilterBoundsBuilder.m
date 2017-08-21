//
//  JRFilterBoundsBuilder.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterBoundsBuilder.h"

#import "JRFilterTicketBounds.h"
#import "JRFilterTravelSegmentBounds.h"
#import "PLANIT_v1-Swift.h"


@interface JRFilterBoundsBuilder ()

@property (nonnull, nonatomic, strong) NSOrderedSet <JRSDKTicket *> *tickets;
@property (nonnull, nonatomic, strong) JRSDKSearchInfo *searchInfo;

@property (nonatomic, strong) JRFilterTicketBounds *ticketBounds;
@property (nonatomic, strong) NSArray *travelSegmentsBounds;

@end


@implementation JRFilterBoundsBuilder

- (instancetype)initWithSearchResults:(nonnull NSOrderedSet <JRSDKTicket *> *)tickets forSearchInfo:(nonnull JRSDKSearchInfo *)searchInfo {
    self = [super init];
    if (self) {
        _tickets = tickets;
        _searchInfo = searchInfo;
        _isSimpleSearch = [JRSDKModelUtils isSimpleSearch:searchInfo];
        
        [self createBounds];
        [self process];
        [self sortBoundsContent];
    }
    
    return self;
}

#pragma mark - Private methds

- (void)createBounds {
    self.ticketBounds = [JRFilterTicketBounds new];
    
    NSMutableArray *travelSegmentsBounds = [NSMutableArray array];
    for (JRSDKTravelSegment *travelSegment in self.searchInfo.travelSegments) {
        JRFilterTravelSegmentBounds *travelSegmentBounds = [[JRFilterTravelSegmentBounds alloc] initWithTravelSegment:travelSegment];
        [travelSegmentsBounds addObject:travelSegmentBounds];
    }
    
    self.travelSegmentsBounds = [travelSegmentsBounds copy];
}

- (void)process {
    NSMutableOrderedSet<JRSDKPaymentMethod *> *allPaymentMethods = [NSMutableOrderedSet orderedSet];
    NSMutableDictionary<NSString *, JRSDKGate *> *gatesByMainID = [NSMutableDictionary dictionary];
    
    for (JRSDKTicket *ticket in self.tickets) {
        CGFloat curMinPrice = [ticket.proposals.firstObject.price priceInUSD].floatValue;
        CGFloat curMaxPrice = [ticket.proposals.lastObject.price priceInUSD].floatValue;
        self.ticketBounds.minPrice = MIN(curMinPrice, self.ticketBounds.minPrice);
        self.ticketBounds.maxPrice = MAX(curMaxPrice, self.ticketBounds.maxPrice);
        
        for (JRSDKTravelSegment *travelSegment in self.searchInfo.travelSegments) {
            NSInteger indexOfTravelSegment = [self.searchInfo.travelSegments indexOfObject:travelSegment];
            JRSDKFlightSegment *flightSegment = [ticket.flightSegments objectAtIndex:indexOfTravelSegment];
            JRFilterTravelSegmentBounds *travelSegmentBounds = [self.travelSegmentsBounds objectAtIndex:indexOfTravelSegment];
            [self processFlightSegment:flightSegment withTravelSegmentBounds:travelSegmentBounds minPrice:curMinPrice];
        }
        
        for (JRSDKProposal *proposal in ticket.proposals) {
            JRSDKGate *gate = proposal.gate;
            [allPaymentMethods unionSet:gate.paymentMethods];
            gatesByMainID[gate.mainGateID] = gate;
        }
    }
    
    self.ticketBounds.paymentMethods = [allPaymentMethods copy];
    self.ticketBounds.gates = [NSOrderedSet orderedSetWithArray:gatesByMainID.allValues];
}

- (void)processFlightSegment:(JRSDKFlightSegment *)flightSegment withTravelSegmentBounds:(JRFilterTravelSegmentBounds *)travelSegmentBounds minPrice:(CGFloat)minPrice {
    NSMutableDictionary<NSNumber *, NSNumber *> *transfersCountsWitnMinPrice = [travelSegmentBounds.transfersCountsWitnMinPrice mutableCopy];
    NSMutableOrderedSet<JRSDKAlliance *> *allAlliances = [travelSegmentBounds.alliances mutableCopy];
    NSMutableOrderedSet<JRSDKAirline *> *allAirlines = [travelSegmentBounds.airlines mutableCopy];
    NSMutableOrderedSet<JRSDKAirport *> *originAirports = [travelSegmentBounds.originAirports mutableCopy];
    NSMutableOrderedSet<JRSDKAirport *> *stopoverAirports = [travelSegmentBounds.stopoverAirports mutableCopy];
    NSMutableOrderedSet<JRSDKAirport *> *destinationAirports = [travelSegmentBounds.destinationAirports mutableCopy];
    
    travelSegmentBounds.overnightStopover = (flightSegment.hasOvernightStopover) ? YES : travelSegmentBounds.overnightStopover;
    travelSegmentBounds.transferToAnotherAirport = (flightSegment.hasTransferToAnotherAirport) ? YES : travelSegmentBounds.transferToAnotherAirport;
    
    travelSegmentBounds.minTotalDuration = MIN(flightSegment.totalDurationInMinutes, travelSegmentBounds.minTotalDuration);
    travelSegmentBounds.maxTotalDuration = MAX(flightSegment.totalDurationInMinutes, travelSegmentBounds.maxTotalDuration);
    
    travelSegmentBounds.minDelaysDuration = MIN(flightSegment.delayDurationInMinutes, travelSegmentBounds.minDelaysDuration);
    travelSegmentBounds.maxDelaysDuration = MAX(flightSegment.delayDurationInMinutes, travelSegmentBounds.maxDelaysDuration);
    
    travelSegmentBounds.minDepartureTime = MIN(flightSegment.departureDateTimestamp.doubleValue, travelSegmentBounds.minDepartureTime);
    travelSegmentBounds.maxDepartureTime = MAX(flightSegment.departureDateTimestamp.doubleValue, travelSegmentBounds.maxDepartureTime);
    
    travelSegmentBounds.minArrivalTime = MIN(flightSegment.arrivalDateTimestamp.doubleValue, travelSegmentBounds.minArrivalTime);
    travelSegmentBounds.maxArrivalTime = MAX(flightSegment.arrivalDateTimestamp.doubleValue, travelSegmentBounds.maxArrivalTime);
    
    if (flightSegment.flights.count > 0) {
        NSNumber *transferCount = @(flightSegment.flights.count - 1);
        NSNumber *minPriceForTransferCount = transfersCountsWitnMinPrice[transferCount];
        if (!minPriceForTransferCount || minPriceForTransferCount.floatValue > minPrice) {
            transfersCountsWitnMinPrice[transferCount] = @(minPrice);
        }
    }
    
    JRSDKAirport *originAirport = flightSegment.flights.firstObject.originAirport;
    JRSDKAirport *destinationAirport = flightSegment.flights.lastObject.destinationAirport;
    for (JRSDKFlight *flight in flightSegment.flights) {
        [allAlliances addObject:flight.airline.alliance];
        [allAirlines addObject:flight.airline];
        
        for (JRSDKAirport *airport in @[flight.originAirport, flight.destinationAirport]) {
            if ([airport isEqual:originAirport]) {
                [originAirports addObject:airport];
            } else if ([airport isEqual:destinationAirport]) {
                [destinationAirports addObject:airport];
            } else {
                [stopoverAirports addObject:airport];
            }
        }
    }

    travelSegmentBounds.transfersCountsWitnMinPrice = [transfersCountsWitnMinPrice copy];
    travelSegmentBounds.airlines = [allAirlines copy];
    travelSegmentBounds.alliances = [allAlliances copy];
    travelSegmentBounds.originAirports = [originAirports copy];
    travelSegmentBounds.stopoverAirports = [stopoverAirports copy];
    travelSegmentBounds.destinationAirports = [destinationAirports copy];
}

- (void)sortBoundsContent {
    NSMutableOrderedSet<JRSDKPaymentMethod *> *allPaymentMethods = [self.ticketBounds.paymentMethods mutableCopy];
    NSMutableOrderedSet<JRSDKGate *> *allGates = [self.ticketBounds.gates mutableCopy];
    [allPaymentMethods sortUsingComparator:^NSComparisonResult(JRSDKPaymentMethod * _Nonnull obj1, JRSDKPaymentMethod *  _Nonnull obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    }];
    [allGates sortUsingComparator:^NSComparisonResult(JRSDKGate * _Nonnull obj1, JRSDKGate *  _Nonnull obj2) {
        return [obj1.label caseInsensitiveCompare:obj2.label];
    }];
    self.ticketBounds.paymentMethods = [allPaymentMethods copy];
    self.ticketBounds.gates = [allGates copy];
    [self.ticketBounds resetBounds];
    
    for (JRFilterTravelSegmentBounds *travelSegmentBounds in self.travelSegmentsBounds) {
        NSMutableOrderedSet<NSNumber *> *transfersCounts = [NSMutableOrderedSet orderedSetWithArray:travelSegmentBounds.transfersCountsWitnMinPrice.allKeys];
        NSMutableOrderedSet<JRSDKAlliance *> *allAlliances = [travelSegmentBounds.alliances mutableCopy];
        NSMutableOrderedSet<JRSDKAirline *> *allAirlines =[travelSegmentBounds.airlines mutableCopy];
        NSMutableOrderedSet<JRSDKAirport *> *originAirports = [travelSegmentBounds.originAirports mutableCopy];
        NSMutableOrderedSet<JRSDKAirport *> *stopoverAirports = [travelSegmentBounds.stopoverAirports mutableCopy];
        NSMutableOrderedSet<JRSDKAirport *> *destinationAirports = [travelSegmentBounds.destinationAirports mutableCopy];
        
        [transfersCounts sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        [allAirlines sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(JRSDKAirline * _Nonnull obj1, JRSDKAirline *  _Nonnull obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
        [allAlliances sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(JRSDKAlliance * _Nonnull obj1, JRSDKAlliance *  _Nonnull obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
        [originAirports sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(JRSDKAirport * _Nonnull obj1, JRSDKAirport *  _Nonnull obj2) {
            return [obj1.city caseInsensitiveCompare:obj2.city];
        }];
        [stopoverAirports sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(JRSDKAirport * _Nonnull obj1, JRSDKAirport *  _Nonnull obj2) {
            return [obj1.city caseInsensitiveCompare:obj2.city];
        }];
        [destinationAirports sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(JRSDKAirport * _Nonnull obj1, JRSDKAirport *  _Nonnull obj2) {
            return [obj1.city caseInsensitiveCompare:obj2.city];
        }];

        travelSegmentBounds.transfersCounts = [transfersCounts copy];
        travelSegmentBounds.airlines = [allAirlines copy];
        travelSegmentBounds.alliances = [allAlliances copy];
        travelSegmentBounds.originAirports = [originAirports copy];
        travelSegmentBounds.stopoverAirports = [stopoverAirports copy];
        travelSegmentBounds.destinationAirports = [destinationAirports copy];
        [travelSegmentBounds resetBounds];
    }
}

@end
