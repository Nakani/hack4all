//
//  CardSecurityCodeProtocol.m
//  Example
//
//  Created by 4all on 26/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardSecurityCodeProtocol.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"
#import "CreditCardsList.h"
#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AnalyticsUtil.h"

@interface CardSecurityCodeProtocol ()

@property LoadingViewController *loadingView;
@property (weak) UIViewController *parentVC;
@property NSString* cardID;

@end

@implementation CardSecurityCodeProtocol

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize attrTitle = _attrTitle;
@synthesize textFieldPlaceHolder = _textFieldPlaceHolder;
@synthesize textFieldImageName = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey = _serverKey;
@synthesize keyboardType = _keyboardType;
@synthesize preSettedField = _preSettedField;
@synthesize onUpdateField = _onUpdateField;
@synthesize flowController = _flowController;
@synthesize optional = _optional;

- (instancetype)init {
    self = [super init];
    if (self) {
        _title = @"Ótimo, agora falta pouco, só precisamos das informações do seu cartão";
        _textFieldPlaceHolder = @"Código de segurança";
        _keyboardType = UIKeyboardTypeNumberPad;
        _optional = false;
        _loadingView = [[LoadingViewController alloc] init];
    }
    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    NSString *regex = @"^[0-9]{3,6}$";

    return [self checkIfContentIsValid:data regex:regex];
}

- (NSString *)serverFormattedData:(NSString *)data {
    return data;
}

// MARK: - Services calls

- (void)callRequestVaultKey: (void (^)(NSString *))completion  {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        [_loadingView finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:_parentVC
                  title:@"Atenção!"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    service.successCase = ^(NSDictionary *response){
        [self callPrepareCard: completion];
    };
    
    if (!_loadingView.isLoading) {
        [_loadingView startLoading:_parentVC title:@"Aguarde..."];
    }
    
    [service requestVaultKey];
}

- (void)callPrepareCard: (void (^)(NSString *))completion {
    Services *service = [[Services alloc] init];
    
    NSString *cardnumber = _flowController.cardNumber;
    NSString *cardNumberFromPhoto = _flowController.cardNumberFromPhoto;
    NSMutableDictionary *card;
    
    if(_flowController.expirationDate) {
        NSString *expDate = _flowController.expirationDate;
        card = @{CardTypeKey: [[NSNumber alloc] initWithInteger:_flowController.selectedType],
                 CardNumberKey:cardnumber,
                 ExpirationDateKey:expDate,
                 SecurityCodeKey:_flowController.CVV}.mutableCopy;
    } else {
        card = @{CardTypeKey: [[NSNumber alloc] initWithInteger:_flowController.selectedType],
                 CardNumberKey:cardnumber,
                 SecurityCodeKey:_flowController.CVV}.mutableCopy;
    }
    
    if (![_flowController.cardName isEqualToString:@""]) {
        card[CardholderKey] = _flowController.cardName;
    }
    
    service.failureCaseWithData = ^(id data) {
        NSDictionary *responseObj = (NSDictionary *)data;
        
        if (responseObj[ErrorKey]){
            NSMutableString *msg = [responseObj[ErrorKey][ErrorMessageKey] mutableCopy];
            NSArray *invalidFields = responseObj[ErrorKey][DataKey];
            
            [msg appendString:@"\n"];
            for (int i = 0; i < invalidFields.count; i++) {
                [msg appendString:[self getFieldDescription:[invalidFields objectAtIndex:i]]];
            }
            
            PopUpBoxViewController *popUp = [[PopUpBoxViewController alloc] init];
            
            [_loadingView finishLoading:^{
                [popUp show:_parentVC title:@"Atenção!"
                description:msg imageMode:Error
               buttonAction:^{
                   [_flowController goBackWithErrors:invalidFields from:_parentVC];
               }];
            }];
        }
        
    };
    
    service.successCase = ^(NSDictionary *response){
        NSString *cardNonce = [response valueForKey:CardNonceKey];
        BOOL scannedCard = NO;
        if ([cardNumberFromPhoto isEqualToString:cardnumber]) {
            scannedCard = YES;
        }
        [self callAddCardWithCardNonce:cardNonce scannedCard:scannedCard withCompletion:completion];
    };
    
    [service prepareCard:card];
}

-(NSString *)getFieldDescription:(NSString *)field{
    if ([field isEqualToString:CardNumberKey]) {
        return @"- Número do cartão;\n";
    }else if ([field isEqualToString:CardholderKey]) {
        return @"- Nome;\n";
        
    }else if ([field isEqualToString:ExpirationDateKey]) {
        return @"- Validade;\n";
        
    }else if ([field isEqualToString:SecurityCodeKey]) {
        return @"- Código de segurança;\n";
    }
    return @"";
}

- (void)callAddCardWithCardNonce:(NSString *)cardNonce scannedCard:(BOOL)scannedCard withCompletion: (void (^)(NSString *))completion  {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        if([cod isEqualToString:@"16.6"]){
            [self callAddCardWithCardNonce:cardNonce scannedCard:scannedCard withCompletion:completion];
        } else {
            NSString *cancelButtonTitle = @"Entendi";
            if (cod == nil) {
                cancelButtonTitle = @"OK";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:cancelButtonTitle
                                                  otherButtonTitles:nil];
            
            [_loadingView finishLoading:nil];
            [alert show];
        }
    };
    
    service.successCase = ^(NSDictionary *response){
        /*
         * Em caso de erro, exibe alerta.
         * Se houver bloco de login com pagamento a ser chamado, deve listar os cartões
         * para obter os parâmetros do bloco.
         * Caso contrário, apenas fecha a view.
         */
        
        if ([(NSString*)[response valueForKey:@"status"] intValue] != 1) {
            [_loadingView finishLoading:^{
                NSString *msg = (NSString*)[response valueForKey:@"message"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"Fechar"
                                                      otherButtonTitles:nil];
                [alert show];
            }];
        } else {
            self.cardID = [response objectForKey:CardIDKey];
            [self callListCards:completion];
        }
    };
    
    [service addCardWithCardNonce:cardNonce scannedCard:scannedCard];
}

