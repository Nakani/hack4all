//
//  ChoosePaymentTypeViewController.m
//  Example
//
//  Created by Cristiano Matte on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ChoosePaymentTypeViewController.h"
#import "ComponentViewController.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "CreditCardsList.h"
#import "BaseNavigationController.h"
#import "Services.h"
#import "AnalyticsUtil.h"

@interface ChoosePaymentTypeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *chooseCardLabel;
@property (weak, nonatomic) IBOutlet UIView *componentView;

@property (copy, nonatomic) NSString *selectedCardId;
@property (assign) BOOL askCvv;

@property ComponentViewController *componentVC;

@end

@implementation ChoosePaymentTypeViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AnalyticsUtil createScreenViewWithName:@"confirmacao_pagamento"];
    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configurePaymentComponent];
}

// MARK: - Actions

- (IBAction)continueButtonTouched {
    _signFlowController.selectedCardId = _selectedCardId;
    _signFlowController.askCvv = _askCvv;
    [_signFlowController viewControllerDidFinish:self];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// MARK: - Layout

- (void)configureLayout {
    // Configura view
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    // Configura navigation bar
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Cartão";
    /*
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgTitle.image = [UIImage lib4allImageNamed:@"4allwhite"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imgTitle;
    */
    
    self.chooseCardLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.chooseCardLabel.textColor = [layoutManager darkFontColor];
    
    _componentVC = [[ComponentViewController alloc] init];
    
    _componentVC.delegate = self;
    
    _componentVC.buttonTitleWhenNotLogged = @"Continuar";
    _componentVC.buttonTitleWhenLogged = @"Continuar";
    
    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    _componentVC.view.frame = self.componentView.bounds;
    
    //Adiciona view do component ao controller
    [self.componentView addSubview:_componentVC.view];
    
    //Adiciona a parte funcional ao container
    [self addChildViewController:_componentVC];
    [_componentVC didMoveToParentViewController:self];
}

- (void) configurePaymentComponent{
    
    if (_componentVC != nil) {
        [_componentVC.view removeFromSuperview];
        [_componentVC removeFromParentViewController];
    }
    
    _componentVC = [[ComponentViewController alloc] init];
    
    _componentVC.delegate = self;
    
    _componentVC.buttonTitleWhenNotLogged = @"Continuar";
    _componentVC.buttonTitleWhenLogged = @"Continuar";
    
    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    _componentVC.view.frame = self.componentView.bounds;
    
    //Adiciona view do component ao controller
    [self.componentView addSubview:_componentVC.view];
    
    //Adiciona a parte funcional ao container
    [self addChildViewController:_componentVC];
    [_componentVC didMoveToParentViewController:self];
}

- (void) callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode cvv:(NSString *)cvv {
    _selectedCardId = cardId;
    _askCvv = [[[CreditCardsList sharedList] getCardWithID:cardId] askCvv];
    
    _signFlowController.selectedCardId = _selectedCardId;
    _signFlowController.askCvv = _askCvv;
    [self dismissViewControllerAnimated:YES completion:^{
       [_signFlowController viewControllerDidFinish:self];
    }];
}

@end
