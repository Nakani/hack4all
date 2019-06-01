//
//  CashInMapAnnotationView.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 07/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CashInMapAnnotationView.h"

@implementation CashInMapAnnotationView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView != nil) {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside) {
        for(int i=0; i<[self.subviews count]; i++) {
            isInside = CGRectContainsPoint(self.subviews[i].frame, point);
            if(isInside) {
                break;
            }
        }
    }
    return isInside;
    
}

@end
