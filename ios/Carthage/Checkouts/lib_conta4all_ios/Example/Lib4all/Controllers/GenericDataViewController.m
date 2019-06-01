//
//  GenericDataViewController.m
//  Example
//
//  Created by 4all on 12/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "GenericDataViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "MainActionButton.h"
#import "SISUNameDataField.h"
#import "SISUPhoneNumberDataField.h"
#import "SISUTokenSmsDataField.h"
#import "SISUEmailDataField.h"
#import "SISUPasswordDataField.h"
#import "SISUPasswordConfirmationDataField.h"
#import "SMSTokenDelegate.h"
#import "PopUpBoxViewController.h"
#import "User.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "NSStringMask.h"
#import "TokenTextField.h"
#import "SocialContainerViewController.h"
#import "SocialSignInDelegate.h"
#import "Lib4all.h"
#import "AnalyticsUtil.h"
#import "Lib4allPreferences.h"

@interface GenericDataViewController () <UIGestureRecognizerDelegate, SocialSignInDelegate>

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *textFieldCustom;
@property (weak, nonatomic) IBOutlet MainActionButton *mainButton;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelSubDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightGradientView;
@property (weak, nonatomic) IBOutlet UIView *containerSocial;

//Items of the first controller(input full name)
@property (weak, nonatomic) IBOutlet UILabel *labelLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

//Items of SMS controller
@property (strong) SMSTokenDelegate *delegateToken;
@property (weak, nonatomic) IBOutlet UIView *viewContainerPin;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken1;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken2;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken3;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken4;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken5;
@property (weak, nonatomic) IBOutlet TokenTextField *textToken6;
@property (weak, nonatomic) IBOutlet UIButton *buttonResendSms;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfirmToken;

@end

@implementation GenericDataViewController

static CGFloat const kBottomConstraintMin = 60.0;
SocialContainerViewController *componentSocial;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupController];

    if ([_dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]] && self.signFlowController.isLogin) {
        [self sendLoginSms:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    if ([_dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]]) {
        [_textToken1 becomeFirstResponder];
    }else{
        [_textFieldCustom becomeFirstResponder];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.navigationController.title;

    if ([_dataFieldProtocol isKindOfClass:[SISUNameDataField class]]) {
        self.bottomConstraint.constant = kBottomConstraintMin;
    } else{
        self.bottomConstraint.constant = 22.0;
    }

}



- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    self.navigationItem.title = @"";

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [self dismissKeyboard];

}


- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if ([[UIScreen mainScreen] bounds].size.height<=480.0f) {
        NSLog(@"App is running on iPhone with screen 3.5 inch");
        _heightGradientView.constant = _heightGradientView.constant - 70;
    }

    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 3 + keyboardSize.height;

        [self.view updateConstraints];
        [self.view layoutIfNeeded];

    }];

}

