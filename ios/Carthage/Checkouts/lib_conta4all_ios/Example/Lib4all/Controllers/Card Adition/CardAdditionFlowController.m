//
//  CardAdditionFlowController.m
//  Example
//
//  Created by Cristiano Matte on 01/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CardAdditionFlowController.h"
#import <CoreLocation/CoreLocation.h>
#import "BaseNavigationController.h"
#import "LocalizationFlowController.h"
#import "SystemLocalizationRequiredViewController.h"
#import "LocalizationPermissionViewController.h"
#import "LocalizationRequiredViewController.h"
#import "CardAdditionWelcomeViewController.h"
#import "DataFieldViewController.h"
#import "Lib4allPreferences.h"
#import "User.h"
#import "CPFDataField.h"
#import "BirthdateDataField.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "BirthdateDataField.h"
#import "DateUtil.h"
#import "CardTypeSelectorViewController.h"
#import "CardFieldViewController.h"
#import "CardNumberProtocol.h"
#import "CardNameProtocol.h"
#import "CardExpirationProtocol.h"
#import "CardSecurityCodeProtocol.h"
#import "ServicesConstants.h"
#import "CardFieldViewController.h"
#import "AnalyticsUtil.h"

@interface CardAdditionFlowController ()
@property LocalizationFlowController *localizationFlowController;
@property (nonatomic, weak) UIViewController *controllerPreviousCardIO;
@end

@implementation CardAdditionFlowController

@synthesize onLoginOrAccountCreation = _onLoginOrAccountCreation;

//este init utiliza o acceptedPaymentTypes e acceptedBrands configurado globalmente
- (instancetype)init {
    self = [super init];

    // Verifica se é necessário exigir dados do anti-fraude
    Lib4allPreferences *preferences = [Lib4allPreferences sharedInstance];
    NSString *cpf = [[User sharedUser] cpf];
    NSString *birthdate = [[User sharedUser] birthdate];

    BOOL requireCpfOrCnpj = [preferences.requiredAntiFraudItems[@"cpf"] isEqual: @YES] && (cpf == (id)[NSNull null] || cpf.length == 0);
    BOOL requireBirthdate = [preferences.requiredAntiFraudItems[@"birthdate"] isEqual: @YES] && (birthdate == (id)[NSNull null] || birthdate.length == 0);

    _requiredFields = [[NSMutableArray alloc] init];
    if (requireCpfOrCnpj) {
        [_requiredFields addObject:[[CPFDataField alloc] init]];
    }
    if (requireBirthdate) {
        [_requiredFields addObject:[[BirthdateDataField alloc] init]];
    }

    self.acceptedPaymentTypes = [preferences acceptedPaymentTypes];
    self.acceptedBrands = [[preferences acceptedBrands] allObjects];

    [CardIOUtilities preloadCardIO];

    return self;
}

//este init utiliza o acceptedPaymentTypes e acceptedBrands configurado localmente, recebido via parâmetro
- (instancetype)initWithAcceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands {
    self = [super init];

    // Verifica se é necessário exigir dados do anti-fraude
    Lib4allPreferences *preferences = [Lib4allPreferences sharedInstance];
    NSString *cpf = [[User sharedUser] cpf];
    NSString *birthdate = [[User sharedUser] birthdate];

    BOOL requireCpfOrCnpj = [preferences.requiredAntiFraudItems[@"cpf"] isEqual: @YES] && (cpf == (id)[NSNull null] || cpf.length == 0);
    BOOL requireBirthdate = [preferences.requiredAntiFraudItems[@"birthdate"] isEqual: @YES] && (birthdate == (id)[NSNull null] || birthdate.length == 0);

    _requiredFields = [[NSMutableArray alloc] init];
    if (requireCpfOrCnpj) {
        [_requiredFields addObject:[[CPFDataField alloc] init]];
    }
    if (requireBirthdate) {
        [_requiredFields addObject:[[BirthdateDataField alloc] init]];
    }

    self.acceptedPaymentTypes = paymentTypes;
    self.acceptedBrands = brands;

    return self;
}

