//
//  JRNavigationController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRNavigationController.h"
#import "UIImage+JRUIImage.h"
#import "JRColorScheme.h"
#import "JRViewController.h"
#import "PLANIT_v1-Swift.h"

@interface JRNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *screenshotAlertsButton;
@property (nonatomic, strong) UIButton *screenshotPopoversButton;

@end

@implementation JRNavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	[self setupNavigationBar];
	if (iPhone()) {
        [self setDelegate:self];
        [self.interactivePopGestureRecognizer setDelegate:self];
	}
}

- (void)setupNavigationBar {
    self.navigationBar.barTintColor = [UIColor lightGrayColor];
    self.navigationBar.tintColor = [JRColorScheme navigationBarItemColor];
    self.navigationBar.translucent = YES;
//    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName   : [UIColor clearColor],
                                               NSFontAttributeName              : [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium]};

}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[JRViewController class]]) {
        [self setNavigationBarHidden:![(JRViewController *)viewController shouldShowNavigationBar] animated:animated];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        CGPoint point = [gestureRecognizer locationInView:self.view];
        UIView *subview = [self.view hitTest:point withEvent:nil];
        BOOL subviewIsSlider = [subview isKindOfClass:[HLRangeSlider class]] || [subview isKindOfClass:[UISlider class]];
        BOOL isInteractivePopForRootVC = gestureRecognizer == self.interactivePopGestureRecognizer && self.viewControllers.count <= 1;

        if (subviewIsSlider || isInteractivePopForRootVC) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)removeAllViewControllersExceptCurrent
{
    self.viewControllers = @[[self.viewControllers lastObject]];
}

#pragma mark autorotation

- (BOOL)shouldAutorotate
{
    if (iPhone() && !_allowedIphoneAutorotate) {
        return NO;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (iPhone() && !_allowedIphoneAutorotate) {
        return UIInterfaceOrientationMaskPortrait;
    }
	return [super supportedInterfaceOrientations];
}

@end
