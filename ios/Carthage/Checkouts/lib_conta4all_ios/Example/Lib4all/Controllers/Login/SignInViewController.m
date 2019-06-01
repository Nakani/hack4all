//
//  SignInViewController.m
//  Example
//
//  Created by Cristiano Matte on 22/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "SocialContainerViewController.h"
#import "LoadingViewController.h"
#import "ChallengeViewController.h"
#import "SignWithSessionViewController.h"
#import "LayoutManager.h"
#import "BaseNavigationController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "Lib4allPreferences.h"
#import "LocationManager.h"
#import "Lib4allInfo.h"
#import "NSStringMask.h"
#import "UIImage+Color.h"
#import "Lib4all.h"
#import "UIView+Gradient.h"
#import "MainActionButton.h"
#import "NSBundle+Lib4allBundle.h"
#import "FXKeychain.h"
#import "AnalyticsUtil.h"

//@import Firebase;

@interface SignInViewController () < UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneOrEmaiLTextField;
@property (weak, nonatomic) IBOutlet UILabel *noLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet MainActionButton *mainButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet UIView *containerSocial;
@property (assign) BOOL isSocialLogin;
@property (strong, nonatomic) NSMutableString *rawId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kBottomConstraint;

@end

@implementation SignInViewController

static CGFloat const kBottomConstraintMin = 60.0;
static NSString* const kNavigationTitle = @"Entrar";
SocialContainerViewController *socialComponent;
LoadingViewController *loading;
// MARK: - View contoller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    NSDictionary *customerData = [Lib4all customerData];

    [self configureSocialComponent];
    [self configureLayout];

    loading = [[LoadingViewController alloc] init];

    /*
     Alteração Bruno Fernandes 7/2/2017
     Isto aqui nunca é para acontecer o.o
     coloquei um assert para forçar um erro
     if (self.signFlowController == nil) {
        self.signFlowController = [[SignFlowController alloc] init];
     }
     */
    NSAssert(self.signFlowController != nil, @"SignFlowController é nil!!");

    FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
    NSString *sessionToken = [keychain objectForKey:@"sessionToken"];
    if (sessionToken) {
        SignWithSessionViewController *signInSession = [[UIStoryboard storyboardWithName:@"Lib4all" bundle:[NSBundle getLibBundle]]
                                                        instantiateViewControllerWithIdentifier:@"SignWithSessionViewController"];

        signInSession.sessionToken = sessionToken;
        signInSession.fullName     = [keychain objectForKey:@"fullName"];
        signInSession.phone        = [keychain objectForKey:@"phoneNumber"];
        signInSession.email        = [keychain objectForKey:@"emailAddress"];

        signInSession.signFlowController = self.signFlowController;

        [self.navigationController setNavigationBarHidden:YES animated:YES];

        [self.navigationController pushViewController:signInSession animated:NO];

    }

    self.rawId = [[NSMutableString alloc] init];

    if (customerData[@"phoneNumber"] != nil) {
        NSString *data = customerData[@"phoneNumber"];
        self.rawId = data.mutableCopy;
        self.phoneOrEmaiLTextField.text = (NSString *)[NSStringMask maskString:data
                                                                   withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    }

    if (customerData[@"emailAddress"] != nil) {
        NSString *data = customerData[@"emailAddress"];
        self.rawId = data.mutableCopy;
        self.phoneOrEmaiLTextField.text = data;
    }
    
    if (self.rawId != nil && _signFlowController.socialSignInData[ThirdPartyToken] != nil) {
        [self signInButtonTouched:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self configureLayout];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationItem.title = @"";

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];


    [self dismissKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.kBottomConstraint.constant = kBottomConstraintMin;


    if (self.navigationController.viewControllers.count == 1) {
        /*
         * Os dados do controlador de fluxo a seguir devem ser resetados toda vez
         * que este view controller aparecer, para evitar que um "Voltar" para esta
         * tela mantenha dados de tentativas de login ou cadastro anteriores
         */
        _signFlowController.enteredPhoneNumber = nil;
        _signFlowController.enteredEmailAddress = nil;
        _signFlowController.accountData = nil;

        [[Lib4all sharedInstance] callLogoutWithoutAction:nil];
    }

    Lib4allPreferences *preferences = [Lib4allPreferences sharedInstance];
    _signFlowController.requireFullName = [preferences requireFullName];
    // CPF e data de nascimento são exigidos se for login com pagamento e o anti-fraude estiver ativo ou se usuário da biblioteca solicitou
    _signFlowController.requireCpfOrCnpj = (_signFlowController.requirePaymentData && [preferences.requiredAntiFraudItems[@"cpf"] isEqual: @YES]) || [preferences requireCpfOrCnpj];
    _signFlowController.requireBirthdate = (_signFlowController.requirePaymentData && [preferences.requiredAntiFraudItems[@"birthdate"] isEqual: @YES]) || [preferences requireBirthdate];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.4 animations:^{
        if([[UIScreen mainScreen] bounds].size.height < 568){
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = _heightHeader.constant - 95;
        }

        self.kBottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];

    }];


}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        if ([[UIScreen mainScreen] bounds].size.height<=480.0f) {
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = 222;
        }

        self.kBottomConstraint.constant = kBottomConstraintMin;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];

    }];

}

