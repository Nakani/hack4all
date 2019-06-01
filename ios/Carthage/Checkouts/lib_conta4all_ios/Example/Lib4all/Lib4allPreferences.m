//
//  Lib4allPreferences.m
//  Example
//
//  Created by Cristiano Matte on 21/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Lib4allPreferences.h"
#import "CardUtil.h"
#import "LayoutManager.h"

@implementation Lib4allPreferences

@synthesize acceptedBrands = _acceptedBrands;
@synthesize termsOfServiceURL = _termsOfServiceURL;

+ (instancetype)sharedInstance {
    static Lib4allPreferences *sharedInstance = nil;
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[Lib4allPreferences alloc] init];
        }
    }
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Por padrão, aceita pagamento com crédito e bandeiras Master e Visa
        
        //isso é deprecated, na verdade, este parâmetro não é para ser mais usado
        //self.acceptedPaymentMode = PaymentModeCredit;
        
        //esse será o parâmetro que deve ser consultado de agora em diante para saber quais são os meios de pagamento aceitos pelo aplicativo
        self.acceptedPaymentTypes = @[@(Credit), @(CheckingAccount)];
        
        
        self.acceptedBrands = [[NSSet alloc] initWithObjects:
                               [NSNumber numberWithInt:CardBrandVisa],
                               [NSNumber numberWithInt:CardBrandMastercard], nil];
        
        // Por padrão, os termos de uso são o da 4all
        self.termsOfServiceURL = [NSURL URLWithString:@"http://4all.com/termosdeuso"];

        // Por padrão, utiliza o ambiente de testes
        self.environment = EnvironmentTest;
        
        // Por padrão, ativa o anti-fraude exigindo cpf e data de nascimento
        self.requiredAntiFraudItems = [[NSMutableDictionary alloc] initWithObjects:@[@YES, @YES, @YES] forKeys:@[@"cpf", @"birthdate", @"geolocation"]];
        
        // Cores padrões do botão e do loader
        self.loaderColor = nil;
        
        // Por padrão, o balanceType é o da conta 4all
        self.balanceType = @"4all";
        self.balanceTypeFriendlyName = @"4all";
        self.thirdPartyLoginAppName = @"4all";
        self.wizardAppName = @"4all";
        self.isBalanceFloatingButtonEnabled = YES;
        self.isCardOCREnabled = YES;
        self.registerWithoutCardAddition = NO;
    }
    
    return self;
}

- (void)setAcceptedBrands:(NSSet *)acceptedBrands {
    if (acceptedBrands) _acceptedBrands = acceptedBrands;
}

- (void)setTermsOfServiceURL:(NSURL *)termsOfServiceURL {
    if (termsOfServiceURL) _termsOfServiceURL = termsOfServiceURL;
}

@end
