//
//  JRFlightsSegmentHeaderView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "PLANIT_v1-Swift.h"

#import "JRFlightsSegmentHeaderView.h"
#import "DateUtil.h"

@interface JRFlightsSegmentHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *directionLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *separatorLineHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *originDepartureView;

@end

@implementation JRFlightsSegmentHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorLineHeightConstraint.constant = 1.0 / [UIScreen mainScreen].scale;
    
    [self updateContent];
}

#pragma mark Public methods

- (void)setFlightSegment:(JRSDKFlightSegment *)flightSegment {
    _flightSegment = flightSegment;
    
    [self updateContent];
}

#pragma mark Private methods

- (void)updateContent {
    if (self.flightSegment == nil) { return; }
    
    NSMutableArray *const airports = [NSMutableArray arrayWithCapacity:self.flightSegment.flights.count];
    [airports addObject:self.flightSegment.flights.firstObject.originAirport.iata];
    
    for (JRSDKFlight *flight in self.flightSegment.flights) {
        [airports addObject:flight.destinationAirport.iata];
    }
    
    NSString *originFlightSegment = self.flightSegment.flights.firstObject.originAirport.city;
    NSString *destinationFlightSegment = self.flightSegment.flights.lastObject.destinationAirport.city;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ - %@", originFlightSegment, destinationFlightSegment];
    self.directionLabel.text = [airports componentsJoinedByString:@" • "];

    self.durationLabel.text = [DateUtil duration:self.flightSegment.totalDurationInMinutes durationStyle:JRDateUtilDurationShortStyle];
    self.originDepartureView.layer.backgroundColor = [UIColor clearColor].CGColor;
}

@end
