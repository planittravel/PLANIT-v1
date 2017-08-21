//
//  JRFilterListSeparatorCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "PLANIT_v1-Swift.h"

#import "JRFilterListSeparatorCell.h"

#import "JRFilterListSeparatorItem.h"
#import "JRColorScheme.h"

@interface JRFilterListSeparatorCell ()

@end


@implementation JRFilterListSeparatorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = self.contentView.backgroundColor = [JRColorScheme navigationBarBackgroundColor];
}

- (void)setItem:(JRFilterListSeparatorItem *)item {
    _item = item;
    
    self.separatorLabel.text = [item tilte];
}

@end
