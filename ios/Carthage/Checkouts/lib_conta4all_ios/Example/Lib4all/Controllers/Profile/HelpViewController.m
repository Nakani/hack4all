//
//  HelpViewController.m
//  Example
//
//  Created by Cristiano Matte on 01/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "HelpViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "User.h"
#import <ZDCChat/ZDCChat.h>
#import "UIImage+Color.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UIView *topRoundView;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *contactUsLabel;
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *disclosure;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Configura navigation bar
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
}

#pragma mark - Actions

- (IBAction)mailButtonTouched {
    NSURL *url = [[NSURL alloc] initWithString:@"mailto://ajuda@4all.com"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chatButtonTouched {
    [ZDCChat initializeWithAccountKey:@"41j6mInD9i6LHjwvOXPmlvBQVbG6fceJ"];
    
    
    // Personaliza layout do chat
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    [[ZDCPreChatFormView appearance] setFormBackgroundColor:layoutManager.backgroundColor];
    [[ZDCOfflineMessageView appearance] setFormBackgroundColor:layoutManager.backgroundColor];
    [[ZDCChatView appearance] setChatBackgroundColor:layoutManager.backgroundColor];
    [[ZDCLoadingView appearance] setLoadingBackgroundColor:layoutManager.backgroundColor];
    [[ZDCLoadingErrorView appearance] setErrorBackgroundColor:layoutManager.backgroundColor];
    [[ZDCChatUI appearance] setChatBackgroundColor:layoutManager.backgroundColor];
    
    [[ZDCLoadingErrorView appearance] setButtonTitleColor:layoutManager.lightFontColor];
    [[ZDCLoadingErrorView appearance] setButtonBackgroundColor:layoutManager.darkGreen];
    
    [[ZDCVisitorChatCell appearance] setTextColor:layoutManager.lightFontColor];
    [[ZDCVisitorChatCell appearance] setBubbleColor:layoutManager.gradientColor];
    [[ZDCVisitorChatCell appearance] setBubbleBorderColor:layoutManager.darkGray];
    [[ZDCAgentChatCell appearance] setBubbleColor:layoutManager.primaryColor];
    [[ZDCAgentChatCell appearance] setBubbleBorderColor:layoutManager.darkGray];
    [[[ZDCChat instance] overlay] setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidLayout:) name:ZDC_CHAT_UI_DID_LAYOUT object:nil];
    
    // Adiciona dados do usuário logado
    User *user = [User sharedUser];
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        visitor.phone = user.phoneNumber;
        visitor.email = user.emailAddress;
        visitor.name = user.fullName;
    }];
    
    [ZDCChat startChatIn:self.navigationController withConfig:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptional;
        config.preChatDataRequirements.email = ZDCPreChatDataRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequiredEditable;
        config.preChatDataRequirements.department = ZDCPreChatDataRequiredEditable;
    }];
}

- (void)chatDidLayout:(NSNotification*)notification {
    ZDCChatViewController *controller = [ZDCChat instance].chatViewController;
    controller.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - Layout

- (void)configureLayout {
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    self.topSeparatorViewHeightConstraint.constant = 0.5;
    self.bottomSeparatorViewHeightConstraint.constant = 0.5;
    
    // Configura layout da view redonda com foto/logo da 4all
    [self.topRoundView layoutIfNeeded];
    self.topRoundView.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    self.topRoundView.layer.cornerRadius = self.topRoundView.frame.size.height / 2;
    
    // Configura layout das labels
    self.helpLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].subTitleFontSize];
    self.helpLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    self.contactUsLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].midFontSize];
    self.contactUsLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    // Configura layout das separator views
    self.topSeparatorView.backgroundColor = [[LayoutManager sharedManager] primaryColor];
    self.bottomSeparatorView.backgroundColor = [[LayoutManager sharedManager] primaryColor];
    self.disclosure.image = [self.disclosure.image withColor:[LayoutManager sharedManager].primaryColor];
    
    // Configura layout do botao de chat
    CGFloat fontSize = [LayoutManager sharedManager].regularFontSize;
    CGFloat totalPadding = 36.0;
    
    self.chatButton.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:fontSize];
    [self.chatButton setTitleColor:[[LayoutManager sharedManager] darkFontColor] forState:UIControlStateNormal];
    [self.chatButton setTitleColor:[[LayoutManager sharedManager] darkFontColor] forState:UIControlStateHighlighted];
    
    [self.chatButton layoutIfNeeded];
    CGFloat centerX = (totalPadding / 2) + 1;
    CGFloat centerY = self.chatButton.bounds.size.height / 2;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fontSize, fontSize)];
    iconImageView.image = [[UIImage lib4allImageNamed:@"iconHelp"] withColor:[LayoutManager sharedManager].primaryColor];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.center = CGPointMake(centerX, centerY);
    [self.chatButton addSubview:iconImageView];
    self.chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, totalPadding, 0, 0);
    
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
