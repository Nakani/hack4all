//
//  SignFlowController.m
//  Example
//
//  Created by Cristiano Matte on 22/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SignFlowController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocalizationFlowController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "PinViewController.h"
#import "PinConfirmationViewController.h"
#import "PasswordViewController.h"
#import "ChallengeViewController.h"
#import "SignWithSessionViewController.h"
#import "AccountCreatedViewController.h"
#import "CardAdditionFlowController.h"
#import "DataFieldViewController.h"
#import "ChoosePaymentTypeViewController.h"
#import "BlockedPasswordViewController.h"
#import "NameDataField.h"
#import "CPFDataField.h"
#import "BirthdateDataField.h"
#import "Lib4allPreferences.h"
#import "User.h"
#import "CreditCardsList.h"
#import "Lib4all.h"
#import "GenericDataViewController.h"
#import "SISUPhoneNumberDataField.h"
#import "SISUNameDataField.h"
#import "SISUTokenSmsDataField.h"
#import "SISUEmailDataField.h"
#import "SISUCPFDataField.h"
#import "SISUBirthdateDataField.h"
#import "SISUPasswordDataField.h"
#import "SISUPasswordConfirmationDataField.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "TermsViewController.h"
#import "WelcomeViewController.h"
#import "TermsViewController.h"
#import "DateUtil.h"

@interface SignFlowController()
@property (strong, nonatomic) LoadingViewController *loadingView;
@end

#import "FXKeychain.h"

@implementation SignFlowController


@synthesize onLoginOrAccountCreation = _onLoginOrAccountCreation;

