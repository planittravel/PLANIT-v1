//
//  JRTableViewCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRTableViewCell.h"
#import "UIImage+JRUIImage.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRDefines.h"
#import "JRColorScheme.h"


@interface JRTableViewCell ()

@property (strong, nonatomic) UIImageView *bottomLine;
@property (strong, nonatomic) NSLayoutConstraint *leadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *trailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end


@implementation JRTableViewCell

- (void)initialSetup
{
    UIView *scaleToFillView = [UIView new];
    [scaleToFillView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self insertSubview:scaleToFillView atIndex:0];
    [self addConstraints:JRConstraintsMakeScaleToFill(scaleToFillView, self)];
    
    _customBackgroundView = [UIView new];
    [_customBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_customBackgroundView setBackgroundColor:[JRColorScheme itemsBackgroundColor]];
    [self addSubview:_customBackgroundView];
    [self addConstraints:JRConstraintsMakeScaleToFill(_customBackgroundView, scaleToFillView)];
    
	_customSelectedBackgroundView = [UIView new];
    [_customSelectedBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_customSelectedBackgroundView setBackgroundColor:[JRColorScheme itemsSelectedBackgroundColor]];
    [_customSelectedBackgroundView setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    
	_bottomLine = [UIImageView new];
    [_bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_customBackgroundView addSubview:_bottomLine];
    
    _leadingConstraint = JRConstraintMake(_bottomLine, NSLayoutAttributeLeading, NSLayoutRelationEqual, _customBackgroundView, NSLayoutAttributeLeading, 1, 0);
    [_customBackgroundView addConstraint:_leadingConstraint];
    
    _trailingConstraint = JRConstraintMake(_customBackgroundView, NSLayoutAttributeTrailing, NSLayoutRelationEqual, _bottomLine, NSLayoutAttributeTrailing, 1, 0);
    [_customBackgroundView addConstraint:_trailingConstraint];
    _bottomConstraint = JRConstraintMake(_customBackgroundView, NSLayoutAttributeBottom, NSLayoutRelationEqual, _bottomLine, NSLayoutAttributeBottom, 1, 0);
    [_customBackgroundView addConstraint:_bottomConstraint];
    
    [_customBackgroundView addConstraint:JRConstraintMake(_bottomLine, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, JRPixel())];
    
    [_bottomLine setHidden:YES];
    
	[self setLeftOffset:_leftOffset];
    [self setBottomLineInsets:_bottomLineInsets];
    
	[self setBottomLineColor:[JRColorScheme separatorLineColor]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
    
	[self initialSetup];
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor
{
	_bottomLineColor = bottomLineColor;
	[_bottomLine setImage:[UIImage imageWithColor:_bottomLineColor]];
}

- (void)setLeftOffset:(CGFloat)leftOffset
{
	_bottomLineInsets.left = leftOffset;
    [self setBottomLineInsets:_bottomLineInsets];
}

- (void)setBottomLineInsets:(UIEdgeInsets)bottomLineInsets {
    _bottomLineInsets = bottomLineInsets;
    [_leadingConstraint setConstant:_bottomLineInsets.left];
    [_trailingConstraint setConstant:_bottomLineInsets.right];
    [_bottomConstraint setConstant:_bottomLineInsets.bottom];
}

- (BOOL)bottomLineVisible
{
	return !_bottomLine.hidden;
}
- (void)setBottomLineVisible:(BOOL)bottomLineVisible
{
	[_bottomLine setHidden:!bottomLineVisible];
}

- (void)updateBackgroundViewsForImagePath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    if (self.bottomLineVisible && !_showLastLine) {
        BOOL bottomLineHidden = indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1;
        [self setBottomLineVisible:!bottomLineHidden];
    }
    
	[self setBackgroundColor:nil];
	[self setBackgroundView:_customBackgroundView];
	[self setSelectedBackgroundView:_customSelectedBackgroundView];
}

@end
