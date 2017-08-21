//
//  ASTSimpleSearchFormPresenter.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "PLANIT_v1-Swift.h"

#import "ASTSimpleSearchFormPresenter.h"
#import "ASTSimpleSearchFormViewControllerProtocol.h"
#import "ASTSimpleSearchFormViewModel.h"
#import "JRSearchInfoUtils.h"
#import "DateUtil.h"

static NSString * const kSimpleSearchInfoBuilderStorageKey = @"simpleSearchInfoBuilderStorageKey";

@interface ASTSimpleSearchFormPresenter ()

@property (nonatomic, weak) id <ASTSimpleSearchFormViewControllerProtocol> viewController;

@property (nonatomic, strong) JRSDKSearchInfoBuilder *searchInfoBuilder;
@property (nonatomic, strong) JRSDKTravelSegmentBuilder *directTravelSegmentBuilder;
@property (nonatomic, strong) NSDate *returnDate;
@property (nonatomic, assign) BOOL shouldSetReturnDate;

@end

@implementation ASTSimpleSearchFormPresenter

- (instancetype)initWithViewController:(id <ASTSimpleSearchFormViewControllerProtocol>)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers {
    
    self.directTravelSegmentBuilder.destinationAirport = destination;
    self.directTravelSegmentBuilder.departureDate = checkIn;
    self.returnDate = checkOut;
    
    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    bool isRoundtrip = [flightTicketsAccessoryMethodPerformer fetchIsRoundtrip];

    if (isRoundtrip) {
        self.shouldSetReturnDate = YES;
    } else {
        self.shouldSetReturnDate = NO;
    }

    self.searchInfoBuilder.adults = passengers.adults;
    self.searchInfoBuilder.infants = passengers.infants;
    self.searchInfoBuilder.children = passengers.children;

    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleViewDidLoad {
    [self restoreSearchInfoBuilder];
    [self createDirectTravelSegmentBuilder];
    [self.viewController updateWithViewModel:[self buildViewModel]];

}

- (void)handleSelectCellViewModel:(ASTSimpleSearchFormCellViewModel *)cellViewModel {
    switch (cellViewModel.type) {
        case ASTSimpleSearchFormCellViewModelTypeOrigin:
            [self.viewController showAirportPickerWithMode:JRAirportPickerOriginMode];
            break;
        case ASTSimpleSearchFormCellViewModelTypeDestination:
            [self.viewController showAirportPickerWithMode:JRAirportPickerDestinationMode];
            break;
        case ASTSimpleSearchFormCellViewModelTypeDeparture:
            [self.viewController showDatePickerWithMode:JRDatePickerModeDeparture borderDate:nil firstDate:self.directTravelSegmentBuilder.departureDate secondDate:self.shouldSetReturnDate ? self.returnDate : nil];
            break;
        case ASTSimpleSearchFormCellViewModelTypeReturn: {
            [self.viewController showDatePickerWithMode:JRDatePickerModeReturn borderDate:self.directTravelSegmentBuilder.departureDate firstDate:self.directTravelSegmentBuilder.departureDate secondDate:self.shouldSetReturnDate ? self.returnDate : nil];
            break;
        }
    }
}

- (void)handlePickPassengers {
    [self.viewController showPassengersPickerWithInfo:[self buildPassengersInfo]];
}

- (void)handleSelectAirport:(JRSDKAirport *)selectedAirport withMode:(JRAirportPickerMode)mode {
    switch (mode) {
        case JRAirportPickerOriginMode:
            self.directTravelSegmentBuilder.originAirport = selectedAirport;
            break;
        case JRAirportPickerDestinationMode:
            self.directTravelSegmentBuilder.destinationAirport = selectedAirport;
            break;
    }
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSelectDate:(NSDate *)selectedDate withMode:(JRDatePickerMode)mode {
    switch (mode) {
        case JRDatePickerModeDeparture:
            self.directTravelSegmentBuilder.departureDate = selectedDate;
            if (self.returnDate && selectedDate > self.returnDate) {
                self.returnDate = selectedDate;
            }
            break;
        case JRDatePickerModeReturn:
            self.shouldSetReturnDate = YES;
            self.returnDate = selectedDate;
            break;
        default:
            break;
    }
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSelectPassengersInfo:(ASTPassengersInfo *)selectedPassengersInfo {
    self.searchInfoBuilder.adults = selectedPassengersInfo.adults;
    self.searchInfoBuilder.children = selectedPassengersInfo.children;
    self.searchInfoBuilder.infants = selectedPassengersInfo.infants;
    self.searchInfoBuilder.travelClass = selectedPassengersInfo.travelClass;
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSwapAirports {
    JRSDKAirport *originAirport = self.directTravelSegmentBuilder.originAirport;
    self.directTravelSegmentBuilder.originAirport = self.directTravelSegmentBuilder.destinationAirport;
    self.directTravelSegmentBuilder.destinationAirport = originAirport;
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSwitchReturnCheckbox {
    if (self.shouldSetReturnDate) {
        self.shouldSetReturnDate = NO;
        [self.viewController updateWithViewModel:[self buildViewModel]];
    } else {
        if (self.returnDate) {
            self.shouldSetReturnDate = YES;
            [self.viewController updateWithViewModel:[self buildViewModel]];
        } else {
            [self.viewController showDatePickerWithMode:JRDatePickerModeReturn borderDate:self.directTravelSegmentBuilder.departureDate firstDate:self.directTravelSegmentBuilder.departureDate secondDate:self.returnDate];
        }
    }
}

- (void)handleSearch {
    JRSDKSearchInfo *searchInfo = [self buildSearchInfo];
    if (searchInfo) {
        [self.viewController showWaitingScreenWithSearchInfo:searchInfo];
        [self saveSearchInfoBuilder];
        
        FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
        [flightTicketsAccessoryMethodPerformer saveSearchInfoWithSearchInfo:searchInfo];

        [[InteractionManager shared] prepareSearchHotelsInfoFrom:searchInfo];
    }
}

#pragma mark - Build

- (ASTPassengersInfo *)buildPassengersInfo {
    
    NSInteger adults = self.searchInfoBuilder.adults;
    NSInteger children = self.searchInfoBuilder.children;
    NSInteger infants = self.searchInfoBuilder.infants;
    JRSDKTravelClass travelClass = self.searchInfoBuilder.travelClass;
    
    return [[ASTPassengersInfo alloc] initWithAdults:adults children:children infants:infants travelClass:travelClass];
}

- (ASTSimpleSearchFormViewModel *)buildViewModel {
    ASTSimpleSearchFormViewModel *viewModel = [ASTSimpleSearchFormViewModel new];
    viewModel.sectionViewModels = [self buildSectionViewModels];
    viewModel.passengersViewModel = [self buildPassengersViewModel];
    return viewModel;
}

- (NSArray <ASTSimpleSearchFormSectionViewModel *> *)buildSectionViewModels {
    return @[[self buildAirportsSectionViewModel],
             [self buildDatesSectionViewModel]];
}

- (ASTSimpleSearchFormPassengersViewModel *)buildPassengersViewModel {
    ASTSimpleSearchFormPassengersViewModel *passengersViewModel = [ASTSimpleSearchFormPassengersViewModel new];
    passengersViewModel.adults = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.adults)];
    passengersViewModel.children = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.children)];
    passengersViewModel.infants = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.infants)];
    passengersViewModel.travelClass = [JRSearchInfoUtils travelClassStringWithTravelClass:self.searchInfoBuilder.travelClass];
    return passengersViewModel;
}

