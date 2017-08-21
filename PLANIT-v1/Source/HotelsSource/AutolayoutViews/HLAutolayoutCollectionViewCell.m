#import "PLANIT_v1-Swift.h"
#import "HLAutolayoutCollectionViewCell.h"

@interface HLAutolayoutCollectionViewCell()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation HLAutolayoutCollectionViewCell

- (void)updateConstraints
{
    [super updateConstraints];

    if (!self.didSetupConstraints) {
        [self setupConstraints];
        self.didSetupConstraints = YES;
    }
}

- (void)setupConstraints
{
    // Implement in subclass
}

@end