-(void)keyboardWillHide:(NSNotification *)notification {
    if ([[UIScreen mainScreen] bounds].size.height<=480.0f) {
        NSLog(@"App is running on iPhone with screen 3.5 inch");
        _heightGradientView.constant = 222;
    }


    [UIView animateWithDuration:0.4 animations:^{
        if ([_dataFieldProtocol isKindOfClass:[SISUNameDataField class]]) {
            self.bottomConstraint.constant = kBottomConstraintMin;
        } else{
            self.bottomConstraint.constant = 22.0;
        }

        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];

}


- (void)setupController{
    LayoutManager *lm = [LayoutManager sharedManager];
    
    self.labelDescription.text = [self.dataFieldProtocol title];
    self.labelDescription.textColor = lm.lightFontColor;
    self.labelSubDescription.text = [self.dataFieldProtocol subTitle];
    self.labelSubDescription.textColor = lm.lightFontColor;

    _loadingView = [[LoadingViewController alloc] init];

    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.textFieldCustom setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.textFieldCustom.floatLabelFont = [lm fontWithSize:[lm miniFontSize]];
    self.textFieldCustom.floatLabelActiveColor = [lm darkFontColor];
    [self.textFieldCustom setBottomBorderWithColor:[lm lightGray]];
    self.textFieldCustom.clearButtonMode = UITextFieldViewModeNever;
    self.textFieldCustom.delegate = _dataFieldProtocol;

    self.textFieldCustom.font = [lm fontWithSize:[lm regularFontSize]];
    self.textFieldCustom.textColor = [lm darkFontColor];
    [self.textFieldCustom setPlaceholder:[self.dataFieldProtocol textFieldPlaceHolder]];
    self.textFieldCustom.keyboardType = [self.dataFieldProtocol keyboardType];
    
    [_labelDescription setFont:[lm fontWithSize:[lm subTitleFontSize]]];
    [_labelSubDescription setFont:[lm fontWithSize:[lm regularFontSize]]];
    
    [_labelLogin setFont:[lm fontWithSize:[lm regularFontSize]]];
    [_labelLogin setTextColor:[lm darkFontColor]];
    [_buttonLogin.titleLabel setFont:[lm fontWithSize:[lm regularFontSize]]];
    [_buttonLogin setTitleColor:[lm primaryColor] forState:UIControlStateNormal];


    [_buttonResendSms setTitleColor:[lm primaryColor] forState:UIControlStateNormal];
    [[_buttonResendSms layer] setCornerRadius:6.0];
    [[_buttonResendSms layer] setBorderColor:[[lm primaryColor] CGColor]];
    [[_buttonResendSms layer] setBorderWidth:1.0];
    [_buttonResendSms.titleLabel setFont:[lm fontWithSize:[lm regularFontSize]]];

    //Action to dismiss keyboard
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];


    //Name Protocol
    [self nameProtocolConfigurations];

    //SMS Protocol
    [self smsProtocolConfiguration];

    //E-mail Protocol
    [self emailProtocolConfiguration];

    //Password Protocol
    [self passwordProtocolConfiguration];

    //Phone Protocol
    [self phoneNumberProtocolConfiguration];

    //Birthdate Protocol
    [self birthdateProtocolConfiguration];

    //CPF Protocol
    [self cpfProtocolConfiguration];

    User* user = [User sharedUser];
    if ([_labelDescription.text containsString:@"@name"]) {
        NSArray *fullNameSplitted;

        if (user.fullName) {
            fullNameSplitted = [user.fullName componentsSeparatedByString:@" "];
        } else  if (_signFlowController.enteredFullName) {
            fullNameSplitted = [_signFlowController.enteredFullName componentsSeparatedByString:@" "];
        }
        if (fullNameSplitted.count > 0) {
            [_labelDescription setText:[_labelDescription.text stringByReplacingOccurrencesOfString:@"@name"
                                                                              withString:fullNameSplitted[0]]];
        } else if ([_dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]])  {
            [_labelDescription setText:[_labelDescription.text stringByReplacingOccurrencesOfString:@"@name, v"
                                                                                         withString:@"V"]];

        } else {
            [_labelDescription setText:[_labelDescription.text stringByReplacingOccurrencesOfString:@"@name"
                                                                                         withString:@""]];
        }

    }

    if ([_labelDescription.text containsString:@"@phoneNumber"]) {
        NSString *phone;
        if (_signFlowController.enteredPhoneNumber) {
            phone = (NSString *)[NSStringMask maskString:[_signFlowController.enteredPhoneNumber substringFromIndex:2] withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
        } else {
            phone = user.maskedPhone;
        }
        [_labelDescription setText:[_labelDescription.text stringByReplacingOccurrencesOfString:@"@phoneNumber"
                                                                                     withString:phone]];
    }

    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    
    [_labelDescription setText:[_labelDescription.text stringByReplacingOccurrencesOfString:@"4all"
                    withString:balanceTypeFriendlyName]];
    
    [_dataFieldProtocol setAttrTitleForString:_labelDescription.text];
    [_labelDescription setAttributedText:_dataFieldProtocol.attrTitle];

}

- (void) configureSocialComponent{

    if (componentSocial != nil) {
        [componentSocial.view removeFromSuperview];
        [componentSocial removeFromParentViewController];
    }

    _containerSocial.hidden = NO;

    componentSocial = [[SocialContainerViewController alloc] init];

    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    componentSocial.view.frame = self.containerSocial.bounds;

    [componentSocial setDelegate:self];

    componentSocial.isLogin = NO;

    //Adiciona view do component ao controller
    [self.containerSocial addSubview:componentSocial.view];

    //Adiciona a parte funcional ao container
    [self addChildViewController:componentSocial];
    [componentSocial didMoveToParentViewController:componentSocial];

}

