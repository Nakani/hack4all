//
//  UIButton+Color.m
//  Example
//
//  Created by Adriano Soares on 31/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UIView+Gradient.h"

@implementation UIView (Gradient)

-(CAGradientLayer *)setGradientFromColor:(UIColor *)firstColor toColor:(UIColor *)secondColor{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.bounds.size.height);
    gradient.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    gradient.startPoint = CGPointMake(0, 0);
    
    gradient.endPoint   = CGPointMake(0.5, 1);
    
    [self.layer insertSublayer:gradient atIndex:0];
        
    return gradient;
}


@end
