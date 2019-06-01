//
//  PPTransferConfirmationViewController.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 16/04/18.
//  Copyright © 2018 4all. All rights reserved.
//

#import "PPTransferConfirmationViewController.h"
#import "LayoutManager.h"
#import "PrePaidServices.h"
#import "ComponentViewController.h"
#import "User.h"
#import "Services.h"
#import "ForgotPasswordViewController.h"
#import "PasswordModalViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "NSStringMask.h"
#import "NSString+Mask.h"
#import "PPTransferSuccessViewController.h"
#import "Lib4allPreferences.h"
#import "AnalyticsUtil.h"

@interface PPTransferConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTwoLettersName;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelCpf;
@property (weak, nonatomic) IBOutlet UILabel *labelYouAreSendingMoneyTo;
@property (weak, nonatomic) IBOutlet UILabel *labelTransfer;
@property (weak, nonatomic) IBOutlet UILabel *labelTransferValue;
@property (weak, nonatomic) IBOutlet UILabel *labelFee;
@property (weak, nonatomic) IBOutlet UILabel *labelFeeValue;
@property (weak, nonatomic) IBOutlet UIView *totalView;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalValue;
@property (weak, nonatomic) IBOutlet UILabel *labelHowPay;
@property (weak, nonatomic) IBOutlet UIView *componentContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTwoLettersNameSizeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelPhoneNumberTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTwoLettersNameTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelPhoneNumberLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelCpfLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIView *detailedValuesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailedValuesViewHeightConstraint;


@property ComponentViewController *component;
@property (strong, nonatomic) NSString *transferId;
@property double currentFee;
@property double totalValue;
@property double higherPossibleValue;

@property NSString *selectedCardId;
@property BOOL isPaymentWithCheckingAccount;
@end

@implementation PPTransferConfirmationViewController

static NSString* const kNavigationTitle = @"Transferir";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureLayout];
    [self configurePaymentComponent];
    [self loadFee];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.title = kNavigationTitle;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (void) configureLayout {
    if (!_userHasAccount) {
        [_labelName setHidden:YES];
        [self configureConstraintsWhenUserDoesNotHaveAccount];
    } else {
        [_labelCpf setHidden:YES];
    }
    
    _labelCpf.text = [NSString stringWithFormat:@"CPF: %@", _cpf];
    _labelName.text = _name;
    _labelPhoneNumber.text = [self getFormattedPhoneNumber];
    _labelFeeValue.text = @"";
    _labelTotalValue.text = @"";
    _labelTransferValue.text = @"";
    
    NSArray<NSString *> *firstLetters = [_name componentsSeparatedByString:@" "];
    
    if (firstLetters.count >= 2) {
        _labelTwoLettersName.text = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0],[firstLetters[firstLetters.count-1] characterAtIndex:0]];
    }else{
        if (firstLetters[0].length > 1) {
            _labelTwoLettersName.text = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0],[firstLetters[0] characterAtIndex:1]];
        }else{
            _labelTwoLettersName.text = [NSString stringWithFormat:@"%c",[firstLetters[0] characterAtIndex:0]];
        }
        
    }
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    _labelTwoLettersName.clipsToBounds = YES;
    _labelTwoLettersName.layer.cornerRadius = _labelTwoLettersName.frame.size.height/2;
    _labelTwoLettersName.layer.borderColor  = [layout primaryColor].CGColor;
    _labelTwoLettersName.layer.borderWidth  = 1.0f;
    _labelTwoLettersName.textColor          = layout.primaryColor;
    _labelTwoLettersName.font               = [layout fontWithSize:layout.subTitleFontSize];

    _labelYouAreSendingMoneyTo.font = [layout fontWithSize:layout.regularFontSize];
    _labelYouAreSendingMoneyTo.textColor = layout.darkGray;
    
    _labelName.font = [layout boldFontWithSize:layout.subTitleFontSize];
    _labelName.textColor = layout.darkGray;
    
    if(_userHasAccount) {
        _labelPhoneNumber.font = [layout fontWithSize:layout.regularFontSize];
    } else {
        _labelPhoneNumber.font = [layout boldFontWithSize:layout.subTitleFontSize];
    }
    _labelPhoneNumber.textColor = layout.darkGray;
    
    _labelCpf.font = [layout fontWithSize:layout.regularFontSize];
    _labelCpf.textColor = layout.darkGray;
    
    _labelTransfer.font = [layout fontWithSize:layout.subTitleFontSize];
    _labelTransfer.textColor = layout.darkGray;
    
    _labelTransferValue.font = [layout fontWithSize:layout.subTitleFontSize];
    _labelTransferValue.textColor = layout.darkGray;
    
    _labelFee.font = [layout fontWithSize:layout.subTitleFontSize];
    _labelFee.textColor = layout.darkGray;
    
    _labelFeeValue.font = [layout fontWithSize:layout.subTitleFontSize];
    _labelFeeValue.textColor = layout.darkGray;
    
    _labelTotal.font = [layout boldFontWithSize:layout.subTitleFontSize];
    _labelTotal.textColor = layout.darkGray;
    
    _labelTotalValue.font = [layout boldFontWithSize:layout.subTitleFontSize];
    _labelTotalValue.textColor = layout.darkGray;
    
    _labelHowPay.hidden = ![Lib4allPreferences sharedInstance].isEnabledTransferWithCreditCard;
    _labelHowPay.font = [layout fontWithSize:layout.subTitleFontSize];
    _labelHowPay.textColor = layout.darkGray;
}

