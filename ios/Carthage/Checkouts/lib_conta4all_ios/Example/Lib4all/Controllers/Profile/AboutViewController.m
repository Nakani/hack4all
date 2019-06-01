//
//  AboutViewController.m
//  Example
//
//  Created by Cristiano Matte on 27/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "AboutViewController.h"
#import "LayoutManager.h"
#import "User.h"
#import "Lib4allInfo.h"
#import "Lib4allPreferences.h"
#import "BaseNavigationController.h"
#import <ZDCChat/ZDCChat.h>
#import "UIImage+Color.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIView *topRoundView;
@property (weak, nonatomic) IBOutlet UILabel *forAllLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *termsOfUseButton;
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *disclosure;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
}

#pragma mark - Actions

- (IBAction)termsOfUseButtonTouched {
    [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] termsOfServiceURL]];
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Layout

- (void)configureLayout {
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];

    self.topSeparatorViewHeightConstraint.constant = 0.5;
    self.bottomSeparatorViewHeightConstraint.constant = 0.5;
    
    // Configura navigation bar
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    // Configura layout da view redonda com foto/logo da 4all
    [self.topRoundView layoutIfNeeded];
    self.topRoundView.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    self.topRoundView.layer.cornerRadius = self.topRoundView.frame.size.height / 2;
    
    // Configura layout das labels
    self.forAllLabel.font = [[LayoutManager sharedManager] fontWithSize:18];
    self.forAllLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    self.versionLabel.font = [[LayoutManager sharedManager] fontWithSize:14];
    self.versionLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    self.versionLabel.text = [NSString stringWithFormat:@"versão %@", Lib4allVersion];
    
    // Configura layout das separator views
    self.topSeparatorView.backgroundColor = [[LayoutManager sharedManager] primaryColor];
    self.bottomSeparatorView.backgroundColor = [[LayoutManager sharedManager] primaryColor];
    self.disclosure.image = [self.disclosure.image withColor:[LayoutManager sharedManager].primaryColor];
    
    // Configura layout do botao de termos de uso
    CGFloat fontSize = [[LayoutManager sharedManager] regularFontSize];
    CGFloat totalPadding = 36.0;

    self.termsOfUseButton.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:fontSize];
    [self.termsOfUseButton setTitleColor:[[LayoutManager sharedManager] darkFontColor] forState:UIControlStateNormal];
    [self.termsOfUseButton setTitleColor:[[LayoutManager sharedManager] darkFontColor] forState:UIControlStateHighlighted];
    
    [self.termsOfUseButton layoutIfNeeded];
    CGFloat centerX = (totalPadding / 2) + 1;
    CGFloat centerY = self.termsOfUseButton.bounds.size.height / 2;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fontSize, fontSize)];
    iconImageView.image = [[UIImage lib4allImageNamed:@"iconTermsOfUse"] withColor:[LayoutManager sharedManager].primaryColor];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.center = CGPointMake(centerX, centerY);
    [self.termsOfUseButton addSubview:iconImageView];
    self.termsOfUseButton.titleEdgeInsets = UIEdgeInsetsMake(0, totalPadding, 0, 0);
    
    
    // Configura botão de fechar se a view for apresentada modalmente
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}

@end