// MARK: - Actions

- (IBAction)signInButtonTouched:(UIButton *)sender {
    
    if (sender == nil) {
        _signFlowController.isSocialLogin = YES;
    }else{
        _signFlowController.isSocialLogin = NO;
    }
    
    if (![self loginIdValid]) {
        [self.phoneOrEmaiLTextField showFieldWithError:YES];
        if(_signFlowController.isSocialLogin) {
            _signFlowController.isLogin = NO;
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [_signFlowController viewControllerDidFinish:self];
            });
        }
        return;
        
    } else {
        [self.phoneOrEmaiLTextField showFieldWithError:NO];
    }

    // Verifica se o ID entrado é um número de telefone
    BOOL isPhoneNumber = NO;
    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                                options:0
                                                                                  error:nil];
    if ([phoneRegex numberOfMatchesInString:self.rawId options:0 range:NSMakeRange(0, self.rawId.length)] > 0) {
        isPhoneNumber = YES;
    }

    
    Services *service = [[Services alloc] init];

    if (isPhoneNumber) {
        _signFlowController.enteredPhoneNumber = [NSString stringWithFormat:@"55%@", self.rawId];
    } else {
        _signFlowController.enteredEmailAddress = self.rawId;
    }

    service.failureCase = ^(NSString *cod, NSString *msg){
        /*
         * Caso o erro seja "Não há usuário com o telefone informado",
         * redireciona para a tela de cadastro.
         * Para qualquer outro erro, exibe um alerta.
         */
        if ([cod isEqualToString:@"3.25"]) {
            _signFlowController.isLogin = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [loading finishLoading:^{
                    [_signFlowController viewControllerDidFinish:self];
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
                [loading finishLoading:^{
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
            [loading finishLoading:^{
                [_signFlowController viewControllerDidFinish:self];
            }];
        });
    };

    NSMutableArray *requiredData = [[NSMutableArray alloc] init];
    if (_signFlowController.requireFullName) [requiredData addObject:FullNameKey];
    if (_signFlowController.requireCpfOrCnpj) [requiredData addObject:CPFKey];
    if (_signFlowController.requireBirthdate) [requiredData addObject:BirthdateKey];

    // Se o ID inserido for número de telefone, deve adicionar o código do país (Brasil - 55)
    NSString *userId = self.rawId;
    if (isPhoneNumber) {
        userId = [NSString stringWithFormat:@"55%@", userId];
    }

    [loading startLoading:self title:@"Aguarde..."];
    [service startLoginWithIdentifier:userId requiredData:requiredData isCreation:NO];
}

- (IBAction)signUpButtonTouched {
    
    [AnalyticsUtil createEventWithCategory:@"account" action:@"create" label:@"new account" andValue:nil];
    
    
    _signFlowController.isLogin = NO;
    [_signFlowController viewControllerDidFinish:self];
}

- (IBAction)closeButtonTouched:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)loginIdValid {
    if ([self.rawId isEqualToString:@""]) {
        return NO;
    }

    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                                options:0
                                                                                  error:nil];

    if ([phoneRegex numberOfMatchesInString:self.rawId options:0 range:NSMakeRange(0, self.rawId.length)] > 0) {
        if (self.rawId.length == 11) {
            return YES;
        } else {
            
            LayoutManager *layoutManager = [LayoutManager sharedManager];
            
            NSString *msg = @"Confira o número do telefone \n digitado, ele deve conter o \n ddd + o número \n (00.xxxxx.xxxx).";
            
            NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:msg];
            
            NSRange range = [msg rangeOfString:@"ddd + o número"];
            
            [attrMessage addAttribute: NSFontAttributeName value:[layoutManager boldFontWithSize:layoutManager.regularFontSize] range:range];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Telefone incorreto" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert setValue:attrMessage forKey:@"attributedMessage"];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Entendi"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];

            [self presentViewController:alert animated:YES completion:nil];
        }
        return NO;
    }

    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$"
                                                                                options:0
                                                                                  error:nil];

    if ([emailRegex numberOfMatchesInString:self.rawId options:0 range:NSMakeRange(0, self.rawId.length)] > 0) {
        return YES;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"E-mail incorreto" message:@"O e-mail digitado é inválido." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Entendi"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }

    return NO;
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *newRawId = [[NSMutableString alloc] initWithString:self.rawId];

    // Se for backspace, remove último caractere, caso contrário, anexa nova string ao fim da string atual
    if ((string == nil || [string isEqualToString:@""]) && newRawId.length > 0) {
        [newRawId deleteCharactersInRange:NSMakeRange(self.rawId.length-1, 1)];
    } else {
        [newRawId appendString:string];
    }

    // Verifica se string atual é número de telefone
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                           options:0
                                                                             error:nil];
    unsigned long regexMatches = [regex numberOfMatchesInString:newRawId
                                                        options:0
                                                          range:NSMakeRange(0, newRawId.length)];

    /*
     * Se foi digitado backspace, apaga último caractere. Caso contrário, adiciona
     * caractere ao final da string se for e-mail ou telefone quando ainda não foi
     * adicionado o número máximo de caracteres.
     */
    if ((string == nil || [string isEqualToString:@""]) && self.rawId.length > 0) {
        [self.rawId deleteCharactersInRange:NSMakeRange(self.rawId.length-1, 1)];
    } else if (regexMatches == 0 || (regexMatches > 0 && self.rawId.length < 11)) {
        [self.rawId appendString:string];
    }

    // Aplica máscara se for número de telefone
    if (regexMatches > 0) {
        textField.text = (NSString *)[NSStringMask maskString:self.rawId withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    } else {
        textField.text = self.rawId;
    }

    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self signInButtonTouched:[[UIButton alloc] init]];
    return YES;
}

