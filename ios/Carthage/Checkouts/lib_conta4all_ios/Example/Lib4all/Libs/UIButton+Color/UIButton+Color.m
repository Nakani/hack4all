//
//  UIButton+Color.m
//  Example
//
//  Created by Adriano Soares on 31/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UIButton+Color.h"

@implementation UIButton (Color)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageFromColor:backgroundColor] forState:state];
}

-(CAGradientLayer *)setGradientFromColor:(UIColor *)firstColor toColor:(UIColor *)secondColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    gradient.startPoint = CGPointMake(0, 0);
    
    gradient.endPoint   = CGPointMake(1, 1);
    
    [self.layer insertSublayer:gradient atIndex:0];
    
    return gradient;
}


+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
