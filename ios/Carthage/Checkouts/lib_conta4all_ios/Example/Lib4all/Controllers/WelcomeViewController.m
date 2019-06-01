//
//  WelcomeViewController.m
//  Example
//
//  Created by 4all on 20/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "WelcomeViewController.h"
#import "BEMCheckBox.h"
#import "Lib4allPreferences.h"
#import "LayoutManager.h"
#import "Services.h"
#import "User.h"
#import "ServicesConstants.h"
#import "Lib4all.h"
#import "CardAdditionFlowController.h"
#import "AnalyticsUtil.h"

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonNewCard;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinishFlow;
@property (weak, nonatomic) IBOutlet UILabel *labelGreetings;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *appIconImageView;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [AnalyticsUtil createScreenViewWithName:@"bem_vindo"];

    [self setupController];
}

- (void) setupController {
    LayoutManager *lm = [LayoutManager sharedManager];
    [_buttonFinishFlow.titleLabel setFont:[lm fontWithSize:lm.regularFontSize]];
    [_buttonFinishFlow setTitleColor:[lm darkFontColor] forState:UIControlStateNormal];
    [_buttonFinishFlow.layer setCornerRadius:6.0f];
    [_buttonFinishFlow.layer setBorderColor:lm.primaryColor.CGColor];
    _buttonFinishFlow.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [_labelGreetings setFont:[lm boldFontWithSize:lm.regularFontSize]];
    [_labelGreetings setTextColor:lm.darkFontColor];
    
    [_labelDescription setFont:[lm fontWithSize:lm.regularFontSize]];
    [_labelDescription setTextColor:lm.darkFontColor];
    
    _appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    if([Lib4allPreferences sharedInstance].appIcon != nil) {
        _appIconImageView.image = [Lib4allPreferences sharedInstance].appIcon;
    }
    
    NSArray *name = [_signFlowController.accountData[@"fullName"] componentsSeparatedByString:@" "];
    [self.labelGreetings setText:[self.labelGreetings.text stringByReplacingOccurrencesOfString:@"@name" withString: name[0]]];
    
    NSString *wizardAppName = [Lib4allPreferences sharedInstance].wizardAppName;
    _labelDescription.text = [_labelDescription.text stringByReplacingOccurrencesOfString:@"4all" withString:wizardAppName];
    
    [_buttonFinishFlow setTitle:[_buttonFinishFlow.currentTitle stringByReplacingOccurrencesOfString:@"4all" withString:wizardAppName] forState:UIControlStateNormal];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.topView.backgroundColor = lm.primaryColor;
    
    if (_signFlowController.requirePaymentData) {
        [_buttonNewCard setTitle:@"Continuar" forState:UIControlStateNormal];
        [_buttonFinishFlow setTitle:@"Cancelar" forState:UIControlStateNormal];
    }
    
}


- (IBAction)addNewCard {
    // Inicia fluxo de adição de cartão
    
    [AnalyticsUtil createEventWithCategory:@"account" action:@"add card" label:@"add first card" andValue:nil];

    
    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:_signFlowController.acceptedPaymentTypes andAcceptedBrands:_signFlowController.acceptedBrands];
    flowController.loginWithPaymentCompletion = _signFlowController.loginWithPaymentCompletion;
    flowController.loginCompletion = _signFlowController.loginCompletion;
    flowController.onLoginOrAccountCreation = YES;
    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
    [flowController startFlowWithViewController:self];
}

- (IBAction)finishFlow {
    
    [AnalyticsUtil createEventWithCategory:@"account" action:@"start" label:@"start using app" andValue:nil];

    
    // Exibe alerta para confirmar a alteração do dado
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:@"Ao cancelar, o pagamento não será realizado.\nVocê confirma essa ação?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Não"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Sim"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self cancelAndContinueToAppAction];
                                            }]];
    
    if (_signFlowController.requirePaymentData) {
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self cancelAndContinueToAppAction];
    }
    
}

-(void)cancelAndContinueToAppAction{
    if ([[Lib4all sharedInstance].userStateDelegate respondsToSelector:@selector(userDidLogin)]) {
        [[Lib4all sharedInstance].userStateDelegate userDidLogin];
    }
    _signFlowController.isLogin = NO;
    _signFlowController.skipPayment = YES;
    [_signFlowController viewControllerDidFinish:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
