#import "PLANIT_v1-Swift.h"
#import <HotellookSDK/HotellookSDK.h>
#import "HLSearchVC.h"
#import "StringUtils.h"
#import "PureLayout.h"
#import "HLDatePickerVC.h"
#import "JRColorScheme.h"
#import "HLAlertsFabric.h"

@interface HLSearchVC () <HLSearchFormDelegate, HLCityPickerDelegate, HLSearchInfoChangeDelegate, HLCustomPointSelectionDelegate, TicketsSearchDelegate>

@property (nonatomic, weak) IBOutlet UIView *searchFormContainerView;
@property (nonatomic, strong) HLHotelDetailsSearchDecorator *hotelDetailsDecorator;

@end

@implementation HLSearchVC

@synthesize searchInfo = _searchInfo;

- (instancetype)init
{
    self = [super init];

    if (self) {
        [InteractionManager shared].hotelsSearchForm = self;
    }

    return self;
}

#pragma mark - Properties

- (HLSearchInfo *)searchInfo
{
    if (!_searchInfo) {
        _searchInfo =  [HDKDefaultsSaver loadObjectWithKey:HL_DEFAULTS_SEARCH_INFO_KEY] ?: [HLSearchInfo defaultSearchInfo];
    }
    return _searchInfo;
}

- (void)setSearchInfo:(HLSearchInfo *)searchInfo
{
    _searchInfo = searchInfo;
    [self updateControls];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.searchInfo updateExpiredDates];

    self.title = NSLS(@"LOC_SEARCH_FORM_TITLE");
    [self registerForSearchInfoChangesNotifications];

    self.searchForm = [[[NSBundle mainBundle] loadNibNamed:@"HLSearchForm" owner:nil options:nil] objectAtIndex:0];
    [self.searchFormContainerView addSubview:self.searchForm];
    self.searchForm.delegate = self;
    self.searchForm.searchInfo = self.searchInfo;

    [self.searchForm autoPinEdgesToSuperviewEdges];

    self.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    HotelItemsAccessoryMethodsPerformer *hotelItemsAccessoryMethodsPerformer = [[HotelItemsAccessoryMethodsPerformer alloc] init];
    
    NSDate *checkInDate = [hotelItemsAccessoryMethodsPerformer fetchCheckInDate];
    NSDate *checkOutDate = [hotelItemsAccessoryMethodsPerformer fetchCheckOutDate];
    NSInteger indexOfDestinationBeingPlanned = [hotelItemsAccessoryMethodsPerformer fetchIndexOfDestinationBeingPlanned];
    if ([hotelItemsAccessoryMethodsPerformer checkIfCityFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned]) {
        HDKCity *city = [hotelItemsAccessoryMethodsPerformer fetchCityWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned];
        self.searchInfo.city = city;
    }
    
    self.searchInfo.checkInDate = checkInDate;
    self.searchInfo.checkOutDate = checkOutDate;
    [self updateControls];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hotelSearchSpawnedFromItinerary)
                                                 name:@"hotelSearchSpawnedFromItinerary"
                                               object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.hotelDetailsDecorator = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hotelSearchFormViewViewController_ViewDidAppear"
                                                        object:self];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

