//
//  CashInMapAnnotation.m
//  Lib4all
//
//  Created by Gabriel Miranda Silveira on 07/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CashInMapAnnotation.h"

@implementation CashInMapAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

@end
