//
//  JRDatePickerVC.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerVC.h"
#import "JRDatePickerMonthItem.h"
#import "JRDatePickerDayCell.h"
#import "JRDatePickerMonthHeaderReusableView.h"
#import "DateUtil.h"
#import "JRColorScheme.h"

#import "PLANIT_v1-Swift.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "ASTSimpleSearchFormPresenter.h"
#import <BlocksKit/BlocksKit.h>


static const NSInteger kDatePickerCollectionHeaderHeight = 65;

static NSString * const kDayCellIdentifier = @"JRDatePickerDayCell";
static NSString * const kMonthReusableHeaderViewIdentifier = @"JRDatePickerMonthHeaderReusableView";


@interface JRDatePickerVC ()<UITableViewDataSource, UITableViewDelegate, JRDatePickerStateObjectActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) JRDatePickerStateObject *stateObject;

@property (nonatomic, copy) JRDatePickerVCSelecionBlock selectionBlock;

@end


@implementation JRDatePickerVC

- (instancetype)initWithMode:(JRDatePickerMode)mode
                  borderDate:(NSDate *)borderDate
                   firstDate:(NSDate *)firstDate
                  secondDate:(NSDate *)secondDate
              selectionBlock:(JRDatePickerVCSelecionBlock)selectionBlock {

    self = [super init];

    if (self) {
        _stateObject = [[JRDatePickerStateObject alloc] initWithDelegate:self];
        _stateObject.firstSelectedDate = firstDate;
        _stateObject.borderDate = borderDate;
        _stateObject.secondSelectedDate = secondDate;
        _stateObject.mode = mode;
        _selectionBlock = selectionBlock;
        [self buildTable];
    }
    
    return self;
}

- (void)registerNibs {
	[_tableView registerClass:[JRDatePickerDayCell class] forCellReuseIdentifier:kDayCellIdentifier];
    
	UINib *headerNib = [UINib nibWithNibName:kMonthReusableHeaderViewIdentifier bundle:nil];
	[_tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:kMonthReusableHeaderViewIdentifier];
}

- (void)setupTitle {
	if (_stateObject.mode == JRDatePickerModeReturn) {
        [self setTitle:NSLS(@"JR_DATE_PICKER_RETURN_DATE_TITLE")];
	} else {
		[self setTitle:NSLS(@"JR_DATE_PICKER_DEPARTURE_DATE_TITLE")];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self registerNibs];
	[self setupTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popFromJRDatePickerToFlightSearch)
                                                 name:@"popFromJRDatePickerToFlightSearch"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JRDatePicker_ViewDidLoad"
                                                        object:self];
    
}
- (void)popFromJRDatePickerToFlightSearch {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[_tableView reloadData];
	[_tableView scrollToRowAtIndexPath:_stateObject.indexPathToScroll atScrollPosition:UITableViewScrollPositionTop animated:NO];}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	[_tableView flashScrollIndicators];
}

- (void)buildTable {
    
	NSMutableArray *datesToRepresent = [NSMutableArray new];
    
	if (!_stateObject.borderDate) {
		[_stateObject setBorderDate:[DateUtil firstAvalibleForSearchDate]];
	}
    
	NSDate *firstMonth = [DateUtil firstDayOfMonth:[DateUtil resetTimeForDate:[DateUtil today]]];
    
	[datesToRepresent addObject:firstMonth];
	for (NSUInteger i = 1; i <= 12; i++) {
		NSDate *prevMonth = datesToRepresent[i - 1];
		[datesToRepresent addObject:[DateUtil nextMonthForDate:prevMonth]];
	}
    
	for (NSDate *date in datesToRepresent) {
		[_stateObject.monthItems addObject:[JRDatePickerMonthItem monthItemWithFirstDateOfMonth:date stateObject:_stateObject]];
	}
	[_stateObject updateSelectedDatesRange];
}

- (void)dateWasSelected:(NSDate *)date {

    switch (_stateObject.mode) {
        case JRDatePickerModeDefault:
        case JRDatePickerModeDeparture:
            _stateObject.firstSelectedDate = date;
            break;
        case JRDatePickerModeReturn:
            _stateObject.secondSelectedDate = date;
            break;
    }
    
	[_stateObject updateSelectedDatesRange];
	[_tableView reloadData];

    if (self.selectionBlock) {
        self.selectionBlock(date);
    }
    
    [self popOrDismissBasedOnDeviceTypeWithAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _stateObject.monthItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[section];
	return monthItem.weeks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	JRDatePickerDayCell *cell = [tableView dequeueReusableCellWithIdentifier:kDayCellIdentifier];
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[indexPath.section];
	NSArray *dates = (monthItem.weeks)[indexPath.row];
	[cell setDatePickerItem:monthItem dates:dates];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	JRDatePickerMonthHeaderReusableView *sectionHeaderView = [tableView
	                                                          dequeueReusableHeaderFooterViewWithIdentifier:kMonthReusableHeaderViewIdentifier];
	[sectionHeaderView setMonthItem:(_stateObject.monthItems)[section]];
	return sectionHeaderView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.view.frame.size.width / 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return kDatePickerCollectionHeaderHeight;
}

@end
