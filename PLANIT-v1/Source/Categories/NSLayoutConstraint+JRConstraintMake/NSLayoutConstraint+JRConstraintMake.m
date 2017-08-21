//
//  NSLayoutConstraint+JRConstraintMake.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "PLANIT_v1-Swift.h"

#import "NSLayoutConstraint+JRConstraintMake.h"

@implementation NSLayoutConstraint (JRConstraintMake)

NSArray <NSLayoutConstraint *> *JRConstraintsMakeScaleToFill(id item,
                                                             id toItem) {
    
    NSMutableArray <NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeTop, NSLayoutRelationEqual, toItem, NSLayoutAttributeTop, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeLeft, NSLayoutRelationEqual, toItem, NSLayoutAttributeLeft, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeBottom, NSLayoutRelationEqual, toItem, NSLayoutAttributeBottom, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeRight, NSLayoutRelationEqual, toItem, NSLayoutAttributeRight, 1, 0)];
    
    return [constraints copy];
}

NSArray <NSLayoutConstraint *> *JRConstraintsMakeEqualSize(id item,
                                                           id toItem) {
    
    NSMutableArray <NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeWidth, NSLayoutRelationEqual, toItem, NSLayoutAttributeWidth, 1, 0)];
    [constraints addObject:JRConstraintMake(item, NSLayoutAttributeHeight, NSLayoutRelationEqual, toItem, NSLayoutAttributeHeight, 1, 0)];
    
    return [constraints copy];
}

NSLayoutConstraint *JRConstraintMake(id item,
                                     NSLayoutAttribute attribute,
                                     NSLayoutRelation relation,
                                     id toItem,
                                     NSLayoutAttribute secondAttribute,
                                     CGFloat multiplier,
                                     CGFloat constant) {
    
    NSLayoutConstraint *constaint = [NSLayoutConstraint constraintWithItem:item
                                        attribute:attribute
                                        relatedBy:relation
                                           toItem:toItem
                                        attribute:secondAttribute
                                       multiplier:multiplier
                                         constant:constant];
    return constaint;
}

@end
