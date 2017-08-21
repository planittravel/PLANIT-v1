//
//  ASTSearchFormSceneViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "PLANIT_v1-Swift.h"

#import "ASTSearchFormSceneViewController.h"
#import "ASTContainerSearchFormViewController.h"

@interface ASTSearchFormSceneViewController ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ASTSearchFormSceneViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
}

#pragma mark - Setup

- (void)setupViewController {
    [self applyStyle];
    [self setupNavigationItems];
    [self instantiateChildViewController];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)applyStyle {
    self.view.backgroundColor = [UIColor clearColor];
    self.shadowView.backgroundColor = [UIColor clearColor];
    [self.shadowView applyShadowLayer];
}

- (void)setupNavigationItems {
    self.navigationItem.title = NSLS(@"JR_SEARCH_FORM_TITLE");
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
}

- (void)instantiateChildViewController {
    
    ASTContainerSearchFormViewController *containerSearchFormViewController = [[ASTContainerSearchFormViewController alloc] init];
    
    [self addChildViewController:containerSearchFormViewController];
    [self.containerView addSubview:containerSearchFormViewController.view];
    
    containerSearchFormViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addConstraints:JRConstraintsMakeScaleToFill(containerSearchFormViewController.view, self.containerView)];
    
    [containerSearchFormViewController didMoveToParentViewController:self];
}

@end