-(void) configureConstraintsWhenUserDoesNotHaveAccount {
    _labelTwoLettersNameSizeConstraint.constant = 0;
    _labelPhoneNumberLeadingSpaceConstraint.constant = 0;
    _labelCpfLeadingSpaceConstraint.constant = 0;
    _labelPhoneNumberTopSpaceConstraint.active = NO;
    _labelTwoLettersNameTopSpaceConstraint.active = NO;
    NSLayoutConstraint *labelPhoneNumberBottomSpaceToLabelCpf = [NSLayoutConstraint constraintWithItem:_labelPhoneNumber attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_labelCpf attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *labelPhoneNumberTopSpaceToLabelYouAre = [NSLayoutConstraint constraintWithItem:_labelPhoneNumber attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_labelYouAreSendingMoneyTo attribute:NSLayoutAttributeBottom multiplier:1 constant:13];
    [self.view addConstraints:@[labelPhoneNumberBottomSpaceToLabelCpf,labelPhoneNumberTopSpaceToLabelYouAre]];
}

- (void) configurePaymentComponent{
    
    if (_component != nil) {
        [_component.view removeFromSuperview];
        [_component removeFromParentViewController];
    }
    
    _component = [[ComponentViewController alloc] init];
    
    _component.delegate = self;
    
    _component.buttonTitleWhenNotLogged = @"Transferir";
    _component.buttonTitleWhenLogged = @"Transferir";
    
    _component.disabledCreditCardPayment = ![Lib4allPreferences sharedInstance].isEnabledTransferWithCreditCard;
    
    _component.view.frame = _componentContainerView.bounds;
    [_componentContainerView addSubview:_component.view];
    [self addChildViewController:_component];
    [_component didMoveToParentViewController:_component];
    
    [self changeViewForCurrentPaymentOption];
}

-(NSString *)getFormattedPhoneNumber{
    //Format phone number
    
    NSString *phoneNumber = [NSStringMask maskString:[_phoneNumber substringFromIndex:2] withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    if (phoneNumber != nil) {
        
        phoneNumber = [@"+55" stringByAppendingString:phoneNumber];
        return phoneNumber;
    }else{
        return _phoneNumber;
    }
}

- (void) loadFee {
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.successCase = ^(id data) {
        NSDictionary *response = data;
        BOOL success = [[response valueForKey:@"success"] boolValue];
        if (success) {
            NSArray *fees = [response valueForKey:@"cardCashInFees"];
            NSDictionary *higherFee = fees[[fees count]-1];
            _higherPossibleValue = [[higherFee valueForKey:@"max"] intValue]/100.0;
            for(NSDictionary *fee in fees) {
                double minValue = [[fee valueForKey:@"min"] intValue]/100.0;
                double maxValue = [[fee valueForKey:@"max"] intValue]/100.0;
                if(_amount >= minValue && _amount <= maxValue) {
                    _currentFee = [[fee valueForKey:@"fee"] intValue]/100.0;
                    [self changeViewForCurrentPaymentOption];
                    return;
                }
            }
            //Só vai cair aqui se o valor selecionado for maior que os valores limites enviados pelo backend
            _currentFee = [[higherFee valueForKey:@"fee"] intValue]/100.0;
        }
        [self changeViewForCurrentPaymentOption];
    };
    
    services.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        [alert show:self title:@"Atenção" description:errorMessage imageMode:Error buttonAction:nil];
    };
    
    [services balance];
}

- (void) updateValues {
    
    float newHeight = 0;
    
    if (_isPaymentWithCheckingAccount) {
        _labelTotal.text = @"Transferência";
        _labelTotalValue.text = [[NSString stringWithFormat:@"R$ %0.2f", _amount] stringByReplacingOccurrencesOfString:@"." withString:@","];
    } else {
        _labelTotal.text = @"Total";
        _labelTransferValue.text = [[NSString stringWithFormat:@"R$ %0.2f", _amount] stringByReplacingOccurrencesOfString:@"." withString:@","];
        _labelFeeValue.text = [[NSString stringWithFormat:@"R$ %0.2f", _currentFee] stringByReplacingOccurrencesOfString:@"." withString:@","];
        _totalValue = _currentFee + _amount;
        _labelTotalValue.text = [[NSString stringWithFormat:@"R$ %0.2f", _totalValue] stringByReplacingOccurrencesOfString:@"." withString:@","];
        newHeight = 86;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _detailedValuesViewHeightConstraint.constant = newHeight;
    }];
}