//este init utiliza os tipos de pagamentos e bandeiras definidas em Preferences
- (instancetype)init {
    self = [super init];

    if (self) {
        _onLoginOrAccountCreation = YES;
    }
    
    self.socialSignInData = [[NSMutableDictionary alloc] init];
    self.acceptedPaymentTypes = [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
    self.acceptedBrands = [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects];
    self.loadingView = [[LoadingViewController alloc] init];

    return self;
}


//este init recebe configuração de tipos de pagamento e bandeiras!
- (instancetype)initWithAcceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands {
    self = [super init];

    if (self) {
        _onLoginOrAccountCreation = YES;
    }

    self.acceptedPaymentTypes = paymentTypes;
    self.acceptedBrands = brands;

    return self;
}

- (void)startFlowWithViewController:(UIViewController *)viewController {

}

- (void)viewControllerDidFinish:(UIViewController *)viewController {
    // O fluxo varia se for login ou cadastro
    if (_isLogin) {
        [self continueSignInFlowWihViewController:viewController];
    } else {
        [self continueSignUpFlowWihViewController:viewController];
    }
}

- (void)finishLoginFlow:(User *)user viewController:(UIViewController *)viewController {
    // Finaliza o fluxo de login
    [User sharedUser].currentState = UserStateLoggedIn;
    [viewController dismissViewControllerAnimated:YES completion:^{
        
        FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
        [keychain setObject:user.token forKey:@"sessionToken"];
        [keychain setObject:user.fullName forKey:@"fullName"];
        NSString *maskedEmail = user.emailAddress;
        maskedEmail = [maskedEmail stringByReplacingCharactersInRange:NSMakeRange(2, [maskedEmail rangeOfString:@"@"].location-2) withString:@"******"];
        [keychain setObject:maskedEmail forKey:@"emailAddress"];
        NSString *maskedPhone;
        maskedPhone = [user.phoneNumber substringFromIndex:2];
        maskedPhone = [maskedPhone stringByReplacingCharactersInRange:NSMakeRange(2, maskedPhone.length-4) withString:@"******"];
        [keychain setObject:maskedPhone forKey:@"phoneNumber"];
          
        if (_loginCompletion != nil) _loginCompletion(user.phoneNumber, user.emailAddress, user.token);
    }];
}

- (void)continueSignInFlowWihViewController:(UIViewController *)viewController {
    UIViewController *destination;
    User *user = [User sharedUser];

    BOOL requestLocalizationPermission = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) &&
    ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) &&
    ([[Lib4allPreferences sharedInstance].requiredAntiFraudItems[@"geolocation"] isEqual: @YES]);

    if ([viewController isKindOfClass:[GenericDataViewController class]]) {
        GenericDataViewController *vc = (GenericDataViewController *)viewController;
        BOOL isFromChallenge = [vc.dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]];
        if (isFromChallenge && _isSocialLogin == NO) {
            destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                           instantiateViewControllerWithIdentifier:@"PinViewController"];
            _enteredPhoneNumber = user.phoneNumber;
            _enteredEmailAddress = user.emailAddress;
            ((PinViewController *)destination).signFlowController = self;

        } else if([[User sharedUser] currentState] != UserStateLoggedIn) {
            //Redireciona para tela de login
            if (_isSocialLogin) {
                if (user.hasPassword) {
                    destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                   instantiateViewControllerWithIdentifier:@"PasswordViewController"];
                    ((PasswordViewController *)destination).signFlowController = self;
                    
                } else {
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUTokenSmsDataField alloc] init]];
                    
                    ((GenericDataViewController *)destination).signFlowController = self;
                }
            
            } else {
            
                UINavigationController *navDestionation = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                                           instantiateViewControllerWithIdentifier:@"LoginVC"];
                destination = [[navDestionation viewControllers] objectAtIndex:0];
                
                ((SignInViewController *)destination).signFlowController = self;
            }
        } else {
            [self finishLoginFlow:user viewController:viewController];
        }

        //Se for login com face não tem senha
    } else if ([viewController isKindOfClass:[SignInViewController class]] &&
               user.hasPassword) {
        
        // Redireciona para tela de inserção de senha
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"PasswordViewController"];
        ((PasswordViewController *)destination).signFlowController = self;
    } else if (([viewController isKindOfClass:[SignInViewController class]] &&
               [_socialSignInData valueForKey:ThirdPartyToken] != nil && _isSocialLogin) ||
               (([viewController isKindOfClass:[SignInViewController class]] && _isSocialLogin == NO))) {
        destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUTokenSmsDataField alloc] init]];

        ((GenericDataViewController *)destination).signFlowController = self;
    } else if ([viewController isKindOfClass:[ChoosePaymentTypeViewController class]]) {
        // Finaliza o fluxo de login com pagamento
        if (_loginWithPaymentCompletion != nil) {
            if(_askCvv) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pagamento"
                                                                                         message:@"Informe o código de segurança (CVV) localizado na parte de trás do seu cartão"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"CVV";
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                }];
                [alertController addAction:[UIAlertAction
                                            actionWithTitle:@"Pagar"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [viewController dismissViewControllerAnimated:YES completion:^{
                                                    FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
                                                    [keychain setObject:user.token forKey:@"sessionToken"];
                                                    [keychain setObject:user.fullName forKey:@"fullName"];
                                                    NSString *maskedEmail = user.emailAddress;
                                                    maskedEmail = [maskedEmail stringByReplacingCharactersInRange:NSMakeRange(2, [maskedEmail rangeOfString:@"@"].location-2) withString:@"******"];
                                                    [keychain setObject:maskedEmail forKey:@"emailAddress"];
                                                    NSString *maskedPhone;
                                                    maskedPhone = [user.phoneNumber substringFromIndex:2];
                                                    maskedPhone = [maskedPhone stringByReplacingCharactersInRange:NSMakeRange(2, maskedPhone.length-4) withString:@"******"];
                                                    [keychain setObject:maskedPhone forKey:@"phoneNumber"];
                                                    
                                                }];
                                                
                                                NSArray *textFields = alertController.textFields;
                                                UITextField *cvvField = textFields[0];
                                                _loginWithPaymentCompletion(user.token, _selectedCardId, cvvField.text);
                                            }]];
                [alertController addAction:[UIAlertAction
                                            actionWithTitle:@"Cancelar"
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [viewController dismissViewControllerAnimated:YES completion:^{
                                                    FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
                                                    [keychain setObject:user.token forKey:@"sessionToken"];
                                                    [keychain setObject:user.fullName forKey:@"fullName"];
                                                    NSString *maskedEmail = user.emailAddress;
                                                    maskedEmail = [maskedEmail stringByReplacingCharactersInRange:NSMakeRange(2, [maskedEmail rangeOfString:@"@"].location-2) withString:@"******"];
                                                    [keychain setObject:maskedEmail forKey:@"emailAddress"];
                                                    NSString *maskedPhone;
                                                    maskedPhone = [user.phoneNumber substringFromIndex:2];
                                                    maskedPhone = [maskedPhone stringByReplacingCharactersInRange:NSMakeRange(2, maskedPhone.length-4) withString:@"******"];
                                                    [keychain setObject:maskedPhone forKey:@"phoneNumber"];
                                                    
                                                }];
                                            
                                            }]];

                
                [viewController presentViewController:alertController animated:YES completion:nil];
            } else {
                _loginWithPaymentCompletion(user.token, _selectedCardId, nil);
            }
        }
        
    } else {
        BOOL requireFullName = (user.fullName == nil || [user.fullName isEqualToString:@""]);
        BOOL requireCpf = (user.cpf == nil || [user.cpf isEqualToString:@""]);
        BOOL requireBirthdate = (user.birthdate == nil || [user.birthdate isEqualToString:@""]);
        
        if (requireFullName || requireCpf || requireBirthdate) {
            destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                           instantiateViewControllerWithIdentifier:@"DataFieldViewController"];
            
            if (requireFullName) {
                // Redireciona para tela de inserção de nome
                ((DataFieldViewController *)destination).dataFieldProtocol = [[NameDataField alloc] init];
            } else if (requireCpf) {
                // Redireciona para tela de inserção de cpf
                ((DataFieldViewController *)destination).dataFieldProtocol = [[CPFDataField alloc] init];
                ((DataFieldViewController *)destination).dataIsRequired = YES;
            } else if (requireBirthdate) {
                // Redireciona para tela de inserção de data de nascimento
                ((DataFieldViewController *)destination).dataFieldProtocol = [[BirthdateDataField alloc] init];
            }
            
            ((DataFieldViewController *)destination).flowController = self;
        } else if (_requirePaymentData && [[CreditCardsList sharedList] getDefaultCard] == nil) {
            // Usuário não tem cartão ainda
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            dateFormatter.dateFormat = @"yyyy/MM/dd";
            NSDate *birthdate = [dateFormatter dateFromString:[User sharedUser].birthdate];
            
            if(![DateUtil isOverEighteen:birthdate]) {
                //Usuário é menor de idade, então deve seguir com o processo para ele pagar com a conta pré paga
                
                destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                               instantiateViewControllerWithIdentifier:@"ChoosePaymentTypeViewController"];
                ((ChoosePaymentTypeViewController *)destination).signFlowController = self;
            } else {
                //Inicia fluxo de adição de cartão
                
                CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];
                flowController.loginWithPaymentCompletion = _loginWithPaymentCompletion;
                flowController.loginCompletion = _loginCompletion;
                flowController.onLoginOrAccountCreation = YES;
                flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
                [flowController startFlowWithViewController:viewController];
                return;
            }
        } else if (_requirePaymentData && requestLocalizationPermission) {
            LocalizationFlowController *localizationFlowController = [[LocalizationFlowController alloc] init];
            localizationFlowController.onLoginOrAccountCreation = _onLoginOrAccountCreation;
            localizationFlowController.completionBlock = ^(UIViewController *viewController) {
                [self viewControllerDidFinish:viewController];
            };
            [localizationFlowController startFlowWithViewController:viewController];
            return;
            
        } else if (_requirePaymentData) {
            // Redireciona para tela de escolha de forma pagamento
            destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                           instantiateViewControllerWithIdentifier:@"ChoosePaymentTypeViewController"];
            ((ChoosePaymentTypeViewController *)destination).signFlowController = self;
        } else {
            [self finishLoginFlow:user viewController:viewController];
        }
    }
    
    if (destination != nil) {
        [viewController.navigationController pushViewController:destination animated:YES];
    }
}

