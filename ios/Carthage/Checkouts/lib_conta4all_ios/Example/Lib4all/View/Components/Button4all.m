//
//  Button4all.m
//  Example
//
//  Created by Cristiano Matte on 8/23/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Button4all.h"
#import "LayoutManager.h"
#import "Lib4allPreferences.h"

@interface Button4all ()

@property (strong, nonatomic) UIView *pipeView;
@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation Button4all

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self render];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self render];
    }
    
    return self;
}

- (void)prepareForInterfaceBuilder {
    [self render];
}

- (void)render {
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    self.backgroundColor = [[LayoutManager sharedManager] mainButtonColor];
    [self setTitleColor:[[LayoutManager sharedManager] lightFontColor] forState:UIControlStateNormal];
    self.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] regularFontSize]];
    
    if (self.iconImageView) [self.iconImageView removeFromSuperview];
    if (self.pipeView) [self.pipeView removeFromSuperview];
    
    /*
     * Adiciona o ícone da 4all no canto direito do botão
     */
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4all branco"]];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.iconImageView];
    
    NSLayoutConstraint *iconRightConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:-10.0];
    NSLayoutConstraint *iconCenterConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.0
                                                                             constant:0.0];
    NSLayoutConstraint *iconHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:24.0];
    NSLayoutConstraint *iconWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.iconImageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0
                                                                            constant:0.0];
    
    iconRightConstraint.active = YES;
    iconCenterConstraint.active = YES;
    iconHeightConstraint.active = YES;
    iconWidthConstraint.active = YES;
    
    /*
     * Adiciona o pipe branco ao lado do ícone da 4all
     */
    self.pipeView = [[UIView alloc] init];
    self.pipeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pipeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pipeView];
    
    NSLayoutConstraint *pipeRightConstraint = [NSLayoutConstraint constraintWithItem:self.pipeView
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.iconImageView
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:-10.0];
    NSLayoutConstraint *pipeTopConstraint = [NSLayoutConstraint constraintWithItem:self.pipeView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *pipeBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pipeView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0.0];
    NSLayoutConstraint *pipeWidthConstraint = [NSLayoutConstraint constraintWithItem:self.pipeView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:0.5];
    
    pipeRightConstraint.active = YES;
    pipeTopConstraint.active = YES;
    pipeBottomConstraint.active = YES;
    pipeWidthConstraint.active = YES;
    
    /*
     * Centraliza o título entre a borda esquerda e o pipe branco
     */
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 44.0);
}

@end
