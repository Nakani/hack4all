//
//  ErrorTextField.h
//  Example
//
//  Created by Luciano Acosta on 27/04/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorTextField : UITextField

@property (nonatomic, strong) NSString *regex;
@property (assign) BOOL validateWithRegex;
//@property (nonatomic, strong) UILabel *messageLabel;

- (BOOL)checkIfContentIsValid:(BOOL)showValidation;
- (void)showFieldWithError:(BOOL)isValid;
- (void)setBorder:(UIColor *)color width:(CGFloat)width;
- (void)roundTopCornersRadius:(CGFloat)radius;
- (void)roundBottomCornersRadius:(CGFloat)radius;
- (void)roundCustomCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners;
- (void)setIconsImages:(UIImage *)img errorImg:(UIImage *)errorImg;

@end
