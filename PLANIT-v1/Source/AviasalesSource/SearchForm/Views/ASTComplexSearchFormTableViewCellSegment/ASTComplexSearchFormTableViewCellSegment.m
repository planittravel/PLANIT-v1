//
//  ASTComplexSearchFormTableViewCellSegment.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "PLANIT_v1-Swift.h"

#import "ASTComplexSearchFormTableViewCellSegment.h"

@interface ASTComplexSearchFormTableViewCellSegment ()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation ASTComplexSearchFormTableViewCellSegment

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadViewFromNib];
    }
    return self;
}

- (void)loadViewFromNib {
    self.view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImageView.tintColor = [UIColor whiteColor];
}

- (void)animateTapInView:(UIView *)view {
    view.alpha = 0.5;
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 1.0;
    }];
}

- (IBAction)viewTapped:(UIView *)sender {
    
    [self animateTapInView:sender];
    
    if (self.tapAction) {
        self.tapAction(sender);
    }
}

@end