- (void)callListCards: (void (^)(NSString *))completion  {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        [_loadingView finishLoading:^{
            completion(nil);
        }];
    };
    
    service.successCase = ^(NSDictionary *response) {
        [_loadingView finishLoading:^{
            if(_flowController.selectedType == CardTypePatAlimentacao || _flowController.selectedType == CardTypePatRefeicao)
                completion(nil);
            else if ([[[CreditCardsList sharedList] creditCards] count] > 1) {
                [self setDefaultCard:completion];
            } else {
                completion(nil);
            }
        }];
    };
    
    [service listCards];
}

- (void)setDefaultCard: (void (^)(NSString *))completion  {
    if (self.cardID == nil) return;
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        [_loadingView finishLoading:^{
            completion(nil);
        }];
    };
    
    service.successCase = ^(NSDictionary *response) {
        [_loadingView finishLoading:^{
            if ([[response objectForKey:SubscriptionInOtherCardKey] boolValue]) {
                NSString *cardNumber = self.flowController.enteredCardNumber;
                NSString *lastDigits = [cardNumber substringFromIndex:cardNumber.length-4];
                NSString *message = @"Você possuí assinatura(s) associadas a outros cartões. Deseja transferir todas as suas assinaturas para seu novo cartão padrão, final xxxx?";
                message = [message stringByReplacingOccurrencesOfString:@"xxxx" withString:lastDigits];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Sim"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self setSubscriptionsForCard:completion];
                                            }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"Não"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               completion(nil);
                                           }];
                
                [alert addAction:noButton];
                [alert addAction:yesButton];
                
                [self.parentVC presentViewController:alert animated:YES completion:nil];
            } else {
                completion(nil);
            }
        }];
    };
    
    [_loadingView startLoading:self.parentVC title:@"Aguarde..."];
    [service setDefaultCardWithCardID:self.cardID];
}

