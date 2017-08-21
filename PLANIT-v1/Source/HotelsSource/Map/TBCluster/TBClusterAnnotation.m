//
//  TBClusterAnnotation.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/8/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//
#import "PLANIT_v1-Swift.h"

#import "TBClusterAnnotation.h"

@implementation TBClusterAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate variants:(NSArray *)variants
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _variants = variants;
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

@end