- (void) changeViewForCurrentPaymentOption {
    _isPaymentWithCheckingAccount = ([User sharedUser].preferredPaymentMethod == 1);
    _detailedValuesView.hidden = _isPaymentWithCheckingAccount;
    [self updateValues];
}

//MARK: Callback Delegate

-(void)callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode cvv:(NSString *)cvv {
    
    _isPaymentWithCheckingAccount = (paymentMode == PaymentModeChecking);
    _selectedCardId = cardId;
    
    if (_isPaymentWithCheckingAccount) {
        [AnalyticsUtil logEventWithName:@"transferir_com_saldo" andParameters:nil];
    } else {
        [AnalyticsUtil logEventWithName:@"transferir_com_carteira" andParameters:nil];
        
        if (_amount > _higherPossibleValue) {
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            NSString *currencyValue = [[NSString stringWithFormat:@"R$ %0.2f", _higherPossibleValue] stringByReplacingOccurrencesOfString:@"." withString:@","];
            NSString *message = [NSString stringWithFormat:@"O valor máximo de transferência no cartão de crédito é de %@. Para envio de valores maiores, utilize seu saldo %@!", currencyValue, [Lib4allPreferences sharedInstance].balanceTypeFriendlyName];
            [modal show:self
                  title:@"Atenção"
            description:message
              imageMode:Error
           buttonAction:nil];
            return;
        }
    }
    
    if(![[User sharedUser] shouldAskForTouchId] && ![[User sharedUser] isTouchIdEnabled]) {
        [self callTransferFromTouchID:NO];
    } else {
        [self callTouchId];
    }
}

- (void) didLoadPaymentType {
    [self changeViewForCurrentPaymentOption];
}


- (void)callTouchId {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Use a digital para transferências.";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    //Get touch id succeded
                                    if([[User sharedUser] shouldAskForTouchId] && ![[User sharedUser] isTouchIdEnabled]) {
                                        //Se nunca perguntou pro usuario sobre o touch id e o touchId está desativado
                                        [self passwordToConfirmTouchId];
                                        [[User sharedUser] setShouldAskForTouchId:NO];
                                    }
                                    [self callTransferFromTouchID:YES];
                                } else {
                                    //Get touch id failed or user cancelled
                                    if([@"Fallback authentication mechanism selected." isEqualToString:error.localizedDescription]) {
                                        //User choose to use password instead touchId
                                        [[User sharedUser] setShouldAskForTouchId:NO];
                                        [self callTransferFromTouchID:NO];
                                    } else {
                                        if ([@"Biometry is disabled for unlock." isEqualToString:error.localizedDescription]) {
                                            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Touch id bloqueado"
                                                                                                                      message: @"Vá a configurações para desbloquear"
                                                                                                               preferredStyle:UIAlertControllerStyleAlert];
                                            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                                        } else {
                                            //User calcelled
                                            if([[User sharedUser] shouldAskForTouchId]){
                                                //Se o usuario cancelou a pergunta do touchId, mantém o touchId desabilitado
                                                [[User sharedUser] setShouldAskForTouchId:NO];
                                            }
                                            [self callTransferFromTouchID:NO];
                                        }
                                    }
                                }
                            
                            }];
    } else {
        //Touch id is disabled in device
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callTransferFromTouchID:NO];
        });
    }
}

- (void) passwordToConfirmTouchId {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Insira a sua senha para ativar o Touch ID"
                                                                              message: @""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Senha";
        textField.secureTextEntry = YES;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField *passwordTxtField = textfields[0];
        
        Services *service = [[Services alloc] init];
        service.successCase = ^(NSDictionary *response) {
            if([response[@"isPasswordCorrect"] boolValue]){
                [[User sharedUser] setIsTouchIdEnabled:YES];
                [self callTransferFromTouchID:YES];
            } else {
                [self passwordIsIncorrect:alertController];
            }
        };
        service.failureCase = ^(NSString *cod, NSString *msg) {
            [self passwordIsIncorrect:alertController];
        };
        [service checkPassword:passwordTxtField.text];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Esqueci minha senha" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ForgotPasswordViewController *forgotPasswordViewController = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
        [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //User cancelled
        [[User sharedUser] setShouldAskForTouchId:NO];
        [[User sharedUser] setIsTouchIdEnabled:NO];
    }]];
    
    [self presentViewController:alertController animated:YES completion: nil];
}

