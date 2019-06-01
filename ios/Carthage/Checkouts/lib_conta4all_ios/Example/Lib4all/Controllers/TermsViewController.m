//
//  TermsViewController.m
//  Example
//
//  Created by 4all on 25/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "TermsViewController.h"
#import "BEMCheckBox.h"
#import "LayoutManager.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "Lib4all.h"
#import "WelcomeViewController.h"
#import "GAIDictionaryBuilder.h"
#import "AnalyticsUtil.h"

@interface TermsViewController ()

@property (weak, nonatomic) IBOutlet BEMCheckBox *checkbox;
@property (weak, nonatomic) IBOutlet UIView *termsAndConditionView;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UILabel *labelGreetings;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *appIConImageView;

@end

@implementation TermsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [AnalyticsUtil createScreenViewWithName:@"aceite_termos"];

    [self setupController];
}

#pragma mark - Actions
- (IBAction)continueSignUp {
    
    if ([_checkbox on]) {
        
        [AnalyticsUtil createEventWithCategory:@"account" action:@"agree" label:@"read and agreed with terms" andValue:nil];

        [self completeCustomerCreation:^{
            if ([Lib4allPreferences sharedInstance].registerWithoutCardAddition) {
                if ([[Lib4all sharedInstance].userStateDelegate respondsToSelector:@selector(userDidLogin)]) {
                    [[Lib4all sharedInstance].userStateDelegate userDidLogin];
                }
                _signFlowController.isLogin = NO;
                _signFlowController.skipPayment = YES;
                [_signFlowController finishSignUpWithViewController:self];
            } else {
                
                WelcomeViewController *welcomeController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController"bundle: [NSBundle getLibBundle]];
                welcomeController.signFlowController = _signFlowController;
                [self.navigationController pushViewController:welcomeController animated:YES];
            }
        }];
        
    }else{
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        [modal show:self
              title:@"Atenção"
        description:@"Para continuar, é necessário aceitar os termos e condições."
          imageMode:Error
       buttonAction:nil];
    }

    
}

- (IBAction)showTermsOfService {
    [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] termsOfServiceURL]];
}