// MARK: - Layout

- (void)configureLayout {

    LayoutManager *layout = [LayoutManager sharedManager];

    // Configura view
    self.view.backgroundColor = layout.backgroundColor;

    // Configura navigation bar
    self.navigationController.navigationBar.translucent = NO;

    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;

    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.phoneOrEmaiLTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.phoneOrEmaiLTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.phoneOrEmaiLTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.phoneOrEmaiLTextField setBottomBorderWithColor: layout.lightGray];
    self.phoneOrEmaiLTextField.clearButtonMode = UITextFieldViewModeNever;
    self.phoneOrEmaiLTextField.delegate = self;

    self.phoneOrEmaiLTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.phoneOrEmaiLTextField.textColor = layout.darkFontColor;
    [self.phoneOrEmaiLTextField setPlaceholder:@"Telefone ou e-mail"];//.placeholder = @"Telefone ou e-mail";


    // Configura label de cadastro
    self.noLoginLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.noLoginLabel.textColor = layout.darkFontColor;

    self.labelDescription.font = [layout fontWithSize:layout.subTitleFontSize];
    self.labelDescription.textColor = layout.lightFontColor;

    // Configura botão de cadastro
    self.signUpButton.titleLabel.font = [layout fontWithSize:layout.regularFontSize];
    [self.signUpButton setTitleColor:layout.primaryColor forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:layout.gradientColor forState:UIControlStateSelected];


    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault]; //UIlib4allImageNamed:@"transparent.png"
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];



    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];

    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                 style:UIBarButtonItemStylePlain target:self
                                                                action:@selector(closeButtonTouched:)];

    if (self.navigationController.viewControllers.count == 1 && !self.hideCloseButton) {
        [self.navigationItem setLeftBarButtonItem:menuItem];
    }
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    _labelDescription.text = [_labelDescription.text stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:_labelDescription.text];
    
    NSRange range = [_labelDescription.text rangeOfString:@"informe o seu telefone ou e-mail"];

    [attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
    [_labelDescription setAttributedText:attrTitle];
    
    if (_signFlowController.enteredEmailAddress != nil && _signFlowController.socialSignInData) {
        _containerSocial.hidden = YES;
        [_phoneOrEmaiLTextField setText:_signFlowController.enteredEmailAddress];
        self.rawId = [_signFlowController.enteredEmailAddress mutableCopy];
    }

}