#pragma mark - Social DElegates
-(void)socialLoginDidFinishWithToken:(NSString *)token fromSocialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK{

    if (token != nil) {
        _signFlowController.isSocialLogin = YES;
        if (_signFlowController.socialSignInData == nil) {
            _signFlowController.socialSignInData = [[NSMutableDictionary alloc] init];
        }

        [self continueFromSocialLogin:token socialMedia:socialMedia nativeSDK:nativeSDK];
    }else{
        NSLog(@"%@",@"**** Exibir mensagem ****");
    }
}

#pragma mark - Methods

-(void) continueFromSocialLogin:(NSString *)token socialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK{
    Services *service = [[Services alloc] init];

    LoadingViewController *loader = [[LoadingViewController alloc] init];

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
        [loader finishLoading:^{
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
            
            [loader finishLoading:^{
                self.signFlowController.isLogin = YES;
                [User sharedUser].currentState = UserStateLoggedIn;
                [self.signFlowController viewControllerDidFinish:self];
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

    service.failureCase = ^(NSString *cod, NSString *msg) {
        failureCase(cod, msg);

    };

    service.successCase = ^(NSDictionary *response) {
        if ([[response valueForKey:@"hasAccount"] boolValue]) {

            // Deve solicitar os dados se eles foram exigidos e não estão presentes no banco de dados
            NSArray *lackingData = response[LackingDataKey];
            _signFlowController.requireFullName = _signFlowController.requireFullName && (lackingData != nil) && [lackingData containsObject:FullNameKey];
            _signFlowController.requireCpfOrCnpj = _signFlowController.requireCpfOrCnpj && (lackingData != nil) && [lackingData containsObject:CpfKey];
            _signFlowController.requireBirthdate = _signFlowController.requireBirthdate && (lackingData != nil) && [lackingData containsObject:BirthdateKey];
            _signFlowController.isSocialLogin = YES;
            [User sharedUser].token = response[@"sessionToken"];

            getAccountData();
        }else{
            //Não há usuário vinculado
            _signFlowController.isLogin = NO;

            [_signFlowController.socialSignInData setObject:token forKey:ThirdPartyToken];
            [_signFlowController.socialSignInData setObject:@(socialMedia) forKey:ThirdPartyType];
            [_signFlowController.socialSignInData setObject:@(nativeSDK) forKey:NativeSDKKey];

            if (response[@"name"]) {
                [_signFlowController.accountData setValue:response[@"name"]
                                                   forKey:FullNameKey];
                _signFlowController.enteredFullName = response[@"name"];
                [_textFieldCustom setText:response[@"name"]];
            }

            if (response[@"email"]) {
                [_signFlowController.accountData setValue:response[@"email"]
                                                   forKey:EmailAddressKey];
                _signFlowController.enteredEmailAddress = response[@"email"];
                [loader finishLoading:^{
                    [self checkIfAccountExists:response[@"email"]];
                }];

            }else{
                [self clickButonAction:nil];
            }


            /*
             Verifica se há um usuário com esse e-mail da rede social
             Caso exista, o token da rede social é vinculado a esta conta no completeLogin
             */


        }
    };

    [loader startLoading:self title:@"Aguarde..."];
    [service thirdPartyLogin:token fromSocialMedia:socialMedia nativeSDK:nativeSDK];
}

-(void)checkIfAccountExists:(NSString *)email{
    _signFlowController.enteredEmailAddress = email;
    Services *service = [[Services alloc] init];
    service.failureCase = ^(NSString *cod, NSString *msg){
        /*
         * Caso o erro seja "Não há usuário com o telefone informado",
         * redireciona para a tela de cadastro.
         * Para qualquer outro erro, exibe um alerta.
         */
        if ([cod isEqualToString:@"3.25"]) {
            _signFlowController.isLogin = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [_loadingView finishLoading:^{
                    [self clickButonAction:nil];
                }];
            });
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loadingView finishLoading:^{
                    [self presentViewController:alert animated:YES completion:nil];
                }];
            });
        }
    };

    service.successCase = ^(NSDictionary *response){
        _signFlowController.isLogin = YES;

        _signFlowController.maskedPhoneNumber = response[MaskedPhoneKey];
        _signFlowController.maskedEmailAddress = response[MaskedEmailAddressKey];

        // Deve solicitar os dados se eles foram exigidos e não estão presentes no banco de dados
        NSArray *lackingData = response[LackingDataKey];
        _signFlowController.requireFullName = _signFlowController.requireFullName && (lackingData != nil) && [lackingData containsObject:FullNameKey];
        _signFlowController.requireCpfOrCnpj = _signFlowController.requireCpfOrCnpj && (lackingData != nil) && [lackingData containsObject:CpfKey];
        _signFlowController.requireBirthdate = _signFlowController.requireBirthdate && (lackingData != nil) && [lackingData containsObject:BirthdateKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             * Se há dados a serem inseridos, direciona para tela de adição de dados.
             * Caso contrário, direciona para tela de challenge.
             */
            [_loadingView finishLoading:^{
                [_signFlowController viewControllerDidFinish:self];
            }];
        });
    };

    NSMutableArray *requiredData = [[NSMutableArray alloc] init];
    if (_signFlowController.requireFullName) [requiredData addObject:FullNameKey];
    if (_signFlowController.requireCpfOrCnpj) [requiredData addObject:CPFKey];
    if (_signFlowController.requireBirthdate) [requiredData addObject:BirthdateKey];


    [_loadingView startLoading:self title:@"Aguarde..."];
    [service startLoginWithIdentifier:email requiredData:requiredData isCreation:NO];
}

