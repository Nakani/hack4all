//
//  AuxiliaryActionButton.m
//  Example
//
//  Created by Cristiano Matte on 13/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "AuxiliaryActionButton.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"

@implementation AuxiliaryActionButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self render];
}

- (void)prepareForInterfaceBuilder {
    [self render];
}

- (void)render {
    CGFloat fontSize = [LayoutManager sharedManager].regularFontSize;
    CGFloat totalPadding = 36.0;
    
    [self layoutIfNeeded];
    
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    self.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
    [self setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
    [self setTitleColor:[[LayoutManager sharedManager] gradientColor] forState:UIControlStateHighlighted];
    self.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:fontSize];
    [self addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonNormal:) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
    
    CGFloat centerX = (totalPadding / 2) + 1;
    CGFloat centerY = self.bounds.size.height / 2;
    
    if (self.icon != nil) {
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fontSize, fontSize)];
        
        iconImageView.image = [self.icon withColor:[LayoutManager sharedManager].primaryColor];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.center = CGPointMake(centerX, centerY);
        [self addSubview:iconImageView];
        self.titleEdgeInsets = UIEdgeInsetsMake(0, totalPadding, 0, 0);
    
    }

}

- (void)buttonHighlight:(UIButton*)sender {
    self.layer.borderColor = [[[LayoutManager sharedManager] gradientColor] CGColor];
}

- (void)buttonNormal:(UIButton*)sender {
    self.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
}

@end