- (void) configureSocialComponent{

    if (socialComponent != nil) {
        [socialComponent.view removeFromSuperview];
        [socialComponent removeFromParentViewController];
    }
    
    socialComponent = [[SocialContainerViewController alloc] init];

    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    socialComponent.view.frame = self.containerSocial.bounds;
    
    [socialComponent setDelegate:self];
    
    //Adiciona view do component ao controller
    [self.containerSocial addSubview:socialComponent.view];
    
    socialComponent.isLogin = YES;
    
    //Adiciona a parte funcional ao container
    [self addChildViewController:socialComponent];
    [socialComponent didMoveToParentViewController:socialComponent];
    
}

//MARK: - Social delegate
-(void) continueFromSocialLogin:(NSString *)token socialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK{
    Services *service = [[Services alloc] init];
    
    
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
                self.signFlowController.isLogin = YES;
                [User sharedUser].currentState = UserStateLoggedIn;
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
            
            self.rawId = [[NSMutableString alloc] initWithString:@""];
            if (response[@"name"]) {
                [_signFlowController.accountData setValue:response[@"name"]
                                                   forKey:FullNameKey];
                _signFlowController.enteredFullName = response[@"name"];
            }
            
            //Verificar o que faz quando nao tem email
            if (response[@"email"]) {
                [_signFlowController.accountData setValue:response[@"email"]
                                                   forKey:EmailAddressKey];
                _signFlowController.enteredEmailAddress = response[@"email"];
                [_phoneOrEmaiLTextField setText:response[@"email"]];
                self.rawId = [[NSMutableString alloc] initWithString:response[@"email"]];
            }
            
            /*
                Verifica se há um usuário com esse e-mail da rede social
                Caso exista, o token da rede social é vinculado a esta conta no completeLogin
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading finishLoading:^{
                    [self signInButtonTouched:nil];
                }];
            });

        }
    };
    
    [loading startLoading:self title:@"Aguarde..." completion:^{
        [service thirdPartyLogin:token fromSocialMedia:socialMedia nativeSDK:nativeSDK];
    }];
}

//MARK: - Social Login Delegate
-(void)socialLoginDidFinishWithToken:(NSString *)token fromSocialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK{
    if (token != nil) {
        _signFlowController.isSocialLogin = YES;
        
        if (_signFlowController.socialSignInData == nil) {
            _signFlowController.socialSignInData = [[NSMutableDictionary alloc] init];
        }

        [self continueFromSocialLogin:token socialMedia:socialMedia nativeSDK:nativeSDK];

    }else{
        _signFlowController.isSocialLogin = NO;
    }
    

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
