//
//  UIFloatLabelTextField+Border.m
//  Example
//
//  Created by Adriano Soares on 13/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"

@implementation UIFloatLabelTextField (Border)

- (void) setBottomBorderWithColor:(UIColor *) color {
    self.bottomBorderView = [UIView new];
    self.bottomBorderView .backgroundColor = color;
    [self.bottomBorderView  setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    self.bottomBorderView .frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
    [self addSubview:self.bottomBorderView];
}

- (void) showFieldWithError:(BOOL) showError {
    LayoutManager *lm = [LayoutManager sharedManager];
    if (showError) {
        self.bottomBorderView .backgroundColor = [lm errorColor];
    } else {
        self.bottomBorderView .backgroundColor = [lm lightGray];
    }


}

@end
