//
//  ASTComplexSearchFormViewControllerProtocol.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "JRAirportPickerEnums.h"

@class ASTComplexSearchFormViewModel;

@protocol ASTComplexSearchFormViewControllerProtocol <NSObject>

- (void)updateWithViewModel:(ASTComplexSearchFormViewModel *)viewModel;
- (void)addRowAnimatedAtIndex:(NSInteger)index withViewModel:(ASTComplexSearchFormViewModel *)viewModel;
- (void)removeRowAnimatedAtIndex:(NSInteger)index withViewModel:(ASTComplexSearchFormViewModel *)viewModel;
- (void)showAirportPickerWithMode:(JRAirportPickerMode)mode forIndex:(NSInteger)index;
- (void)showDatePickerWithBorderDate:(NSDate *)borderDate selectedDate:(NSDate *)selectedDate forIndex:(NSInteger)index;
- (void)showPassengersPickerWithInfo:(ASTPassengersInfo *)passengersInfo;
- (void)showErrorWithMessage:(NSString *)message;
- (void)showWaitingScreenWithSearchInfo:(JRSDKSearchInfo *)searchInfo;

@end
