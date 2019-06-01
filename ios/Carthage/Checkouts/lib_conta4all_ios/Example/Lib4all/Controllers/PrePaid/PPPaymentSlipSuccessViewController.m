//
//  PPPaymentSlipSuccessViewController.m
//  Example
//
//  Created by Adriano Soares on 28/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPPaymentSlipSuccessViewController.h"
#import "LayoutManager.h"
#import "PrePaidServices.h"
#import "Services.h"
#import "LoadingViewController.h"
#import "UIView+Gradient.h"
#import "AMPopTip.h"
#import "CurrencyUtil.h"
#import "PPPaymentSlipsViewController.h"
#import "AnalyticsUtil.h"

@interface PPPaymentSlipSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentSlipLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentSlipAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *barCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *barCodeNumberLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation PPPaymentSlipSuccessViewController

static NSString* const kNavigationTitle = @"Adicionar dinheiro";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.paymentSlipAmountLabel.text = [CurrencyUtil currencyFormatter:self.amount];
    

    self.expirationDateLabel.text = self.expirationDate;
    
    self.barCodeNumberLabel.text  = self.barCode;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"left-nav-arrow"]
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(closeButtonTouched)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    [self configureLayout];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (IBAction)copyTouched:(id)sender {

    [AnalyticsUtil logEventWithName:@"copiar_codigo_barras" andParameters:nil];
    
    if(![self.barCode isEqualToString:@""] && self.barCode != nil) {
        UIPasteboard.generalPasteboard.string = self.barCode;
        [self displayToolTip:sender withMessage:@"Código copiado!"];
    } else {
        [self displayToolTip:sender withMessage:@"Erro!"];
    }
}

- (IBAction)sendEmailTouched:(id)sender {
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    [AnalyticsUtil logEventWithName:@"enviar_boleto_email" andParameters:nil];
    
    Services *services = [[Services alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [loading finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:self
                  title:@"Atenção"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    services.successCase = ^(NSDictionary *response) {
        [loading finishLoading:^{
            [self displayToolTip:sender withMessage:@"Enviado para o seu e-mail!"];
        }];
    };
    
    [loading startLoading:self title:@"Aguarde ..."];
    [services resendEmailPaymentSlip:self.paymentId];
}


- (void) displayToolTip:(UIView *) parent withMessage:(NSString *) message{
    AMPopTip *popTip = [AMPopTip popTip];

    [popTip showText:message direction:AMPopTipDirectionUp maxWidth:200 inView:self.scrollView fromFrame:parent.frame];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [popTip hide];
    });
}

- (void) closeButtonTouched {
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[PPPaymentSlipsViewController class]]) {
            PPPaymentSlipsViewController *destination = self.navigationController.viewControllers[i];
            [destination.tabBarViewController setSelectedIndex:1];
            [destination loadData];
            [self.navigationController popToViewController:destination animated:YES];
        }
    }
}

- (void) configureLayout {
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    self.titleLabel.font = [layout fontWithSize:layout.titleFontSize];
    self.titleLabel.textColor = layout.lightFontColor;
    
    NSArray *regularLabels = @[_paymentSlipLabel, _expirationLabel, _barCodeLabel];
    for (int i = 0; i < regularLabels.count; i++) {
        UILabel *label = regularLabels[i];
        
        label.font = [layout fontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }
    
    NSArray *boldLabels = @[_paymentSlipAmountLabel, _expirationDateLabel, _barCodeNumberLabel];
    for (int i = 0; i < boldLabels.count; i++) {
        UILabel *label = boldLabels[i];
        
        label.font = [layout boldFontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }

    AMPopTip *appearance = [AMPopTip appearance];
    appearance.textColor = layout.lightFontColor;
    appearance.popoverColor = [layout primaryColor];
    
}

@end