- (void)continueSignUpFlowWihViewController:(UIViewController *)viewController {
    __block UIViewController *destination;
    
    if ([viewController isKindOfClass:[SignInViewController class]]) {
        // Após a tela de cadastro, apresenta a tela de senha
        destination  = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUNameDataField alloc] init]];
        ((GenericDataViewController *)destination).signFlowController = self;
        
        
    } else {
        
        if ([viewController isKindOfClass:[GenericDataViewController class]]) {
            GenericDataViewController *dataController = (GenericDataViewController *) viewController;
            
            if ([dataController.dataFieldProtocol isKindOfClass:[SISUNameDataField class]]) {
                // Após a tela de inserção de nome, solicita o telefone
                destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUPhoneNumberDataField alloc] init]];
                
                ((GenericDataViewController *)destination).signFlowController = self;
                
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUPhoneNumberDataField class]]) {
                
                // Após a tela de inserção do telefone, solicita o SMS Token caso telefone não tenha sido validado
                if (_isPhoneValidated == NO) {
                    
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUTokenSmsDataField alloc] init]];
                    
                }else{
                    // Caso celular já validado, pula para inserção de e-mail
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUEmailDataField alloc] init]];
                }
                
                ((GenericDataViewController *)destination).signFlowController = self;
                
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUTokenSmsDataField class]]) {
                
                // Após a tela de inserção do SMS Token, solicita o E-mail
                destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUEmailDataField alloc] init]];

                ((GenericDataViewController *)destination).signFlowController = self;
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUEmailDataField class]]) {

                // Após a tela de inserção de E-mail, solicita o CPF se obrigatório
                if ([[Lib4allPreferences sharedInstance] requireCpfOrCnpj]) {
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUCPFDataField alloc] init]];
                }else{
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUBirthdateDataField alloc] init]];
                }


                ((GenericDataViewController *)destination).signFlowController = self;
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUCPFDataField class]]) {

                // Após a tela de inserção de CPF, solicita a data de nascimento
                destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUBirthdateDataField alloc] init]];

                ((GenericDataViewController *)destination).signFlowController = self;
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUBirthdateDataField class]]) {

                /*
                    Após a tela de inserção da data de nascimento, solicita a senha caso não seja login com rede social
                    Se for login/cadastro com social login, pula step de senha;
                 */

                if (_socialSignInData[ThirdPartyToken] == nil) {
                    //Parametros necessarios para protocolo de password
                    SISUPasswordDataField *protocol = [[SISUPasswordDataField alloc] init];
                    protocol.emailAddress = [_accountData valueForKey:EmailAddressKey];
                    protocol.phoneNumber  = [_accountData valueForKey:PhoneNumberKey];
                    protocol.cpf          = [_accountData valueForKey:CPFKey];
                    
                    destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:protocol];
                }else{
                    TermsViewController *termsViewController = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:[NSBundle getLibBundle]];
                    termsViewController.signFlowController = self;
                    destination = termsViewController;
                }
                
                ((GenericDataViewController *)destination).signFlowController = self;
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUPasswordDataField class]]) {

                // Após a tela de inserção da senha, solicita a confirmação da mesma
                destination = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUPasswordConfirmationDataField alloc] init]];

                ((GenericDataViewController *)destination).signFlowController = self;
            }else if ([dataController.dataFieldProtocol isKindOfClass:[SISUPasswordConfirmationDataField class]]) {
                
                TermsViewController *termsViewController = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:[NSBundle getLibBundle]];
                termsViewController.signFlowController = self;
                destination = termsViewController;
            }
        }else if([viewController isKindOfClass:[TermsViewController class]]){
            //Se veio da tela de termos é pq foi cancelado o processo
            [viewController dismissViewControllerAnimated:YES completion:nil];

        }else if ([viewController isKindOfClass:[WelcomeViewController class]]){

            if (_requirePaymentData && _skipPayment == NO) {
                // Após a tela de welcome, se exige dados de pagamento, inicia fluxo de adição de cartão
                CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];
                flowController.loginWithPaymentCompletion = _loginWithPaymentCompletion;
                flowController.loginCompletion = _loginCompletion;
                flowController.onLoginOrAccountCreation = YES;
                flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
                [flowController startFlowWithViewController:viewController];
            }else{
                [self finishSignUpWithViewController:viewController];
            }

        }
    }

    if (destination != nil) {
        destination.title = @"Cadastro";
        [viewController.navigationController pushViewController:destination animated:YES];
    }
}