+ (GenericDataViewController *)getConfiguredControllerWithdataFieldProtocol:(id<DataFieldProtocol>) protocol{

    GenericDataViewController *controller = [[GenericDataViewController alloc] initWithNibName:@"GenericDataViewController"bundle: [NSBundle getLibBundle]];
    controller.dataFieldProtocol = protocol;
    return controller;
}


-(void)nameProtocolConfigurations{

    //Se for a primeira tela de signup (protocolo de nome) a label e botão de login são exibidos
    if ([_dataFieldProtocol isKindOfClass:[SISUNameDataField class]]) {
        [_labelLogin setHidden:NO];
        [_buttonLogin setHidden:NO];
        [AnalyticsUtil createScreenViewWithName:@"cadastro_nome"];
        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                     style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(closeController:)];

        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationItem setLeftBarButtonItem:menuItem];
        }
        _textFieldCustom.autocapitalizationType = UITextAutocapitalizationTypeWords;

        if (_signFlowController.enteredFullName != nil && ![_signFlowController.enteredFullName isEqualToString:@""]) {
            [self.textFieldCustom setText:_signFlowController.enteredFullName];
        }else{
            [self configureSocialComponent];
        }


    }else{
        [_labelLogin setHidden:YES];
        [_buttonLogin setHidden:YES];
    }

}

-(void)emailProtocolConfiguration{
    if ([_dataFieldProtocol isKindOfClass:[SISUEmailDataField class]]) {

        [AnalyticsUtil createScreenViewWithName:@"cadastro_email"];

        //Remove a tela de SMS da pilha, caso usuario clique em voltar, não retorna para ela
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];

        //Validando o protocol, evita-se que sejam removidas outras controllers novamente caso avance e volte

        NSInteger currentIndex = [viewControllers indexOfObject:self];
        GenericDataViewController *previousController = [viewControllers objectAtIndex:currentIndex-1];

        if ([previousController.dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]]) {
            [viewControllers removeObject:previousController];
        }

        self.navigationController.viewControllers = viewControllers;

        //Preenche automaticamente caso tenha vindo do login
        if (self.signFlowController.enteredEmailAddress != nil) {
            _textFieldCustom.text = self.signFlowController.enteredEmailAddress;
        }

    }

}

-(void)passwordProtocolConfiguration{
    //if password or passwords confirmation
    if ([_dataFieldProtocol isKindOfClass:[SISUPasswordDataField class]] || [_dataFieldProtocol isKindOfClass:[SISUPasswordConfirmationDataField class]]) {
        _textFieldCustom.secureTextEntry = YES;

        if ([_dataFieldProtocol isKindOfClass:[SISUPasswordDataField class]]) {
            [AnalyticsUtil createScreenViewWithName:@"cadastro_senha"];
        }else if([_dataFieldProtocol isKindOfClass:[SISUPasswordConfirmationDataField class]]){
            [AnalyticsUtil createScreenViewWithName:@"cadastro_repetir_senha"];
        }

    }else{
        _textFieldCustom.secureTextEntry = NO;
    }
}