- (ASTSimpleSearchFormSectionViewModel *)buildAirportsSectionViewModel {
    JRSDKTravelSegmentBuilder *travelSegmentBuilder = self.directTravelSegmentBuilder;
    ASTSimpleSearchFormSectionViewModel *sectionViewModel = [ASTSimpleSearchFormSectionViewModel new];
    sectionViewModel.cellViewModels = @[[self buildAirportCellViewModelWithType:ASTSimpleSearchFormCellViewModelTypeOrigin airport:travelSegmentBuilder.originAirport],
                                        [self buildAirportCellViewModelWithType:ASTSimpleSearchFormCellViewModelTypeDestination airport:travelSegmentBuilder.destinationAirport]];
    return sectionViewModel;
}

- (ASTSimpleSearchFormSectionViewModel *)buildDatesSectionViewModel {
    NSDate *directDate = self.directTravelSegmentBuilder.departureDate;
    NSDate *returnDate = self.shouldSetReturnDate ? self.returnDate : nil;
    ASTSimpleSearchFormSectionViewModel *sectionViewModel = [ASTSimpleSearchFormSectionViewModel new];
    sectionViewModel.cellViewModels = @[[self buildDateCellViewModelWithType:ASTSimpleSearchFormCellViewModelTypeDeparture date:directDate],
                                        [self buildDateCellViewModelWithType:ASTSimpleSearchFormCellViewModelTypeReturn date:returnDate]];
    return sectionViewModel;
}

- (ASTSimpleSearchFormAirportCellViewModel *)buildAirportCellViewModelWithType:(ASTSimpleSearchFormCellViewModelType)type airport:(JRSDKAirport *)airport {
    ASTSimpleSearchFormAirportCellViewModel *cellViewModel = [ASTSimpleSearchFormAirportCellViewModel new];
    cellViewModel.type = type;
    BOOL isOrigin = type == ASTSimpleSearchFormCellViewModelTypeOrigin;
    NSString *placeholder = isOrigin ? @"JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_ORIGIN" : @"JR_SEARCH_FORM_AIRPORT_CELL_EMPTY_DESTINATION";
    cellViewModel.city = airport.city ? airport.city : NSLS(placeholder);
    cellViewModel.iata = airport.iata;
    cellViewModel.icon = isOrigin ? @"origin_icon" : @"destination_icon";
    cellViewModel.hint = isOrigin? NSLS(@"JR_SEARCH_FORM_COMPLEX_ORIGIN") : NSLS(@"JR_SEARCH_FORM_COMPLEX_DESTINATION");
    cellViewModel.placeholder = !airport.city;
    return cellViewModel;
}

