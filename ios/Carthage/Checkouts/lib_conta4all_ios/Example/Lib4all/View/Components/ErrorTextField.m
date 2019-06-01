//
//  ErrorTextField.m
//  Example
//
//  Created by Luciano Acosta on 27/04/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ErrorTextField.h"
#import "LayoutManager.h"

@implementation ErrorTextField{
    UIImage *iconImg;
    UIImage *iconImgError;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(CGRect)textRectForBounds:(CGRect)bounds{
         return CGRectInset(bounds, 35, 0);
}

-(CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 35, 0);
}

-(BOOL)checkIfContentIsValid:(BOOL)showValidation{
    
    BOOL returnValue;
    NSString *cleanText = [self.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@")" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([self.text length]==0){
        returnValue = NO;
    }else{
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:self.regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:cleanText options:0 range:NSMakeRange(0, [cleanText length])];
        
        if (regExMatches == 0) {
            returnValue = NO;
        } else {
            returnValue = YES;
        }
    }
    
    if (!returnValue) {
        if (showValidation) {
            [self showFieldWithError:NO];
        }
    }else{
        [self showFieldWithError:YES];
    }
    
    return returnValue;
}

- (void)showFieldWithError:(BOOL)isValid{
    
    if (!isValid) {
        [self setIcon:YES];
        [self setBorder:[[LayoutManager sharedManager] red] width:1.0];
        [self.superview bringSubviewToFront:self];
        
        //Create label to show the message
//        UILabel *lblErrorMessage = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, (self.frame.origin.y+self.frame.size.height), self.frame.size.width, 15)];
//        lblErrorMessage.textColor = [UIColor colorWithRed:213.0/255.0 green:0 blue:0 alpha:1.0];
//        lblErrorMessage.font = [UIFont systemFontOfSize:12.0];
//        lblErrorMessage.tag = [self getRandomNum];
//        if (self.messageLabel == nil){
//                self.messageLabel = lblErrorMessage;
//        }
        
//        if ([self.superview viewWithTag:self.messageLabel.tag] == nil) {
//            [self.superview addSubview:self.messageLabel];
//        }
    
    }else {
//        if (self.messageLabel) {
//            [[self.superview viewWithTag:self.messageLabel.tag] removeFromSuperview];
//        }
        [self setIcon:NO];
        [self setBorder:[[LayoutManager sharedManager] lightGray] width:1.0];
    }
}

-(void)setBorder:(UIColor *)color width:(CGFloat)width{

    BOOL layerFound = NO;
    for (CALayer *frameLayer in self.layer.sublayers) {
        if ([frameLayer isKindOfClass:[CAShapeLayer class]]) {
            ((CAShapeLayer *)frameLayer).strokeColor = color.CGColor;
            layerFound = YES;
        }
        
    }
    
    if (!layerFound) {
        [self roundCorners:UIRectCornerAllCorners radius:0];
        [self setBorder:color width:width];
    }
    
    
}

-(void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    [self layoutIfNeeded];
    CGRect bounds = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.fillColor = nil;
    
    [self.layer addSublayer:frameLayer];
}

-(void)roundTopCornersRadius:(CGFloat)radius
{
    [self roundCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) radius:radius];
}

-(void)roundBottomCornersRadius:(CGFloat)radius
{
    [self roundCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) radius:radius];
}

-(void)roundCustomCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners
{
    [self roundCorners:corners radius:radius];
}

-(void)setIconsImages:(UIImage *)img errorImg:(UIImage *)errorImg{
    iconImg = img;
    iconImgError = errorImg;
    [self setIcon:NO];
}

-(void)setIcon:(BOOL)withError{
    UIImage *img;
    if (withError) {
        img = iconImgError;
    }else{
        img = iconImg;
    }
    
    float heightWidth =  32.0;
    CGFloat fontSize = 16.0;
    CGFloat centerX = (heightWidth / 2) + 2;
    CGFloat centerY = (heightWidth / 2);
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, heightWidth, heightWidth)];
    //[paddingView setBackgroundColor:[UIColor redColor]];
    [paddingView setClipsToBounds:YES];
    
    [paddingView setClipsToBounds:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fontSize, fontSize)];
    imageView.image = img;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = CGPointMake(centerX, centerY);
    [paddingView addSubview:imageView];
    
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = paddingView;

}

//-(int) getRandomNum{
//    int randNumber;
//    do{
//        int min = 100;
//        int max = 200;
//        
//        randNumber = rand() % (max - min) + min;
//        
//    }while([self.superview viewWithTag:randNumber] != nil);
//    
//    return randNumber;
//}

@end
