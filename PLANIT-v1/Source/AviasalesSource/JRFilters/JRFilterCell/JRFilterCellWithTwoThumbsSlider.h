//
//  ASFilterCellWithTwoThumbsSlider.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//



#import "JRTableViewCell.h"

@class JRFilterTwoThumbSliderItem;
@class NMRangeSlider;

@interface JRFilterCellWithTwoThumbsSlider : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellAttLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *cellSlider;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *dayTimeButtons;
@property (strong, nonatomic) JRFilterTwoThumbSliderItem *item;

@end