-(void)smsProtocolConfiguration{

    LayoutManager *lm = [LayoutManager sharedManager];

    //if SMS token screen
    if ([_dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]]) {

        [AnalyticsUtil createScreenViewWithName:@"cadastro_sms"];

        //Change font and colors
        for (int i = 1; i < 7 ; i++) {
            UITextField *fieldDigit = (UITextField *)[self.view viewWithTag:i];
            [fieldDigit setFont:[lm fontWithSize:lm.regularFontSize]];
            [fieldDigit setTextColor:lm.primaryColor];
        }

        //Delegate responsible for digits fields
        _delegateToken = [[SMSTokenDelegate alloc] init];
        _delegateToken.rootController = self;

        _textToken1.delegate = _delegateToken;
        _textToken2.delegate = _delegateToken;
        _textToken3.delegate = _delegateToken;
        _textToken4.delegate = _delegateToken;
        _textToken5.delegate = _delegateToken;
        _textToken6.delegate = _delegateToken;

        [_viewContainerPin setHidden:NO];
    }else{
        [_viewContainerPin setHidden:YES];
    }
}

-(void)phoneNumberProtocolConfiguration{
    if ([_dataFieldProtocol isKindOfClass:[SISUPhoneNumberDataField class]]) {

        [AnalyticsUtil createScreenViewWithName:@"cadastro_celular"];

        //Preenche automaticamente caso tenha vindo do login
        if (self.signFlowController.enteredPhoneNumber != nil) {
            _textFieldCustom.text =  (NSString *)[NSStringMask maskString:[self.signFlowController.enteredPhoneNumber substringFromIndex:2] withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
        }
    }

}

-(void)birthdateProtocolConfiguration{
    if ([_dataFieldProtocol isKindOfClass:[SISUBirthdateDataField class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_data_nascimento"];
    }
}

-(void)cpfProtocolConfiguration{
    if ([_dataFieldProtocol isKindOfClass:[SISUCPFDataField class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_cpf"];

    }
}

#pragma mark - Actions
-(void) closeController:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickButonAction:(id)sender {

    NSString *dataText;
    BOOL fieldIsValid;

    if ([_dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]]) {
        dataText = [NSString stringWithFormat:@"%@%@%@%@%@%@", _textToken1.text,_textToken2.text,_textToken3.text,_textToken4.text,_textToken5.text, _textToken6.text];
    }else{
        dataText = _textFieldCustom.text;
    }

    fieldIsValid = [_dataFieldProtocol isDataValid:dataText];

    //If not valid, displays the error on the text field
    [_textFieldCustom showFieldWithError:!fieldIsValid];


    if (fieldIsValid) {
//        _signFlowController.isLogin = NO;

        //Executa ação customizada
        [self.dataFieldProtocol saveData:self data:dataText withCompletion:nil];
    }

}

- (IBAction)resendSmsToken:(id)sender {

    [AnalyticsUtil createEventWithCategory:@"account" action:@"resend" label:@"resend sms token" andValue:nil];

    [self sendLoginSms:YES];
}


-(void) sendLoginSms:(BOOL)showAlertOnSuccess {
    Services *service = [[Services alloc] init];

    service.failureCase = ^(NSString *cod, NSString *msg){
        //[_loadingView finishLoading:^{
            [[[PopUpBoxViewController alloc] init] show:self
                                                  title:@"Atenção!"
                                            description:msg
                                              imageMode:Error
                                           buttonAction:^{

                                           }];
            self.buttonResendSms.enabled = YES;
        //}];
    };

    service.successCase = ^(NSDictionary *response){
        if (showAlertOnSuccess) {
            //[_loadingView finishLoading:^{
                [[[PopUpBoxViewController alloc] init] show:self
                                                      title:@"Código reenviado por SMS."
                                                description:@"Em instantes você receberá um SMS \ncontendo um código."
                                                  imageMode:Success
                                               buttonAction:^{

                                               }];
                self.buttonResendSms.enabled = YES;
            //}];
        }
    };

    self.buttonResendSms.enabled = NO;
    //[_loadingView startLoading:self title:@"Aguarde..."];
    [service sendLoginSms];
}

- (IBAction)confirmSmsToken:(id)sender {

    //TODO: Implement confirm sms
    [self clickButonAction:nil];

}

- (IBAction)callLogin:(id)sender {

    [AnalyticsUtil createEventWithCategory:@"account" action:@"login" label:@"existing account" andValue:nil];

    self.signFlowController.isLogin = YES;
    [self.signFlowController viewControllerDidFinish:self];
}


#pragma mark - Gesture Recognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    //Evita a necessidade de tocar duas vezes  no botão
    if ([touch.view isDescendantOfView:_mainButton]) {
        return NO;
    }

    return YES;
}
@end