- (void) passwordIsIncorrect:(UIAlertController *)alertController {
    
    alertController.message = @"Senha inválida!";
    
    
    UITextField *textField = alertController.textFields[0];
    textField.text = @"";
    UIView *container = textField.superview;
    UIView *effectView = container.superview.subviews[0];
    
    if (effectView && [effectView class] == [UIVisualEffectView class]){
        container.layer.borderWidth = 0.7;
        container.layer.borderColor = [[UIColor redColor]CGColor];
        [effectView removeFromSuperview];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)callTransferFromTouchID:(BOOL)isFromTouchID {
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    Services *client = [[Services alloc] init];
    
    client.successCase = ^(id data) {
        [loading finishLoading:^{
            if(isFromTouchID) {
                if (_isPaymentWithCheckingAccount) {
                    [self callTransferP2PWithCheckingAccount:nil];
                } else {
                    [self callTransferP2PWithCreditCard:nil];
                }
            } else {
                [self showPassword];
            }
        }];
    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [loading finishLoading:^{
            if(isFromTouchID) {
                if (_isPaymentWithCheckingAccount) {
                    [self callTransferP2PWithCheckingAccount:nil];
                } else {
                    [self callTransferP2PWithCreditCard:nil];
                }
            } else {
                [self showPassword];
            }
        }];
    };
    
    [loading startLoading:self title:@"Aguarde..."];
    [client checkStatus];
}


-(void)showPassword {
    PasswordModalViewController *requestPassword = [[PasswordModalViewController alloc] init];
    [self presentViewController:requestPassword animated:YES completion:nil];
    __weak PasswordModalViewController *weakRequestPassword = requestPassword;
    requestPassword.didEnterPassword = ^(NSString *password) {
        [weakRequestPassword dismissViewControllerAnimated:NO completion:^{
            if (_isPaymentWithCheckingAccount) {
                [self callTransferP2PWithCheckingAccount:password];
            } else {
                [self callTransferP2PWithCreditCard:password];
            }
        }];
    };
}

-(void)callTransferP2PWithCheckingAccount:(NSString * _Nullable)password {
    PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    PrePaidServices *client = [[PrePaidServices alloc] init];
    
    client.successCase = ^(id data) {
        _transferId = [data stringValue];
        [loading finishLoading:^{
            [self performSegueWithIdentifier:@"segueSuccess" sender:self];
        }];
        
    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [loading finishLoading:^{
            [alert show:self title:@"Atenção!" description:errorMessage imageMode:Error buttonAction:nil];
        }];
    };
    
    NSNumber *amountNumber = [[NSNumber alloc] initWithInt:_amount*100];
    [loading startLoading:self title:@"Aguarde..."];
    [client p2pTransferToId:_phoneNumber amout:amountNumber description:_descriptionMessage password:password destinationCpf:_cpf];
}

-(void)callTransferP2PWithCreditCard:(NSString * _Nullable)password {
    PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    PrePaidServices *client = [[PrePaidServices alloc] init];
    
    client.successCase = ^(id data) {
        NSDictionary *response = data;
        _transferId = [[response valueForKey:@"transferId"] stringValue];
        [loading finishLoading:^{
            [self performSegueWithIdentifier:@"segueSuccess" sender:self];
        }];
        
    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [loading finishLoading:^{
            [alert show:self title:@"Atenção!" description:errorMessage imageMode:Error buttonAction:nil];
        }];
    };
    
    double amountNumber = _amount*100.0;
    
    [loading startLoading:self title:@"Aguarde..."];
    [client createPaymentCashIn:amountNumber payMode:TransactionPayModeCredit receiverCpf:_cpf receiverPhoneNumber:_phoneNumber description:_descriptionMessage cardId:_selectedCardId password:password];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueSuccess"]) {
        PPTransferSuccessViewController *destination = (PPTransferSuccessViewController *)segue.destinationViewController;
        if(_name != nil && ![_name  isEqual: @""]) {
            destination.name = _name;
        } else {
            destination.name = [self getFormattedPhoneNumber];
        }
        destination.amountValue = [[NSString stringWithFormat:@"R$ %0.2f", _amount] stringByReplacingOccurrencesOfString:@"." withString:@","];
        destination.transferId = _transferId;
    }
}

@end