- (IBAction)cancelSignUp {
    
    // Exibe alerta para confirmar a alteração do dado
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:@"Deseja realmente cancelar a criação da sua conta?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Não"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Sim"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [AnalyticsUtil createEventWithCategory:@"account" action:@"desagree" label:@"do not agreed with terms" andValue:nil];

                                                [_signFlowController viewControllerDidFinish:self];
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Methods
- (void) setupController {
    LayoutManager *lm = [LayoutManager sharedManager];
    [_buttonCancel.titleLabel setFont:[lm fontWithSize:lm.regularFontSize]];
    [_buttonCancel titleLabel].numberOfLines = 2;
    [_buttonCancel setTitleColor:[lm darkFontColor] forState:UIControlStateNormal];
    [_buttonCancel.layer setCornerRadius:6.0f];
    _buttonCancel.titleLabel.textAlignment = NSTextAlignmentCenter;
    _buttonCancel.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.labelGreetings.font = [lm fontWithSize:[lm subTitleFontSize]];
    self.labelGreetings.textColor = [lm darkFontColor];
    NSArray *name = [_signFlowController.enteredFullName componentsSeparatedByString:@" "];

    [self.labelGreetings setText:[self.labelGreetings.text stringByReplacingOccurrencesOfString:@"@name" withString:name[0]]];
    
    self.termsAndConditionsLabel.font = [lm fontWithSize:[LayoutManager sharedManager].midFontSize];
    self.termsAndConditionsLabel.textColor = [lm darkFontColor];
    self.termsAndConditionButton.titleLabel.font = [lm fontWithSize:[LayoutManager sharedManager].midFontSize];
    self.termsAndConditionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.topView.backgroundColor = lm.primaryColor;
    
    [self.termsAndConditionButton setTitleColor:[lm primaryColor] forState:UIControlStateNormal];
    [self.termsAndConditionButton setTitleColor:[lm gradientColor] forState:UIControlStateSelected];
    [self.termsAndConditionButton setTitleColor:[lm gradientColor] forState:UIControlStateHighlighted];
    
    self.checkbox.onAnimationType = BEMAnimationTypeFade;
    self.checkbox.offAnimationType = BEMAnimationTypeFade;
    self.checkbox.onTintColor = lm.primaryColor;
    self.checkbox.onFillColor = lm.primaryColor;
    
    self.appIConImageView.contentMode = UIViewContentModeScaleAspectFit;
    if ([Lib4allPreferences sharedInstance].appIcon != nil) {
        self.appIConImageView.image = [Lib4allPreferences sharedInstance].appIcon;
    }
    
    [self.navigationItem setHidesBackButton:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)completeCustomerCreation:(void (^)())completion{
    Services *service = [[Services alloc] init];
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    // Completion comum para os casos em que há algum erro nas requisições de dados do usuário
    void (^failureCase)(NSString *, NSString *) = ^(NSString *cod, NSString *msg) {
        // Informa o usuário sobre uma falha no login
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        
        [loading finishLoading:^{
            [modal show:self
                  title:@"Atenção"
            description:@"Falha na conexão. Tente novamente mais tarde."
              imageMode:Error
           buttonAction:^{
               // Faz logout para remover todos os dados do usuários já baixados e fecha a tela de challenge
               [[Lib4all sharedInstance] callLogoutWithoutAction:nil];
               [self dismissViewControllerAnimated:YES completion:nil];
           }];
        }];
    };
    
    // O último passo para finalizar o login é obter a foto de usuário
    void (^getAccountPhoto)(void) = ^{
        Services *getAccountPhotoService = [[Services alloc] init];
        
        getAccountPhotoService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountPhotoService.successCase = ^(NSDictionary *response) {
            [loading finishLoading:^{
                completion();
            }];
            return;
        };
        
        [getAccountPhotoService getAccountPhoto];
    };
    
    
    // O quarto passo para finalizar o login é obter as preferências de usuário
    void (^getAccountPreferences)(void) = ^{
        Services *getAccountPreferenceService = [[Services alloc] init];
        
        getAccountPreferenceService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountPreferenceService.successCase = ^(NSDictionary *response) {
            getAccountPhoto();
        };
        
        [getAccountPreferenceService getAccountPreferences:@[ReceivePaymentEmailsKey]];
    };

    
    // O terceiro passo da finalização de login é obter os cartões do usuário
    void (^getAccountCards)(void) = ^{
        Services *getAccountCardsService = [[Services alloc] init];
        
        getAccountCardsService.successCase = ^(NSDictionary *response){
            // Em caso de sucesso, chama o último passo da finalização de login
            getAccountPreferences();
        };
        
        getAccountCardsService.failureCase = ^(NSString *cod, NSString *msg){
            failureCase(cod, msg);
        };
        
        [getAccountCardsService listCards];
    };
    
    // O segundo passo da finalização de login é obter os dados do usuário
    void (^getAccountData)(void) = ^{
        Services *getAccountDataService = [[Services alloc] init];
        
        getAccountDataService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountDataService.successCase = ^(NSDictionary *response) {
            // Em caso de sucesso, chama o terceiro passo da finalização de login
            getAccountCards();
        };
        
        [getAccountDataService getAccountData:@[CustomerIdKey, PhoneNumberKey, EmailAddressKey, CpfKey, FullNameKey, BirthdateKey, EmployerKey, JobPositionKey, TotpKey]];
    };
    
    
    service.successCase = ^(NSDictionary *data) {
        getAccountData();
    };
    
    service.failureCase = ^(NSString *code, NSString *msg) {
        [loading dismissViewControllerAnimated:YES completion:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:self
                  title:@"Atenção"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    
    [loading startLoading:self title:@"Aguarde..."];
    [service completeCustomerCreationWithChallenge:_signFlowController.enteredChallenge
                                          password:_signFlowController.enteredPassword
                                       accountData:_signFlowController.accountData
                                        socialData:_signFlowController.socialSignInData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
