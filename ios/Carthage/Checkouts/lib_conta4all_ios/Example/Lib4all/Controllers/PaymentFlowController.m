//
//  PaymentFlowController.m
//  Example
//
//  Created by Cristiano Matte on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "PaymentFlowController.h"
#import "DataFieldViewController.h"
#import "NameDataField.h"
#import "CPFDataField.h"
#import "BirthdateDataField.h"
#import "User.h"
#import "DateUtil.h"
#import "Services.h"
#import "LocationManager.h"
#import "Lib4allPreferences.h"
#import "BaseNavigationController.h"
#import "LocalizationFlowController.h"
#import <CoreLocation/CoreLocation.h>
#import "CreditCardsList.h"

@interface PaymentFlowController()
@property LocalizationFlowController *localizationFlowController;

@end

@implementation PaymentFlowController

@synthesize onLoginOrAccountCreation = _onLoginOrAccountCreation;



- (void)startFlowWithViewController:(UIViewController *)viewController {
    [self continueFluxWithViewController:viewController presentModally:YES];
}

- (void)viewControllerDidFinish:(UIViewController *)viewController {
    [self continueFluxWithViewController:viewController presentModally:NO];
}

- (void)continueFluxWithViewController:(UIViewController *)viewController presentModally:(BOOL)presentModally {
    UIViewController *destination;
    User *user = [User sharedUser];
    
    BOOL requestLocalizationPermission = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) &&
                                         ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) &&
                                         ([[Lib4allPreferences sharedInstance].requiredAntiFraudItems[@"geolocation"] isEqual: @YES]);
    BOOL requireCpf = (user.cpf == nil || [user.cpf isEqualToString:@""]);
    BOOL requireBirthdate = (user.birthdate == nil || [user.birthdate isEqualToString:@""]);
    CreditCard *defaultCard = [[CreditCardsList sharedList] getDefaultCard];
    
    // Se o cartão não é do usuário e ele é menor de idade, não pede cpf
    if (defaultCard.isShared && ![[defaultCard.sharedDetails[0] objectForKey:@"provider"] boolValue] && user.birthdate != nil && ![self validateBirthdate]) {
        requireCpf = NO;
    }
    
    if (requireCpf || requireBirthdate) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"DataFieldViewController"];
        
        if (defaultCard.isShared && ![[defaultCard.sharedDetails[0] objectForKey:@"provider"] boolValue] && requireBirthdate) {
            //Se o cartão é compartilhado e não tem data de nascimento, manda primeiro para a tela de inserção de data de nascimento
            // Redireciona para tela de inserção de data de nascimento
            ((DataFieldViewController *)destination).dataFieldProtocol = [[BirthdateDataField alloc] init];
        } else if (requireCpf) {
            // Redireciona para tela de inserção de cpf
            ((DataFieldViewController *)destination).dataFieldProtocol = [[CPFDataField alloc] init];
        } else if (requireBirthdate) {
            // Redireciona para tela de inserção de data de nascimento
            ((DataFieldViewController *)destination).dataFieldProtocol = [[BirthdateDataField alloc] init];
        }
        
        ((DataFieldViewController *)destination).flowController = self;
    } else if (requestLocalizationPermission) {
        //        if (![self validateBirthdateWithViewController:viewController closeViewControllerIfInvalid:NO]) {
        //            return;
        //        }
        
        _localizationFlowController = [[LocalizationFlowController alloc] init];
        _localizationFlowController.onLoginOrAccountCreation = _onLoginOrAccountCreation;
        _localizationFlowController.presentModally = presentModally;
        
        __weak PaymentFlowController *weakSelf = self;
        _localizationFlowController.completionBlock = ^(UIViewController *viewController) {
            [weakSelf viewControllerDidFinish:viewController];
        };
        
        [_localizationFlowController startFlowWithViewController:viewController];
        return;
    } else {
        /*
         * Chama callback pré-venda e set location.
         * Se alguma tela foi apresentada, deve dar dismiss antes
         */
        if (presentModally) {
            [self callSetGeolocation];
            if (_paymentCompletion != nil) _paymentCompletion();
        } else {
            [viewController dismissViewControllerAnimated:YES completion:^{
                [self callSetGeolocation];
                if (_paymentCompletion != nil) _paymentCompletion();
            }];
        }
    }
    
    if (destination != nil) {
        if (presentModally) {
            UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destination];
            [viewController presentViewController:navigationController animated:YES completion:nil];
        } else {
            [viewController.navigationController pushViewController:destination animated:YES];
        }
    }
}

- (BOOL)validateBirthdate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSDate *birthdate = [dateFormatter dateFromString:[User sharedUser].birthdate];
    
    
    if ([DateUtil isOverEighteen:birthdate]) {
        return YES;
    }
    return NO;
}

- (void)callSetGeolocation {
    Services *service = [[Services alloc] init];
    service.failureCase = ^(NSString *cod, NSString *msg) {};
    service.successCase = ^(NSDictionary *response){};
    
    [[LocationManager sharedManager] updateLocationWithCompletion:^(BOOL success, NSDictionary *location) {
        [service setGeolocation];
    }];
}

@end
