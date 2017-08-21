//
//  UIView+NSLS.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "PLANIT_v1-Swift.h"
#import "UIView+NSLS.h"

@implementation UIView (NSLS)

- (NSString *)NSLSKey {
    return nil;
}

- (void)setNSLSKey:(NSString *)NSLSKey
{
    NSString *localizedString = NSLS(NSLSKey);
    id strongSelf = self;
    if ([strongSelf isKindOfClass:[UILabel class]]) {
        UILabel *label = strongSelf;
        [label setText:localizedString];
    } else if ([strongSelf isKindOfClass:[UIButton class]]) {
        UIButton *button = strongSelf;
        [button setTitle:localizedString forState:UIControlStateNormal];
    }
}

@end