- (void)startFlowWithViewController:(UIViewController *)viewController {
    BOOL requestLocalizationPermission = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) &&
                                         ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) &&
                                         ([[Lib4allPreferences sharedInstance].requiredAntiFraudItems[@"geolocation"] isEqual: @YES]);
    unsigned long cardsCount = [[CreditCardsList sharedList] creditCards].count;
    UIViewController *destination;

    if ([User sharedUser] .birthdate != nil) {
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:NO]) {
            return;
        }
    }
    
    // Exibe tela informativa se for primeiro cartão e for efetuar pagamento
    if (cardsCount == 0 && _loginWithPaymentCompletion != nil) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"CardAdditionWelcomeViewController"];
        ((CardAdditionWelcomeViewController *)destination).flowController = self;
        
    } else if (_requiredFields.count > 0) {

        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"DataFieldViewController"];
        ((DataFieldViewController *)destination).dataFieldProtocol = _requiredFields[0];
        ((DataFieldViewController *)destination).flowController = self;
        //[_requiredFields removeObjectAtIndex:0];
    } else if (requestLocalizationPermission) {
        // Se usuário é menor de idade, não passa para o fluxo de permissão de localização
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:NO]) {
            return;
        }

        _localizationFlowController = [[LocalizationFlowController alloc] init];
        _localizationFlowController.onLoginOrAccountCreation = _onLoginOrAccountCreation;
        _localizationFlowController.presentModally = YES;
        __weak CardAdditionFlowController *weakSelf = self;
        _localizationFlowController.completionBlock = ^(UIViewController *viewController) {
            [weakSelf viewControllerDidFinish:viewController];
        };
        _localizationFlowController.isFromAddCardMenu = _isFromAddCardMenu;
        [_localizationFlowController startFlowWithViewController:viewController];
        return;
    } else {
        // Se usuário é menor de idade, não passa para a tela de adição de cartão
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:NO]) {
            return;
        }
        destination = [[CardTypeSelectorViewController alloc] initWithNibName:@"CardTypeSelectorViewController"bundle: [NSBundle getLibBundle]];

        ((CardTypeSelectorViewController *)destination).flowController = self;
        [((CardTypeSelectorViewController *)destination) setAccceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];
    }

    if (_onLoginOrAccountCreation) {
        [viewController.navigationController pushViewController:destination animated:YES];
    } else {
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destination];
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)viewControllerDidFinish:(UIViewController *)viewController {
    BOOL requestLocalizationPermission = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) &&
                                         ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) &&
                                         ([[Lib4allPreferences sharedInstance].requiredAntiFraudItems[@"geolocation"] isEqual: @YES]);

    // Se está voltando da tela de data de nascimento, deve verificar se usuário possui mais de 18 anos
    if ([viewController isKindOfClass:[DataFieldViewController class]] &&
        [((DataFieldViewController*)viewController).dataFieldProtocol isKindOfClass:[BirthdateDataField class]]) {
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:YES]) {
            return;
        }
    }

    if (_requiredFields.count > 0) {
        DataFieldViewController *destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                                instantiateViewControllerWithIdentifier:@"DataFieldViewController"];
        destination.dataFieldProtocol = _requiredFields[0];
        destination.flowController = self;
        //[_requiredFields removeObjectAtIndex:0];

        [viewController.navigationController pushViewController:destination animated:YES];
    } else if (requestLocalizationPermission) {
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:YES]) {
            return;
        }

        _localizationFlowController = [[LocalizationFlowController alloc] init];
        _localizationFlowController.onLoginOrAccountCreation = _onLoginOrAccountCreation;
        __weak CardAdditionFlowController *weakSelf = self;
        _localizationFlowController.completionBlock = ^(UIViewController *viewController) {
            [weakSelf viewControllerDidFinish:viewController];
        };

        [_localizationFlowController startFlowWithViewController:viewController];
    } else if ([viewController isKindOfClass:[CardAdditionWelcomeViewController class]] ||
               [viewController isKindOfClass:[DataFieldViewController class]] ||
               [viewController isKindOfClass:[LocalizationPermissionViewController class]] ||
               [viewController isKindOfClass:[LocalizationRequiredViewController class]] ||
               [viewController isKindOfClass:[SystemLocalizationRequiredViewController class]]) {
        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:YES]) {
            return;
        }
        
        UIViewController *destination = [[CardTypeSelectorViewController alloc] initWithNibName:@"CardTypeSelectorViewController"bundle: [NSBundle getLibBundle]];
        
        ((CardTypeSelectorViewController *)destination).flowController = self;
        [((CardTypeSelectorViewController *)destination) setAccceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];

        [viewController.navigationController pushViewController:destination animated:YES];
 
    } else if ([viewController isKindOfClass:[CardTypeSelectorViewController class]]) {
        _controllerPreviousCardIO = viewController;

        if ([CardIOUtilities canReadCardWithCamera] && _isCardOCREnabled) {
            CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
            scanViewController.hideCardIOLogo = YES;
            scanViewController.scanInstructions = @"Posicione a parte da frente\ndo seu cartão";
            scanViewController.suppressScanConfirmation = YES;
            scanViewController.disableManualEntryButtons = YES;
            scanViewController.collectExpiry = NO;
            [viewController presentViewController:scanViewController animated:YES completion:nil];
        }else{
            UIViewController *destination = [[CardFieldViewController alloc] initWithNibName:@"CardFieldViewController" bundle: [NSBundle getLibBundle]];

            ((CardFieldViewController *)destination).flowController = self;
            ((CardFieldViewController *)destination).dataProtocol   = [[CardNumberProtocol alloc] init];

            [_controllerPreviousCardIO.navigationController pushViewController:destination animated:YES];
        }

    }else if ([viewController isKindOfClass:[CardIOPaymentViewController class]]) {

        UIViewController *destination = [[CardFieldViewController alloc] initWithNibName:@"CardFieldViewController"bundle: [NSBundle getLibBundle]];
        
        ((CardFieldViewController *)destination).flowController = self;
        ((CardFieldViewController *)destination).dataProtocol   = [[CardNumberProtocol alloc] init];

        [_controllerPreviousCardIO.navigationController pushViewController:destination animated:YES];
    } else {
        BOOL isDataField = [viewController isKindOfClass:[CardFieldViewController class]];
        CardFieldViewController *cardFieldVC = (CardFieldViewController *)viewController;
        if (isDataField && [cardFieldVC.dataProtocol isKindOfClass:[CardNumberProtocol class]]) {

            UIViewController *destination = [[CardFieldViewController alloc] initWithNibName:@"CardFieldViewController"bundle: [NSBundle getLibBundle]];
            
            ((CardFieldViewController *)destination).flowController = self;
            ((CardFieldViewController *)destination).dataProtocol   = [[CardNameProtocol alloc] init];

            [viewController.navigationController pushViewController:destination animated:YES];


        } else if (isDataField && [cardFieldVC.dataProtocol isKindOfClass:[CardNameProtocol class]]) {

            UIViewController *destination = [[CardFieldViewController alloc] initWithNibName:@"CardFieldViewController"bundle: [NSBundle getLibBundle]];
            
            ((CardFieldViewController *)destination).flowController = self;
            CardExpirationProtocol *cardExpirationProtocol = [[CardExpirationProtocol alloc] init];
  
            if (_selectedType == CardTypePatRefeicao || _selectedType == CardTypePatAlimentacao) {
                cardExpirationProtocol.optional = YES;
            }
            
            ((CardFieldViewController *)destination).dataProtocol = cardExpirationProtocol;

            [viewController.navigationController pushViewController:destination animated:YES];


        } else  if (isDataField && [cardFieldVC.dataProtocol isKindOfClass:[CardExpirationProtocol class]]) {

            UIViewController *destination = [[CardFieldViewController alloc] initWithNibName:@"CardFieldViewController"bundle: [NSBundle getLibBundle]];
            
            ((CardFieldViewController *)destination).flowController = self;
            ((CardFieldViewController *)destination).dataProtocol   = [[CardSecurityCodeProtocol alloc] init];

            [viewController.navigationController pushViewController:destination animated:YES];


        } else {
            [viewController.view endEditing:YES];
            [viewController dismissViewControllerAnimated:YES completion:^{
                if (_loginWithPaymentCompletion != nil) {
                    CreditCard *card = [[CreditCardsList sharedList] getDefaultCard];
                    NSString *sessionToken = [[User sharedUser] token];
                    NSString *cardId = [card cardId];
                    NSString *cvv = nil;
                    
                    if(card.askCvv)
                        cvv = cardFieldVC.dataProtocol.flowController.CVV;
                    _loginWithPaymentCompletion(sessionToken, cardId, cvv);
                    
                } else if (_loginCompletion != nil) {
                    NSString *sessionToken = [[User sharedUser] token];
                    NSString *phoneNumber = [[User sharedUser] phoneNumber];
                    NSString *email = [[User sharedUser] emailAddress];
                    
                    _loginCompletion(phoneNumber, email, sessionToken);
                }
            }];
        }
    }
}