- (void)setSubscriptionsForCard: (void (^)(NSString *))completion  {
    if (self.cardID == nil) return;
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        [_loadingView finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:_parentVC
                  title:@"Atenção!"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    service.successCase = ^(NSDictionary *response) {
        [_loadingView finishLoading:^{
            NSString *cardNumber = self.flowController.enteredCardNumber;
            NSString *lastDigits = [cardNumber substringFromIndex:cardNumber.length-4];
            NSString *message = @"Todas as suas assinaturas assinaturas foram transferidas com sucesso para o cartão final xxxx.";
            message = [message stringByReplacingOccurrencesOfString:@"xxxx" withString:lastDigits];
            
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:_parentVC
                  title:@"Atenção!"
            description:message
              imageMode:Success
           buttonAction:^{
               completion(nil);
           }];
        }];
    };
    
    [_loadingView startLoading:self.parentVC title:@"Aguarde..."];
    [service setCardForSubscriptions:self.cardID oldCardId:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (![string isEqualToString:@""] && textField.text.length == 6) {
        return NO;
    }

    if (_onUpdateField != nil) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        _onUpdateField(nil, nil, nil, text);
    }
    
    return YES;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    [AnalyticsUtil logEventWithName:@"digitacao_cvv_cartao" andParameters:nil];
    
    self.flowController.CVV = data;
    self.flowController.enteredCVV = data;
    _parentVC = vc;
    
    // Obtém a bandeira do cartão inserido
    NSNumber *cardBrand = [NSNumber numberWithInt:[CardUtil getBrandWithCardNumber:_flowController.cardNumber]];
    
    // Se a bandeira do cartão inserido não for aceita ou o cartão for de uma modalidade não aceita, exibe uma mensagem de erro
    if (![self cardIsAcceptedWithType:_flowController.selectedType andBrand:[cardBrand integerValue]]) {
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        [modal show:_parentVC
              title:@"Atenção!"
        description:@"Este cartão não é aceito para essa transação. Por favor, escolha outro cartão."
          imageMode:Error
       buttonAction:nil];
        return;
    }
    
    BOOL requestLocalizationPermission = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) &&
    ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) &&
    ([[Lib4allPreferences sharedInstance].requiredAntiFraudItems[@"geolocation"] isEqual: @YES]);
    
    if (requestLocalizationPermission) {
        if (!_loadingView.isLoading) {
            [_loadingView startLoading:_parentVC title:@"Aguarde..."];
        }
        
        [[LocationManager sharedManager] updateLocationWithCompletion:^(BOOL success, NSDictionary *location) {
            if (success) {
                [self callRequestVaultKey: completion];
            } else {
                PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_loadingView finishLoading:^{
                        [modal show:_parentVC
                              title:@"Atenção!"
                        description:@"Não foi possível obter sua localização. Ative os serviços de localização nos Ajustes."
                          imageMode:Error
                       buttonAction:nil];
                    }];
                });
            }
        }];
    } else {
        [self callRequestVaultKey: completion];
    }

}

-(BOOL)checkIfContentIsValid:(NSString *)text regex:(NSString *)regex{
    
    BOOL returnValue;
    NSString *cleanText = [text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@")" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([text length]==0){
        returnValue = NO;
    }else{
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:cleanText options:0 range:NSMakeRange(0, [cleanText length])];
        
        if (regExMatches == 0) {
            returnValue = NO;
        } else {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (bool) cardIsAcceptedWithType:(CardType) type andBrand: (CardBrand) brand {
    
    BOOL isValid = NO;
    
    //verifica os meios de pagamento do cartão
    
    //Verifica crédito
    if ((type == CardTypeCredit) && ([_flowController.acceptedPaymentTypes containsObject:@(Credit)])) isValid = YES;
    
    //Verifica débito
    if ((type == CardTypeDebit) && ([_flowController.acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    //Verifica ambos
    if ((type == CardTypeCreditAndDebit) && ([_flowController.acceptedPaymentTypes containsObject:@(Credit)] || [_flowController.acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    //Verifica brands
    if (![_flowController.acceptedBrands containsObject:@(brand)]) isValid = NO;
    
    if((type == CardTypePatRefeicao) && ([_flowController.acceptedPaymentTypes containsObject:@(PatRefeicao)]))
        isValid = YES;
    
    if((type == CardTypePatAlimentacao) && ([_flowController.acceptedPaymentTypes containsObject:@(PatAlimentacao)]))
        isValid = YES;
    
    
    return isValid;
    
}


-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"cartão"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}
@end
