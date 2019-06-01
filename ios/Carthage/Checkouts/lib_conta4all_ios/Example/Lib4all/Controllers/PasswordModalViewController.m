//
//  PasswordModalViewController.m
//  Example
//
//  Created by Luciano Bohrer on 16/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PasswordModalViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "LoadingViewController.h"
#import "ForgotPasswordViewController.h"
#import "BlockedPasswordViewController.h"
#import "UIView+Gradient.h"
#import "PopUpBoxViewController.h"
#import "Services.h"
#import "User.h"

@interface PasswordModalViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation PasswordModalViewController

static CGFloat const kBottomConstraintMin = 60.0;
static NSString* const kNavigationTitle = @"Transferir";

- (instancetype)init{
    self = [super init];
    if (self) {
        self.view = [[NSBundle getLibBundle] loadNibNamed:@"PasswordModalViewController" owner:self options:nil][0];
        [self configureLayout];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    [self configureLayout];
    
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

// MARK: - Actions

- (IBAction)continueButtonTouched {
    if (_passwordTextField.text.length > 3) {

        if ([[User sharedUser] hasPassword]) {
            if (_didEnterPassword != nil) {
                _didEnterPassword(_passwordTextField.text);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }else{
            if ([_passwordTextField.text isEqualToString:_repeatPasswordTextField.text]) {
                Services *services = [[Services alloc] init];
                
                services.successCase = ^(id data) {
                    _didEnterPassword(_passwordTextField.text);
                    [self dismissViewControllerAnimated:YES completion:nil];
                };
                
                services.failureCase = ^(NSString *errorID, NSString *errorMessage) {
                    PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                    
                    [alert show:self title:@"Atenção!" description:errorMessage imageMode:Error buttonAction:nil];
                };
                
                [services setNewPassword:_passwordTextField.text oldPassword:nil];
            }else{
                PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                
                [alert show:self title:@"Atenção!" description:@"As senhas inseridas são diferentes, por favor, tente novamente." imageMode:Error buttonAction:nil];
            }
        }
    }else{
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        [alert show:self title:@"Atenção!" description:@"Por favor, digite uma senha válida para continuar." imageMode:Error buttonAction:nil];
    }
}

- (IBAction)closeController {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            msg = [msg stringByReplacingOccurrencesOfString:@"<email>" withString:user.emailAddress];
            [alert show:self title:@"Esqueceu sua senha?" description:msg imageMode:Success buttonAction:nil];
        }];
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    
    [service startPasswordRecoveryWithIdentifier:[User sharedUser].emailAddress];
}

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
    
    self.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.titleLabel.textColor = layout.lightFontColor;
    
    
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
    
    [self.repeatPasswordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.repeatPasswordTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.repeatPasswordTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.repeatPasswordTextField setBottomBorderWithColor:layout.lightGray];
    self.repeatPasswordTextField.clearButtonMode = UITextFieldViewModeNever;
    
    self.repeatPasswordTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.repeatPasswordTextField.textColor = layout.darkFontColor;
    [self.repeatPasswordTextField setPlaceholder:@"Repita a senha"];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    
    if ([[User sharedUser] hasPassword]) {
        
        NSString* title = [NSString stringWithFormat:@"Insira a sua senha %@", balanceTypeFriendlyName];
        
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        NSRange range = [[NSString stringWithFormat:@"Insira a sua senha %@", balanceTypeFriendlyName] rangeOfString:[NSString stringWithFormat:@"senha %@", balanceTypeFriendlyName]];
        [attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
        
        [_titleLabel setAttributedText:attrTitle];
        
        _passwordTextField.hidden = NO;
        _repeatPasswordTextField.hidden = YES;
    }else{
        
        NSString* title = [NSString stringWithFormat:@"Você ainda não tem uma senha na conta %@.\nCadastre uma senha", balanceTypeFriendlyName];
        
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        NSRange range = [[NSString stringWithFormat:title, balanceTypeFriendlyName] rangeOfString:@"Cadastre uma senha"];
        [attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
        
        [_titleLabel setAttributedText:attrTitle];
        _passwordTextField.hidden = NO;
        _repeatPasswordTextField.hidden = NO;
    }
    _repeatPasswordTextField.delegate = self;
    _passwordTextField.delegate = self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if (textField == _passwordTextField && !_repeatPasswordTextField.hidden){
        [_repeatPasswordTextField becomeFirstResponder];
    }else{
        [self performSelectorOnMainThread:@selector(continueButtonTouched) withObject:nil waitUntilDone:NO];
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (_repeatPasswordTextField.focused) {
        [UIView animateWithDuration:0.4 animations:^{
            self.heightHeader.constant = 150;
            [self.view layoutIfNeeded];
        }];
    }
    
    if (![[User sharedUser] hasPassword]) {
        [UIView animateWithDuration:0.4 animations:^{
            if ([[UIScreen mainScreen] bounds].size.height < 568){
                NSLog(@"App is running on iPhone with screen 3.5 inch");
                _heightHeader.constant = 180;
            }
            
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
        
        }];
         
    }
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    if (_repeatPasswordTextField.focused) {
        [UIView animateWithDuration:0.4 animations:^{
            self.heightHeader.constant = 222;
            [self.view layoutIfNeeded];
        }];
    }
    
    if (![[User sharedUser] hasPassword]) {
        [UIView animateWithDuration:0.4 animations:^{
            if ([[UIScreen mainScreen] bounds].size.height < 568){
                NSLog(@"App is running on iPhone with screen 3.5 inch");
                _heightHeader.constant = 222;
            }
            
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
            
        }];
        
    }
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


@end
