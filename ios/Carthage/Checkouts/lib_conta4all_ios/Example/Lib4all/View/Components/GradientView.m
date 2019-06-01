//
//  GradientView.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "GradientView.h"
#import "UIView+Gradient.h"
#import "LayoutManager.h"

@interface GradientView ()
@property CAGradientLayer *gradient;
@end

@implementation GradientView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self render];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self render];
}

- (void)prepareForInterfaceBuilder {
    [self render];
}

- (void)render {
    LayoutManager *layout = [LayoutManager sharedManager];
    _gradient = [self setGradientFromColor:[layout primaryColor] toColor:[layout gradientColor]];
}

-(void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    _gradient.bounds = self.bounds;
}
@end