-(void)finishSignUpWithViewController:(UIViewController *)viewController {
    // Finaliza o fluxo de login
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (_loginCompletion != nil) {
            User *user = [User sharedUser];
            
            FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
            [keychain setObject:user.token forKey:@"sessionToken"];
            [keychain setObject:user.fullName forKey:@"fullName"];
            NSString *maskedEmail = user.emailAddress;
            maskedEmail = [maskedEmail stringByReplacingCharactersInRange:NSMakeRange(2, [maskedEmail rangeOfString:@"@"].location-2) withString:@"******"];
            [keychain setObject:maskedEmail forKey:@"emailAddress"];
            NSString *maskedPhone;
            maskedPhone = [user.phoneNumber substringFromIndex:2];
            maskedPhone = [maskedPhone stringByReplacingCharactersInRange:NSMakeRange(2, maskedPhone.length-4) withString:@"******"];
            [keychain setObject:maskedPhone forKey:@"phoneNumber"];
            
            
            _loginCompletion(user.phoneNumber, user.emailAddress, user.token);
        }
    }];
}

- (void)viewControllerWillClose:(UIViewController *)viewController {
    // Caso o usuário feche uma tela de inserção de dados após o login, o login deve ser desfeito
    if (_isLogin &&
        ([viewController isKindOfClass:[DataFieldViewController class]] ||
         [viewController isKindOfClass:[PinViewController class]])) {
            [[Lib4all sharedInstance] callLogoutWithoutAction:nil];
        }
}


@end