- (void)updateControls
{
    self.searchForm.searchInfo = self.searchInfo;
    [self updateSearchFormControls];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

- (void)updateSearchFormControls
{
    [self.searchForm updateControls];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)tryToStartSearchWithSearchInfo:(HLSearchInfo *)searchInfo
{
    if ([self.searchInfo readyToSearch]) {
        [self performSearchWithSearchInfo:searchInfo];
    } else {
        [HLAlertsFabric showEmptySearchFormAlert:searchInfo inController:self];
    }
}

- (void)performSearchWithSearchInfo:(HLSearchInfo *)searchInfo
{
    HotelItemsAccessoryMethodsPerformer *hotelItemsAccessoryMethodsPerformer = [[HotelItemsAccessoryMethodsPerformer alloc] init];
    [hotelItemsAccessoryMethodsPerformer saveSearchInfoWithSearchInfo:searchInfo];
    
    [HDKDefaultsSaver saveObject:searchInfo forKey:HL_DEFAULTS_SEARCH_INFO_KEY];
    if (searchInfo.hotel) {
        HLResultVariant *variant = [HLResultVariant createEmptyVariant:searchInfo hotel:searchInfo.hotel];
        self.hotelDetailsDecorator = [[HLHotelDetailsSearchDecorator alloc] initWithVariant:variant
                                                                                 photoIndex:0
                                                                          photoIndexUpdater:nil
                                                                                     filter:nil];

        [self.navigationController pushViewController:self.hotelDetailsDecorator.detailsVC animated:NO];
    } else {
        WaitingVC *waitingVC = [[WaitingVC alloc] initWithNibName:@"WaitingVC" bundle:nil];
        waitingVC.searchInfo = searchInfo;
        [self.navigationController pushViewController:waitingVC animated:NO];
    }
}

- (HLCityPickerVC *)cityPickerVC
{
    return [[HLCityPickerVC alloc] initWithNibName:@"ASTGroupedSearchVC" bundle:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setCityToSearchForm:(HDKCity *)city
{
    self.searchInfo.city = city;
    [self updateControls];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (void)selectCurrentLocation
{
    [[HLLocationManager sharedManager] requestUserLocationWithLocationDestination:kForceCurrentLocationToSearchForm];
    HDKSearchLocationPoint *locationPoint = [HLSearchUserLocationPoint forCurrentLocation];
    if (locationPoint) {
        self.searchInfo.locationPoint = locationPoint;
        [self updateSearchFormControls];
    }
    [[HLNearbyCitiesDetector shared] detectCurrentCityWithSearchInfo:self.searchInfo];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)showCityOrMapPicker
{
    if (self.searchInfo.locationPoint) {
        [self showMapPicker];
    } else {
        [self showCityPicker];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)showCityPickerWithText:(NSString *)searchText animated:(BOOL)animated
{
    HLCityPickerVC *pickerVC = [self cityPickerVC];
    pickerVC.searchInfo = self.searchInfo;
    pickerVC.delegate = self;
    pickerVC.initialSearchText = searchText;

    [self presentCityPicker:pickerVC animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)presentCityPicker:(HLCityPickerVC *)cityPickerVC animated:(BOOL)animated
{
    [self.navigationController pushViewController:cityPickerVC animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)showCityPicker
{
    [self showCityPickerWithText:nil animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)showMapPicker
{
    HLCustomPointSelectionVC *customMapPointSelectionVC = [[HLCustomPointSelectionVC alloc] initWithNibName:@"HLCustomPointSelectionVC" bundle:nil];
    customMapPointSelectionVC.delegate = self;
    customMapPointSelectionVC.initialSearchInfoLocation = self.searchInfo.searchLocation;
    customMapPointSelectionVC.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:customMapPointSelectionVC animated:YES completion:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - HLCityPickerDelegate

- (void)cityPicker:(HLCityPickerVC *)picker didSelectCity:(HDKCity *)city
{
    [self updateSearchCity:city];
    self.searchInfo.hotel = nil;
    [self updateControls];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)cityPicker:(HLCityPickerVC *)picker didSelectHotel:(HDKHotel *)hotel
{
    if (hotel.city) {
        [self updateSearchCity:hotel.city];
    }
    
    self.searchInfo.hotel = hotel;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)updateSearchCity:(HDKCity *)newCity
{
    
    
    self.searchInfo.city = newCity;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)cityPicker:(HLCityPickerVC *)picker didSelectAirport:(HDKAirport *)airport
{
    self.searchInfo.airport = airport;
    self.searchInfo.locationPoint = [[HLSearchAirportLocationPoint alloc] initWithAirport: airport];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)cityPicker:(HLCityPickerVC *)picker didSelectLocationPoint:(HDKSearchLocationPoint *)locationPoint
{
    [self updateSearchLocationPoint:locationPoint];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)updateSearchLocationPoint:(HDKSearchLocationPoint *)locationPoint
{
    self.searchInfo.locationPoint = locationPoint;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - HLCustomPointSelectionDelegate methods

- (void)didSelectCustomSearchLocationPoint:(HDKSearchLocationPoint *)searchLocationPoint
{
    [self.navigationController popViewControllerAnimated:true];
    self.searchInfo.locationPoint = searchLocationPoint;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - HLSearchInfoChangeDelegate methods

- (void)searchInfoChangedNotification:(NSNotification *)notification
{
    if (self.searchInfo == notification.object) {
        hl_dispatch_main_async_safe(^{
            [self updateControls];
        });
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)cityInfoDidLoad:(NSNotification *)notification
{
    hl_dispatch_main_async_safe(^{
        HDKCity *notificationCity = [(NSArray *)notification.object firstObject];
        if ([notificationCity.cityId isEqual:self.searchInfo.city.cityId]) {
            self.searchInfo.city = notificationCity;
        }
        [self updateControls];
    });
}


#pragma mark - HLNearbyCitiesDetectionDelegate methods

- (void)nearbyCitiesDetected:(NSNotification *)notification
{
    NSArray *nearbyCities = (NSArray *)notification.object;
    HDKCity *city = [nearbyCities firstObject];
    if ([city isKindOfClass:[HDKCity class]]) {
        NSString *currentLocationDestination = notification.userInfo[kCurrentLocationDestinationKey];
        if ([currentLocationDestination isEqual:kForceCurrentLocationToSearchForm] || [currentLocationDestination isEqual:kStartCurrentLocationSearch]) {
            HDKSearchLocationPoint *locationPoint = [HLSearchUserLocationPoint forCurrentLocation];
            if (locationPoint) {
                self.searchInfo.locationPoint = locationPoint;
            }
        }

        if ([currentLocationDestination isEqual:kStartCurrentLocationSearch]) {
            [self tryToStartSearchWithSearchInfo:self.searchInfo];
            [[HLNearbyCitiesDetector shared] dropCurrentLocationSearchDestination];
        }
        [self updateControls];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - HLSearchFormDelegate

- (void)onSearch:(HLSearchForm *)searchForm
{
    self.searchInfo.currency = [InteractionManager shared].currency;
    [self tryToStartSearchWithSearchInfo:self.searchInfo];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

- (void)showKidsPicker
{
    HLKidsPickerVC *kidsPicker = [[HLKidsPickerVC alloc] initWithNibName:@"HLKidsPickerVC" bundle:nil];
    kidsPicker.searchInfo = self.searchInfo;
    [self.navigationController pushViewController:kidsPicker animated:YES];
}

- (void)showDatePicker
{
    HLDatePickerVC *datePickerVC = [[HLDatePickerVC alloc] initWithNibName:@"HLDatePickerVC" bundle:nil];
    datePickerVC.searchInfo = self.searchInfo;
    [self.navigationController pushViewController:datePickerVC animated:YES];
}

#pragma mark - TicketsSearchDelegate

- (void)updateSearchInfoWithCity:(HDKCity *)city adults:(NSUInteger)adults checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut
{
    self.searchInfo.hotel = nil;
    self.searchInfo.city = city;
    self.searchInfo.adultsCount = adults;
    self.searchInfo.checkInDate = checkIn;
    self.searchInfo.checkOutDate = checkOut;
    [self updateControls];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedViewController:self.navigationController];
}

- (void)hotelSearchSpawnedFromItinerary {
    if ([self.searchInfo readyToSearch]) {
        [self performSearchWithSearchInfo:self.searchInfo];
    }
}

@end
