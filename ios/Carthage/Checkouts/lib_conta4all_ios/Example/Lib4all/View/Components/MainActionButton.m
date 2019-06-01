//
//  MainActionButton.m
//  Example
//
//  Created by Cristiano Matte on 13/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "MainActionButton.h"
#import "UIButton+Color.h"
#import "LayoutManager.h"

@interface MainActionButton ()
@property CAGradientLayer *gradient;

@end

@implementation MainActionButton


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

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)render {
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    LayoutManager *layout = [LayoutManager sharedManager];
    //self.backgroundColor = [[LayoutManager sharedManager] lightGreen];
//    [self setBackgroundColor:[layout primaryColor] forState:UIControlStateNormal];
//    [self setBackgroundColor:[layout gradientColor] forState:UIControlStateDisabled];
    [self updateConstraints];
    _gradient = [self setGradientFromColor:layout.mainButtonColor toColor:layout.mainButtonGradientColor];
    
    [self setTitleColor:layout.lightFontColor forState:UIControlStateNormal];
    self.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.regularFontSize];
    
    [self addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonNormal:) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
}

- (void)buttonHighlight:(UIButton*)sender {
    self.backgroundColor = [[LayoutManager sharedManager] gradientColor];
}

- (void)buttonNormal:(UIButton*)sender {
    self.backgroundColor = [[LayoutManager sharedManager] primaryColor];
}

- (void) buttonDisabled:(UIButton*)sender {
    self.backgroundColor = [[LayoutManager sharedManager] lightGray];
}

-(void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    _gradient.frame = self.bounds;
}

@end