-(void)goBackWithErrors:(NSArray *)errors from:(UIViewController *)viewController{
    UIViewController *destController = [self getController:errors from:viewController];

    if (destController != nil) {
        [viewController.navigationController popToViewController:destController animated:YES];
    }
}

- (UIViewController *)getController:(NSArray *)fields from:(UIViewController *)controller{

    NSString *field = (NSString *)fields[0];
    NSInteger stackCount = controller.navigationController.viewControllers.count;
    NSInteger indexToGoBack = stackCount-1;

    if ([field isEqualToString:CardNumberKey]) {
        indexToGoBack = stackCount - 4;
    }else if ([field isEqualToString:CardholderKey]) {
        indexToGoBack = stackCount - 3;

    }else if ([field isEqualToString:ExpirationDateKey]) {
        indexToGoBack = stackCount - 2;

    }else if ([field isEqualToString:SecurityCodeKey]) {
        indexToGoBack = stackCount - 1;
    }

    return controller.navigationController.viewControllers[indexToGoBack];
}

- (BOOL)validateBirthdateWithViewController:(UIViewController *)viewController closeViewControllerIfInvalid:(BOOL)close {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSDate *birthdate = [dateFormatter dateFromString:[User sharedUser].birthdate];
    
    
    if ([DateUtil isOverEighteen:birthdate]) {
        return YES;
    } else {
        [self showErrorAlertWithMessage:@"Para adicionar um cartão, é necessário ter 18 anos ou mais." inViewController:viewController closeViewControllerIfInvalid: close];
        return NO;
    }
}

- (void)showErrorAlertWithMessage:(NSString *)message inViewController:(UIViewController *)viewController closeViewControllerIfInvalid:(BOOL)close {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (close) {
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert addAction:ok];

    [viewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CardIO

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:^{
        [self viewControllerDidFinish:scanViewController];
    }];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
//    NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    // Use the card info...
    [scanViewController dismissViewControllerAnimated:YES completion:^{
        if (info.cardholderName != nil) {
            _enteredCardName = info.cardholderName;
            _cardName = info.cardholderName;
        }

        [AnalyticsUtil logEventWithName:@"leitura_cartao_ocr" andParameters:nil];
        
        _enteredCardNumber = info.cardNumber;
        _cardNumber = info.cardNumber;
        _cardNumberFromPhoto = info.cardNumber;
        _enteredCVV = info.cvv;
        _CVV = info.cvv;
        if (info.expiryMonth != 0 && info.expiryMonth != 0) {
            _enteredExpirationDate = [NSString stringWithFormat:@"%02d/%02d",(int)info.expiryMonth, (int)info.expiryYear];
            _expirationDate = _enteredExpirationDate;
        }

        [self viewControllerDidFinish:scanViewController];

    }];
}

@end
