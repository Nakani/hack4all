//
//  PasswordViewController.m
//  Example
//
//  Created by Cristiano Matte on 14/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "PasswordViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"
#import "ForgotPasswordViewController.h"
#import "BlockedPasswordViewController.h"
#import "Lib4all.h"
#import "UIView+Gradient.h"
#import "User.h"
#import "PopUpBoxViewController.h"
#import "MainActionButton.h"
#import "AnalyticsUtil.h"

@interface PasswordViewController () < UIGestureRecognizerDelegate >

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet MainActionButton *mainButton;

@end

@implementation PasswordViewController

static CGFloat const kBottomConstraintMin = 60.0;
static NSString* const kNavigationTitle = @"Entrar";

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AnalyticsUtil createScreenViewWithName:@"login_senha"];

    
    [self configureLayout];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user = [User sharedUser];
    
    if (user.hasPassword && user.isPasswordBlocked) {
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg){ };
        service.successCase = ^(NSDictionary *response){ };

        NSString *identifier = _signFlowController.enteredEmailAddress != nil ? _signFlowController.enteredEmailAddress : _signFlowController.enteredPhoneNumber;
        [service startPasswordRecoveryWithIdentifier:identifier];
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        NSString *msg = @"Enviaremos um e-mail para o endereço cadastrado <email> para que você possa recuperá-la.";
        msg = [msg stringByReplacingOccurrencesOfString:@"<email>" withString:user.maskedEmail];
        [alert show:self title:@"Senha Bloqueada" description:msg imageMode:Error buttonAction:^{
        
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self configureLayout];
    
    [_passwordTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_passwordTextField resignFirstResponder];
}


- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        if([[UIScreen mainScreen] bounds].size.height <= 568){
            //App is running on iPhone with screen 3.5 inch
            _heightHeader.constant = _heightHeader.constant - 95;
        }
        
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        if ([[UIScreen mainScreen] bounds].size.height <= 568) {
            //App is running on iPhone with screen 3.5 inch
            _heightHeader.constant = 222;
        }
        
        self.bottomConstraint.constant = kBottomConstraintMin;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
}
// MARK: - Actions

- (IBAction)continueButtonTouched {
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
            [User sharedUser].currentState = UserStateLoggedIn;
            if ([[Lib4all sharedInstance].userStateDelegate respondsToSelector:@selector(userDidLogin)]) {
                [[Lib4all sharedInstance].userStateDelegate userDidLogin];
            }
            
            [loading finishLoading:^{
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
    
    // O primeiro passo da finalização de login é verificar a senha
    service.successCase = ^(NSDictionary *data) {
        getAccountData();
    };
    
    service.failureCase = ^(NSString *code, NSString *msg) {
        [loading finishLoading:^{
            if ([code isEqualToString:@"4.33"]) {
                PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                [AnalyticsUtil createScreenViewWithName:@"senha_bloqueada"];
                [alert show:self title:@"Senha Bloqueada" description:msg imageMode:Error buttonAction:nil];
    
            } else {
                PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                
                [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
                [self.passwordTextField showFieldWithError:YES];
            }
        }];
    };
    
    [loading startLoading:self title:@"Aguarde..."];
    [service completeLoginWithPassword:_passwordTextField.text socialData:_signFlowController.socialSignInData];
}

- (IBAction)forgotPasswordButtonTouched:(id)sender {
    User *user = [User sharedUser];
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
        
    Services *service = [[Services alloc] init];
    PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        [loadingViewController finishLoading:^{
            [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
        }];
    };
    
    service.successCase = ^(NSDictionary *response){
        [loadingViewController finishLoading:^{
            NSString *msg = @"Enviamos um email para o endereço cadastrado (<email>) com um link para redefinir sua senha.";
            msg = [msg stringByReplacingOccurrencesOfString:@"<email>" withString:user.maskedEmail];
            [alert show:self title:@"Esqueceu sua senha?" description:msg imageMode:Success buttonAction:nil];
        }];
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    NSString *identifier = _signFlowController.enteredEmailAddress != nil ? _signFlowController.enteredEmailAddress : _signFlowController.enteredPhoneNumber;
    
    [AnalyticsUtil createEventWithCategory:@"account" action:@"forgot" label:@"forgot password" andValue:nil];
        
    [service startPasswordRecoveryWithIdentifier:identifier];
}


- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueForgotPassword"]) {
        ForgotPasswordViewController *viewController = segue.destinationViewController;
        viewController.signFlowController = _signFlowController;
    }
    if ([segue.identifier isEqualToString:@"segueBlockedPassword"]) {
        BlockedPasswordViewController *viewController = segue.destinationViewController;
        viewController.signFlowController = _signFlowController;
    }
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueButtonTouched];
    return YES;
}

// MARK: - Layout

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    // Configura view
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura navigation bar
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    self.titleLable.font = [layout fontWithSize:layout.subTitleFontSize];
    self.titleLable.textColor = layout.lightFontColor;
    self.titleLable.numberOfLines = 2;
    
    self.forgotPasswordButton.titleLabel.font = [layout fontWithSize:layout.regularFontSize];
    [self.forgotPasswordButton setTitleColor:layout.primaryColor forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:layout.gradientColor forState:UIControlStateSelected];
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.passwordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.passwordTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.passwordTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.passwordTextField setBottomBorderWithColor:layout.lightGray];
    self.passwordTextField.clearButtonMode = UITextFieldViewModeNever;
    
    self.passwordTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.passwordTextField.textColor = layout.darkFontColor;
    [self.passwordTextField setPlaceholder:@"Senha"];

    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
   
    _titleLable.text = [NSString stringWithFormat:@"Insira a sua senha %@", balanceTypeFriendlyName];
    
    NSRange range = [_titleLable.text rangeOfString:[NSString stringWithFormat:@"senha %@",balanceTypeFriendlyName]];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:_titleLable.text];
    [attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
    [_titleLable setAttributedText:attrTitle];

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
