//
//  UIButton+Color.h
//  Example
//
//  Created by Adriano Soares on 31/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (Color)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (CAGradientLayer *)setGradientFromColor:(UIColor *)firstColor toColor:(UIColor *)secondColor;

@end
