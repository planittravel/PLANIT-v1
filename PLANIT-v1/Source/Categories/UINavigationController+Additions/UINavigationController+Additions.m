//
//  UINavigationController+Additions.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "PLANIT_v1-Swift.h"

#import "UINavigationController+Additions.h"

@implementation UINavigationController(Additions)

- (void)replaceTopViewControllerWith:(UIViewController *)viewController {
    NSMutableArray *const viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers addObject:viewController];
    [self setViewControllers:viewControllers animated:YES];
}

@end
