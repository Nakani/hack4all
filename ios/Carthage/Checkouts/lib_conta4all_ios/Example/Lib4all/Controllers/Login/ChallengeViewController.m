//
//  ChallengeViewController.m
//  Example
//
//  Created by 4all on 4/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ChallengeViewController.h"
#import "User.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "ErrorTextField.h"
#import "UIColor+HexString.h"
#import "Lib4all.h"
#import "AccountCreatedViewController.h"
#import "CardAdditionFlowController.h"
#import "UIImage+Color.h"

@interface ChallengeViewController() < UITextFieldDelegate >

@property (weak, nonatomic) IBOutlet UILabel *lastStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *insertCodeLabel;
@property (weak, nonatomic) IBOutlet ErrorTextField *challengeTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBySMSButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeByEmailButton;

@end


@implementation ChallengeViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [self sendLoginSms:NO];
    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_challengeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_challengeTextField resignFirstResponder];
}

// MARK: - Methods
-(void) sendLoginSms:(BOOL)showAlertOnSuccess {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [alert show];
        self.sendCodeBySMSButton.enabled = YES;
    };
    
    service.successCase = ^(NSDictionary *response){
        if (showAlertOnSuccess) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:@"Código reenviado por SMS!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Fechar"
                                                  otherButtonTitles:nil];
            [alert show];
            self.sendCodeBySMSButton.enabled = YES;
        }
    };
    
    self.sendCodeBySMSButton.enabled = NO;
    [service sendLoginSms];
}

// MARK: - Actions

- (void)completeLoginOrCreation:(NSString *)code {
    Services *service = [[Services alloc] init];
    LoadingViewController *loading = [[LoadingViewController alloc] init];

    // Completion comum para os casos em que há algum erro nas requisições de dados do usuário
    void (^failureCase)(NSString *, NSString *) = ^(NSString *cod, NSString *msg) {
        // Informa o usuário sobre uma falha no login
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:@"Falha na conexão. Tente novamente mais tarde."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // Faz logout para remover todos os dados do usuários já baixados e fecha a tela de challenge
            [[Lib4all sharedInstance] callLogoutWithoutAction:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:ok];
        [loading finishLoading:^{
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };

    // O último passo para finalizar o login é obter a foto de usuário
    void (^getAccountPhoto)(void) = ^{
        Services *getAccountPhotoService = [[Services alloc] init];
        
        getAccountPhotoService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountPhotoService.successCase = ^(NSDictionary *response) {
            if ([[Lib4all sharedInstance].userStateDelegate respondsToSelector:@selector(userDidLogin)]) {
                [[Lib4all sharedInstance].userStateDelegate userDidLogin];
            }
            
            [loading finishLoading:^{
                [User sharedUser].currentState = UserStateOnLogin;
                [_signFlowController viewControllerDidFinish:self];
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
    
    // O primeiro passo da finalização de login é verificar o challenge
    [loading startLoading:self title:@"Aguarde..."];
    
    service.successCase = ^(NSDictionary *data) {
        getAccountData();
    };
    
    service.failureCase = ^(NSString *code, NSString *msg) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [loading finishLoading:^{
            [alert show];
            [self.challengeTextField showFieldWithError:NO];
        }];
    };
    
    if (_signFlowController.isLogin) {
        [service completeLoginWithChallenge:code accountData:_signFlowController.accountData socialData:_signFlowController.socialSignInData];
    } else {
        [service completeCustomerCreationWithChallenge:code password:_signFlowController.enteredPassword accountData:_signFlowController.accountData socialData:_signFlowController.socialSignInData];
    }
}

- (IBAction)callSendLoginSMS {
    [self sendLoginSms:YES];
}

- (IBAction)callSendLoginEmail:(id)sender {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [alert show];
        self.sendCodeByEmailButton.enabled = YES;
    };
    
    service.successCase = ^(NSDictionary *response){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:@"Código enviado por e-mail!"
                                                       delegate:self
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [alert show];
        self.sendCodeByEmailButton.enabled = YES;
    };
    
    self.sendCodeByEmailButton.enabled = NO;
    [service sendLoginEmail];
}

- (IBAction)completeLoginOrCreation {
    [self completeLoginOrCreation:self.challengeTextField.text];
}

- (IBAction)closeVc:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.challengeTextField showFieldWithError:YES];
    
    NSString* challenge = [textField text];
    challenge = [challenge stringByReplacingCharactersInRange:range withString:string];
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^[0-9]{0,6}$" options:0 error:nil];
    int numberOfMatches = (int)[regex numberOfMatchesInString:challenge options:0 range:NSMakeRange(0, challenge.length)];
    
    if (![challenge isEqualToString:@""] && numberOfMatches == 0) {
        return NO;
    }
    
    if (challenge.length == 6) {
        [self.view endEditing:YES];
        [self completeLoginOrCreation:challenge];
        self.challengeTextField.text = challenge;
    }
    
    return challenge.length < 6 ? YES : NO;
}

// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueAccountCreationCompleted"]) {
        AccountCreatedViewController *nextViewController = segue.destinationViewController;
        nextViewController.signFlowController = _signFlowController;
    }
}

// MARK: - Layout

- (void)configureLayout {
    // Configura navigation bar
    LayoutManager *layoutManager = [LayoutManager sharedManager];

    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgTitle.image = [UIImage lib4allImageNamed:@"4allwhite"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imgTitle;
    self.navigationItem.leftBarButtonItem.tintColor = layoutManager.lightFontColor;
    
    // Configura view
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    self.lastStepLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.lastStepLabel.textColor = [layoutManager darkFontColor];
    
    self.insertCodeLabel.font = [layoutManager fontWithSize:[layoutManager subTitleFontSize]];
    self.insertCodeLabel.textColor = [layoutManager darkFontColor];
    
    self.challengeTextField.regex = @"^[0-9]{6}$";
    
    UIColor *redColor = [layoutManager red];
    
    // Configura o text field do desafio
    [self.challengeTextField roundCustomCornerRadius:5.0 corners:UIRectCornerAllCorners];
    self.challengeTextField.backgroundColor = [UIColor whiteColor];
    [self.challengeTextField setBorder:[layoutManager lightGray] width:1];
    self.challengeTextField.font = [layoutManager fontWithSize:[[LayoutManager sharedManager] regularFontSize]];
    self.challengeTextField.placeholder = @"000000";
    //self.challengeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"000000"
    //                                                                                attributes:@{NSForegroundColorAttributeName: [layoutManager lightGray]}];
    [self.challengeTextField setIconsImages:[UIImage lib4allImageNamed:@"iconChallenge"] errorImg:[[UIImage lib4allImageNamed:@"iconChallenge"] withColor:redColor]];
    self.challengeTextField.textColor = [layoutManager darkFontColor];
    self.challengeTextField.delegate = self;
    
    if (!_signFlowController.isLogin) {
        self.sendCodeByEmailButton.hidden = YES;
    }
}

@end