- (ASTSimpleSearchFormDateCellViewModel *)buildDateCellViewModelWithType:(ASTSimpleSearchFormCellViewModelType)type date:(NSDate *)date {
    ASTSimpleSearchFormDateCellViewModel *cellViewModel = [ASTSimpleSearchFormDateCellViewModel new];
    cellViewModel.type = type;
    BOOL isDeparture = type == ASTSimpleSearchFormCellViewModelTypeDeparture;
    NSString *placeholder = isDeparture ? @"JR_DATE_PICKER_DEPARTURE_DATE_TITLE" : @"JR_DATE_PICKER_RETURN_DATE_TITLE";
    cellViewModel.date = date ? [DateUtil dayMonthYearWeekdayStringFromDate:date] : NSLS(placeholder);
    cellViewModel.icon = isDeparture ? @"departure_icon" : @"arrival_icon";
    cellViewModel.hint = isDeparture ? NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_DEPARTURE_DATE") : NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_RETURN_DATE");
    cellViewModel.shouldHideReturnCheckbox = isDeparture;
    cellViewModel.shouldSelectReturnCheckbox = date != nil;
    cellViewModel.placeholder = !date;
    return cellViewModel;
}

#pragma mark - Restore & Create & Save

- (void)restoreSearchInfoBuilder {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kSimpleSearchInfoBuilderStorageKey];
    JRSDKSearchInfoBuilder *searchInfoBuilder = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!searchInfoBuilder) {
        searchInfoBuilder = [self createSearchInfoBuilder];
    }
    self.searchInfoBuilder = searchInfoBuilder;
}

- (JRSDKSearchInfoBuilder *)createSearchInfoBuilder {
    JRSDKSearchInfoBuilder *searchInfoBuilder = [JRSDKSearchInfoBuilder new];
    searchInfoBuilder.adults = 1;
    return searchInfoBuilder;
}

- (void)createDirectTravelSegmentBuilder {
    
    JRSDKTravelSegment *directTravelSegment = self.searchInfoBuilder.travelSegments.firstObject;
    JRSDKTravelSegment *returnTravelSegment = self.searchInfoBuilder.travelSegments.lastObject;
    
    if (directTravelSegment) {
        self.directTravelSegmentBuilder = [[JRSDKTravelSegmentBuilder alloc] initWithTravelSegment:directTravelSegment];
    } else {
        self.directTravelSegmentBuilder = [[JRSDKTravelSegmentBuilder alloc] init];
    }
    
    if (directTravelSegment && returnTravelSegment && ![directTravelSegment isEqual:returnTravelSegment]) {
        self.returnDate = returnTravelSegment.departureDate;
        self.shouldSetReturnDate = YES;
    }
}

- (void)saveSearchInfoBuilder {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.searchInfoBuilder];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSimpleSearchInfoBuilderStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Logic

- (NSString *)validateTravelSegmentBuilder {
    NSString *result = nil;
    if (!self.directTravelSegmentBuilder.originAirport) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_ORIGIN_ERROR");
    } else if (!self.directTravelSegmentBuilder.destinationAirport) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DESTINATION_ERROR");
    } else if ([self.directTravelSegmentBuilder.originAirport isEqual:self.directTravelSegmentBuilder.destinationAirport]) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_SAME_CITY_ERROR");
    } else if (!self.directTravelSegmentBuilder.departureDate) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DEPARTURE_DATE");
    }
    return result;
}

- (void)buildTravelSegments {
    
    NSMutableOrderedSet <JRSDKTravelSegment *> *travelSegments = [[NSMutableOrderedSet alloc] init];
    
    [travelSegments addObject:[self.directTravelSegmentBuilder build]];
    
    if (self.shouldSetReturnDate) {
        JRSDKTravelSegmentBuilder *returnTravelSegmentBuilder = [JRSDKTravelSegmentBuilder new];
        returnTravelSegmentBuilder.originAirport = self.directTravelSegmentBuilder.destinationAirport;
        returnTravelSegmentBuilder.destinationAirport = self.directTravelSegmentBuilder.originAirport;
        returnTravelSegmentBuilder.departureDate = self.returnDate;
        [travelSegments addObject:[returnTravelSegmentBuilder build]];
    }
    
    self.searchInfoBuilder.travelSegments = [travelSegments copy];
}

- (JRSDKSearchInfo *)buildSearchInfo {
    JRSDKSearchInfo *result = nil;
    NSString *error = [self validateTravelSegmentBuilder];
    if (error) {
        [self.viewController showErrorWithMessage:error];
    } else {
        [self buildTravelSegments];
        result = [self.searchInfoBuilder build];
    }
    return  result;
}

@end
