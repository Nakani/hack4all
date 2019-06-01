    //
//  Services.m
//  Example
//
//  Created by 4all on 4/5/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Services.h"
#import "Lib4all.h"
#import "LocationManager.h"
#import "ServicesConstants.h"
#import "User.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "Transaction.h"
#import "Subscription.h"
#import "Loyalty.h"
#import "Preferences.h"
#import "PersistenceHelper.h"
#import "Lib4allPreferences.h"
#import "UserAddress.h"
#import "Lib4allInfo.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface Services ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end


@implementation Services

- (id)init {
    self = [super init];

    if(self) {
        NSString *baseURLString;
        NSString *prepareCardBaseURLString;

        switch ([Lib4allPreferences sharedInstance].environment) {
            case EnvironmentTest:
                baseURLString = TestBaseURL;
                prepareCardBaseURLString = PrepareCardTestBaseURL;
                break;
            case EnvironmentHomologation:
                baseURLString = HomologBaseURL;
                prepareCardBaseURLString = PrepareCardHomologBaseURL;
                break;
            case EnvironmentProduction:
                baseURLString = ProductionBaseURL;
                prepareCardBaseURLString = PrepareCardProductionBaseURL;
        }

        self.baseURL            = [NSURL URLWithString:baseURLString];
        self.prepareCardBaseURL = [NSURL URLWithString:prepareCardBaseURLString];
        self.balanceType = [Lib4allPreferences sharedInstance].balanceType;
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
        self.manager.requestSerializer  = [AFJSONRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.requestSerializer.timeoutInterval = 60;
    }

    return self;
}

- (void)startLoginWithIdentifier:(NSString *)identifier {
    [self startLoginWithIdentifier:identifier requiredData:nil isCreation:NO];
}

- (void)startLoginWithIdentifier:(NSString *)identifier requiredData:(NSArray *)data isCreation:(BOOL)isCreation{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:identifier forKey:IdentifierKey];
    [parameters setValue:@NO forKey:SendSMSKey];

    if (data != nil) {
        [parameters setObject:data forKey:RequiredDataKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    [parameters setValue:Lib4allVersion forKey:LibVersionKey];


    NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
    UIDevice *currentDevice = [UIDevice currentDevice];
    [device setValue:@1 forKey:DeviceTypeKey];
    [device setValue:currentDevice.localizedModel forKey:DeviceModelKey];
    [device setValue:currentDevice.systemVersion forKey:OSVersionKey];
    [parameters setObject:device forKey:DeviceKey];

    [self.manager POST:StartLoginMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        User *sharedUser = [User sharedUser];
        if (!isCreation) {
            // Garante que os dados do usuário anterior foram removidos
            [[PersistenceHelper sharedHelper] removeEntities];
            sharedUser.currentState = UserStateOnLogin;
            sharedUser.token = [responseObject valueForKey:LoginTokenKey];
        }

        sharedUser.maskedPhone = [responseObject valueForKey:MaskedPhoneKey];
        sharedUser.maskedEmail = [responseObject valueForKey:MaskedEmailAddressKey];
        sharedUser.hasPassword = [[responseObject valueForKey:HasPasswordKey] boolValue];
        sharedUser.isPasswordBlocked = [[responseObject valueForKey:IsPasswordBlockedKey] boolValue];


        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)completeLoginWithChallenge:(NSString *)challenge {
    [self completeLoginWithChallenge:challenge accountData:nil socialData:nil];
}

- (void)completeLoginWithChallenge:(NSString *)challenge accountData:(NSDictionary *)data socialData:(NSMutableDictionary *)socialData{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:LoginTokenKey];
    [parameters setValue:challenge forKey:ChallengeKey];
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    if (data != nil) {
        [parameters setObject:data forKey:AccountDataKey];
    }

    if (socialData) {
        NSString *appName = Lib4allPreferences.sharedInstance.thirdPartyLoginAppName;
        [parameters setValue:appName forKey:ThirdPartyAccount];
        [parameters setValue:[socialData valueForKey:ThirdPartyToken] forKey:ThirdPartyToken];
        [parameters setValue:[socialData valueForKey:ThirdPartyType] forKey:ThirdPartyType];
        [parameters setValue:[socialData valueForKey:NativeSDKKey] forKey:NativeSDKKey];
    }

    [self.manager POST:CompleteLoginMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateOnLogin;
        sharedUser.token = [responseObject valueForKey:SessionTokenKey];
        sharedUser.sessionId = [responseObject valueForKey:SessionIDKey];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void)completeLoginWithPassword:(NSString *)password socialData:(NSMutableDictionary *)socialData{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:LoginTokenKey];
    [parameters setValue:password forKey:PasswordKey];
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    if (socialData) {
        NSString *appName = Lib4allPreferences.sharedInstance.thirdPartyLoginAppName;
        [parameters setValue:appName forKey:ThirdPartyAccount];
        [parameters setValue:[socialData valueForKey:ThirdPartyToken] forKey:ThirdPartyToken];
        [parameters setValue:[socialData valueForKey:ThirdPartyType] forKey:ThirdPartyType];
        [parameters setValue:[socialData valueForKey:NativeSDKKey] forKey:NativeSDKKey];
    }


    [self.manager POST:CompleteLoginMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateOnLogin;
        sharedUser.token = [responseObject valueForKey:SessionTokenKey];
        sharedUser.sessionId = [responseObject valueForKey:SessionIDKey];
        
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)refreshSessionWithSessionToken:(NSString *)sessionToken {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setValue:sessionToken forKey:SessionTokenKey];

    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    [parameters setValue:Lib4allVersion forKey:LibVersionKey];
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:RefreshSessionMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateLoggedIn;
        sharedUser.token = [responseObject valueForKey:SessionTokenKey];
        sharedUser.sessionId = [responseObject valueForKey:SessionIDKey];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)sendLoginSms {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    User *sharedUser = [User sharedUser];

    if (sharedUser.currentState == UserStateOnLogin) {
        [parameters setValue:sharedUser.token forKey:LoginTokenKey];
    } else if (sharedUser.currentState == UserStateOnCreation) {
        [parameters setValue:sharedUser.token forKey:CreationTokenKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SendLoginSMSMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)sendLoginEmail {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:LoginTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SendLoginEmailMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)logout {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    // O logout local é feito tanto em caso de sucesso quanto em caso de falha na requisição ao servidor
    [[User sharedUser] remove];
    [[CreditCardsList sharedList] remove];
    [[Preferences sharedPreferences] remove];


    [self.manager POST:LogoutMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)startCustomerCreationWithPhoneNumber:(NSString *)phone emailAddress:(NSString *)email {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *device = [[NSMutableDictionary alloc] init];

    [parameters setValue:phone forKey:PhoneNumberKey];

    if (email != nil) {
        [parameters setValue:email forKey:EmailAddressKey];
    }
    [parameters setValue:@YES forKey:SendSMSKey];

    UIDevice *myDevice = [UIDevice currentDevice];
    [device setValue:@1 forKey:DeviceTypeKey];
    [device setValue:myDevice.localizedModel forKey:DeviceModelKey];
    [device setValue:myDevice.systemVersion forKey:OSVersionKey];
    [parameters setObject:device forKey:DeviceKey];

    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    [parameters setValue:Lib4allVersion forKey:LibVersionKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:StartCustomerCreationMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;

        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateOnCreation;
        sharedUser.token = [response valueForKey:CreationTokenKey];
        sharedUser.accessKey = [response valueForKey:AccessKey];

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)completeCustomerCreationWithChallenge:(NSString *)challenge password:(NSString *)password {
    [self completeCustomerCreationWithChallenge:challenge password:password accountData:nil socialData:nil];
}

- (void)completeCustomerCreationWithChallenge:(NSString *)challenge password:(NSString *)password accountData:(NSDictionary *)data socialData:(NSDictionary *)socialData{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:CreationTokenKey];
    if (challenge != nil) {
        [parameters setValue:challenge forKey:ChallengeKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    if (data != nil) {
        [parameters setObject:data forKey:AccountDataKey];
    }
    if (password != nil) {
        [parameters setObject:password forKey:PasswordKey];
    }

    if (socialData) {
        NSString *appName = Lib4allPreferences.sharedInstance.thirdPartyLoginAppName;
        [parameters setValue:appName forKey:ThirdPartyAccount];
        [parameters setValue:[socialData valueForKey:ThirdPartyToken] forKey:ThirdPartyToken];
        [parameters setValue:[socialData valueForKey:ThirdPartyType] forKey:ThirdPartyType];
        [parameters setValue:[socialData valueForKey:NativeSDKKey] forKey:NativeSDKKey];
    }

    [self.manager POST:CompleteCustomerCreationMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateLoggedIn;
        sharedUser.token = [responseObject valueForKey:SessionTokenKey];
        sharedUser.sessionId = [responseObject valueForKey:SessionIDKey];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)requestVaultKey {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    User *sharedUser = [User sharedUser];

    if (sharedUser.currentState == UserStateOnCreation) {
        [parameters setValue:sharedUser.token forKey:CreationTokenKey];
    } else if (sharedUser.currentState == UserStateLoggedIn) {
        [parameters setValue:sharedUser.token forKey:SessionTokenKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:RequestVaultKeyMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        [[User sharedUser] setAccessKey:[response valueForKey:AccessKey]];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)prepareCard:(NSMutableDictionary *)card {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setObject:card forKey:CardDataKey];
    [parameters setValue:[[User sharedUser] accessKey] forKey:AccessKey];
    
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.prepareCardBaseURL];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager POST:PrepareCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {

        if (_failureCase != nil) {
            [self handleError:operation.responseObject];
        }else{
            self.failureCaseWithData(operation.responseObject);
        }

    }];
}

- (void)addCardWithCardNonce:(NSString *)cardNonce scannedCard:(BOOL)scannedCard {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:cardNonce forKey:CardNonceKey];
    [parameters setValue:@YES forKey:WaitForCardKey];
    [parameters setValue:[NSNumber numberWithBool:scannedCard] forKey:@"scannedCard"];
    
    User *sharedUser = [User sharedUser];
    if (sharedUser.currentState == UserStateOnCreation) {
        [parameters setValue:sharedUser.token forKey:CreationTokenKey];
        [parameters setValue:@YES forKey:SendLoginSMSKey];
    } else if (sharedUser.currentState == UserStateLoggedIn) {
        [parameters setValue:sharedUser.token forKey:SessionTokenKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    NSLog(@"%@", parameters);
    [self.manager POST:AddCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)deleteCardWithCardID:(NSString *)cardID {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:cardID forKey:CardIDKey];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:DeleteCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        CreditCardsList *cardsList = [CreditCardsList sharedList];
        CreditCard *deletedCreditCard = [cardsList getCardWithID:cardID];
        [cardsList.creditCards removeObject:deletedCreditCard];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)getCardDetailsWithCardID:(NSString *)cardID {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    User* sharedUser = [User sharedUser];

    if (sharedUser.currentState == UserStateOnCreation) {
        [parameters setValue:sharedUser.token forKey:CreationTokenKey];
    } else if (sharedUser.currentState == UserStateLoggedIn) {
        [parameters setValue:sharedUser.token forKey:SessionTokenKey];
    }

    if (cardID != nil) {
        [parameters setValue:cardID forKey:CardIDKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:GetCardDetailsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;

        // Confirma que cartão é o default antes de setar localmente
        if ([[response objectForKey:IsDefaultKey] boolValue]) {
            [[CreditCardsList sharedList] setDefaultCardWithCardID:[response objectForKey:CardIDKey]];
        }

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void)setDefaultCardWithCardID:(NSString *)cardID {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:cardID forKey:CardIDKey];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SetDefaultCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        [[CreditCardsList sharedList] setDefaultCardWithCardID:cardID];
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)listCards {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:@0 forKey:ItemIndexKey];
    [parameters setValue:@100 forKey:ItemCountKey];
    [parameters setValue:@YES forKey:PendingSharedCardsKey];

    self.manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];


    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    [parameters setValue:Lib4allVersion forKey:LibVersionKey];
    
    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    
    [self.manager POST:ListCardsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;

        // Remove todos os cartões locais antes de inserir os novos
        [[CreditCardsList sharedList] remove];

        NSMutableArray *cardsList = (NSMutableArray *)[response objectForKey:CardListKey];
        for (NSDictionary* cardDictionary in cardsList) {
            CreditCard *card = [[CreditCard alloc] init];
            card.status = [cardDictionary objectForKey:StatusKey];

            if ([card.status isEqual: @1]) {
                card.type = [[cardDictionary objectForKey:CardTypeKey] intValue];
                card.cardId = [cardDictionary objectForKey:CardIDKey];
                card.brandId = [cardDictionary objectForKey:BrandIDKey];
                card.lastDigits = [cardDictionary objectForKey:LastDigitsKey];
                card.isDefault = [[cardDictionary objectForKey:IsDefaultKey] boolValue];
                card.isShared = [[cardDictionary objectForKey:IsSharedKey] boolValue];
                card.bin = [cardDictionary objectForKey:BinKey];
                card.brandLogoUrl = [cardDictionary objectForKey:CardBrandLogoUrlKey];
                card.cardDescription = [cardDictionary objectForKey:CardDescriptionKey];
                card.expirationDate = [cardDictionary objectForKey:CardExpirationDateKey];
                card.balance = [cardDictionary objectForKey:CardBalanceKey];
                card.showBalance = [[cardDictionary objectForKey:CardShowBalanceKey] boolValue];
                card.balanceMessage = [cardDictionary objectForKey:CardBalanceMessageKey];
                card.askCvv = [[cardDictionary objectForKey:CardAskCvvKey] boolValue];
                card.cvvFormat = [cardDictionary objectForKey:CardCvvFormatKey];
                card.cvvMessage = [cardDictionary objectForKey:CardCvvMessageKey];

                if (card.isShared) {
                    card.sharedDetails = [cardDictionary objectForKey:SharedDetailsKey];
                }


                [[[CreditCardsList sharedList] creditCards] addObject:card];
            }
        }

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)getAccountData:(NSArray *)data {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:data forKey:DataKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:GetAccountDataMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        User* sharedUser = [User sharedUser];
        
        // Atualiza os dados do usuário localmente
        for (NSString *key in response) {
            if ([response[key] isEqual:[NSNull null]]) continue;

            if ([sharedUser respondsToSelector:NSSelectorFromString(key)]) {
                [sharedUser setValue:response[key] forKey:key];
            }
        }

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setAccountData:(NSDictionary *)data {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:data forKey:DataKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:SetAccountDataMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User* sharedUser = [User sharedUser];

        // Atualiza os dados do usuário localmente
        for (NSString *key in data) {
            if ([sharedUser respondsToSelector:NSSelectorFromString(key)]) {
                [sharedUser setValue:data[key] forKey:key];
            }
        }

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

-(void)getAccountPhoto {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:GetAccountPhotoMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *response = responseObject;
        id base64Photo = response[PhotoDataKey];
        if(base64Photo != [NSNull null]) {
            [User sharedUser].profilePictureBase64 = ((NSString *)base64Photo);
        }
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setAccountPhoto:(NSString *)base64Photo {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:base64Photo forKey:PhotoDataKey];
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:SetAccountPhotoMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)getAccountDataByTerm:(NSString *)term {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    [parameters setValue:@[FullNameKey] forKey:DataKey];



    if ([term containsString:@"@"]) {
        [parameters setValue:@{ EmailAddressKey: term } forKey:TermKey];
    } else {
        [parameters setValue:@{ PhoneNumberKey: term } forKey:TermKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:GetAccountDataByTermMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)getAccountPreferences:(NSArray *)preferences {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:preferences forKey:PreferencesKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:GetAccountPreferencesMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        Preferences *sharedPreferences = [Preferences sharedPreferences];

        // Atualiza os dados localmente
        for (NSString *key in response) {
            if ([sharedPreferences respondsToSelector:NSSelectorFromString(key)]) {
                [sharedPreferences setValue:response[key] forKey:key];
            }
        }

        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setAccountPreferences:(NSDictionary *)preferences {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:preferences forKey:PreferencesKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SetAccountPreferencesMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        Preferences *sharedPreferences = [Preferences sharedPreferences];

        // Atualiza os dados localmente
        for (NSString *key in preferences) {
            if ([sharedPreferences respondsToSelector:NSSelectorFromString(key)]) {
                [sharedPreferences setValue:preferences[key] forKey:key];
            }
        }

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)changeEmailAddress:(NSString *)email {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:email forKey:EmailAddressKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:ChangeEmailAddressMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)requestEmailConfirmation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:RequestEmailConfirmationMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setPhoneNumber:(NSString *)phone {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:phone forKey:PhoneNumberKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SetPhoneNumberMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *)responseObject;
        self.successCase(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)confirmPhoneNumber:(NSString *)phone withChallenge:(NSString *)challenge phoneChangeToken:(NSString *)changeToken {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:changeToken forKey:PhoneChangeTokenKey];
    [parameters setValue:challenge forKey:ChallengeKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:ConfirmPhoneNumberMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [[User sharedUser] setPhoneNumber:phone];
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)resendSMSChallengeForPhoneChangeToken:(NSString *)changeToken {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:changeToken forKey:PhoneChangeTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:ResendSMSChallengeMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)listTransactionsWithStartingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount {
    [self listTransactionsWithSubscriptionID:nil startingItemIndex:itemIndex itemCount:itemCount];
}

- (void)listSubscriptionsWithStartingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:itemIndex forKey:ItemIndexKey];
    [parameters setValue:itemCount forKey:ItemCountKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:ListSubscriptionsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSMutableArray *subscriptions = [[NSMutableArray alloc] initWithCapacity:response.count];

        for (NSDictionary* dictionary in (NSArray *)[response objectForKey:SubscriptionListKey]) {
            [subscriptions addObject:[[Subscription alloc] initWithJSONDictionary:dictionary]];
        }

        self.successCase(subscriptions);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)listTransactionsWithSubscriptionID:(NSString *)subscriptionID startingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:itemIndex forKey:ItemIndexKey];
    [parameters setValue:itemCount forKey:ItemCountKey];

    if (subscriptionID) [parameters setValue:subscriptionID forKey:SubscriptionIDKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:ListTransactionsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSMutableArray *transactions = [[NSMutableArray alloc] initWithCapacity:response.count];

        for (NSDictionary* dictionary in (NSArray *)[response objectForKey:TransactionListKey]) {
            [transactions addObject:[[Transaction alloc] initWithJSONDictionary:dictionary]];
        }

        self.successCase(transactions);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)getSubscriptionDetailsWithSubscriptionID:(NSString *)subscriptionId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:subscriptionId forKey:SubscriptionIDKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:GetSubscriptionDetailsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setGeolocation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];

    NSDictionary *location = [[LocationManager sharedManager] getLocation];
    if (location != nil) {
        [parameters setObject:location forKey:GeoLocationKey];
    }

    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    [parameters setValue:Lib4allVersion forKey:LibVersionKey];

    [self.manager POST:SetGeolocationMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) addAddress:(UserAddress *)address {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters addEntriesFromDictionary:@{
        AddressNameKey  : address.name,
        AddressStreetKey: address.street,
        NeighborhoodKey : address.neighborhood,
        CityKey         : address.city,
        AddressZipKey   : address.zip,
        ProvinceKey     : address.province,
        CountryKey      : address.country
    }];

    if (address.number) {
        [parameters setObject:address.number forKey:AddressNumberKey];
    }

    if (address.complement) {
        [parameters setObject:address.complement forKey:AddressComplementKey];
    }

    if (address.reference) {
        [parameters setObject:address.reference forKey:AddressReferenceKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:AddAddressMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) setDefaultAddress:(NSString *)addressId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setObject:addressId forKey:AddressIDKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SetDefaultAddressMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) deleteAddress:(NSString *)addressId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setObject:addressId forKey:AddressIDKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:DeleteAddressMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void) addSharedCard:(NSString *) cardId phoneNumber:(NSString *) phoneNumber withData: (NSDictionary *) data intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue  {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:data];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:phoneNumber forKey:PhoneNumberKey];
    [parameters setValue:intervalType forKey:IntervalTypeKey];
    [parameters setValue:intervalValue forKey:IntervalValueKey];


    [self.manager POST:AddSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) addSharedCard:(NSString *) cardId phoneNumber:(NSString *) phoneNumber withBalance: (NSNumber *) balance intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue  {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:phoneNumber forKey:PhoneNumberKey];
    [parameters setValue:balance forKey:RecurringBalanceKey];
    [parameters setValue:intervalType forKey:IntervalTypeKey];
    [parameters setValue:intervalValue forKey:IntervalValueKey];


    [self.manager POST:AddSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) acceptSharedCard:(NSString *) cardId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];


    [self.manager POST:AcceptSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void) deleteSharedCard:(NSString *) cardId custumerId:(NSString *) customerId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:customerId forKey:CustomerIdKey];



    [self.manager POST:DeleteSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void) updateSharedCard:(NSString *) cardId customerId:(NSString *) customerId withData: (NSDictionary *) data {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:data];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:customerId forKey:CustomerIdKey];

    [self.manager POST:UpdateSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) updateSharedCard:(NSString *) cardId customerId:(NSString *) customerId withBalance: (NSNumber *) balance {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:customerId forKey:CustomerIdKey];
    [parameters setValue:balance forKey:RecurringBalanceKey];


    [self.manager POST:UpdateSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) updateSharedCard:(NSString *) cardId customerId:(NSString *) customerId withBalance: (NSNumber *) balance intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue  {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:customerId forKey:CustomerIdKey];
    [parameters setValue:balance forKey:RecurringBalanceKey];
    [parameters setValue:intervalType forKey:IntervalTypeKey];
    [parameters setValue:intervalValue forKey:IntervalValueKey];


    [self.manager POST:UpdateSharedCardMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void) setCardForSubscriptions:(NSString *) cardId oldCardId:(NSString *)oldCardId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];

    if (oldCardId) {
        [parameters setValue:oldCardId forKey:OldCardIDKey];
    }

    NSDictionary *location = [[LocationManager sharedManager] getLocation];
    if (location != nil) {
        [parameters setObject:location forKey:GeoLocationKey];
    }

    [self.manager POST:SetCardForSubscriptionsMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

-(void)checkStatus{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:CheckStatusMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        User *sharedUser = [User sharedUser];
        [sharedUser setHasPassword:[[responseObject valueForKey:@"hasPassword"] boolValue]];

        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

-(void)checkPassword:(NSString *)password {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:password forKey:PasswordKey];
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:CheckPasswordMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)setNewPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];
    [parameters setValue:newPassword forKey:NewPasswordKey];

    if (oldPassword != nil) {
        [parameters setValue:oldPassword forKey:OldPasswordKey];
    } else {
        [parameters setValue:[NSNull null] forKey:OldPasswordKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [self.manager POST:SetPasswordMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}



- (void)startPasswordRecoveryWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (![identifier containsString:@"@"] && identifier.length < 13) {
        identifier = [NSString stringWithFormat:@"55%@", identifier];
    }

    [parameters setValue:identifier forKey:IdentifierKey];

    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    
    [self.manager POST:StartPasswordRecoveryMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void)validateCpf:(NSString *)cpf{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setValue:cpf forKey:CpfKey];
    if([[Lib4all sharedInstance] hasUserLogged]){
        [parameters setValue:[[User sharedUser] token] forKey:SessionTokenKey];

    }else{
        [parameters setValue:[[User sharedUser] token] forKey:CreationTokenKey];

    }

    [self.manager POST:ValidateCpfMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void)validateSmsOrEmailWithChallenge:(NSString *)challenge{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setValue:challenge forKey:ChallengeKey];
    [parameters setValue:[[User sharedUser] token] forKey:CreationTokenKey];

    [self.manager POST:ValidateChallengeMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

-(void)payTransaction:(NSString *)sessionToken withTransactionId:(NSString *)transactionId andCardId:(NSString *)cardId payMode:(PaymentMode)payMode amount:(NSNumber *)amount installments:(NSNumber *)installments waitForTransaction:(BOOL)waitForTransaction loyalty:(NSDictionary *)loyalty isPaymentToken:(BOOL)isPaymentToken{

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    
    if (cardId) {
        [parameters setValue:cardId forKey:CardIDKey];
    }
    
    if(isPaymentToken) {
        [parameters setValue:transactionId forKey:TransactionTokenKey];
        [parameters setValue:@YES forKey:DontCancelOnTimeoutKey];
    } else {
        [parameters setValue:transactionId forKey:TransactionIDKey];
    }
    
    [parameters setValue:@([amount intValue]) forKey:AmountKey];
    [parameters setValue:@(payMode) forKey:PayMode];
    [parameters setValue:@([installments intValue]) forKey:Installments];
    [parameters setValue:[NSNumber numberWithBool:waitForTransaction] forKey:WaitForTransaction];
    [parameters setValue:self.balanceType forKey:BalanceTypeKey];
    
    if([installments integerValue] > 1) {
        [parameters setValue:@2 forKey:InstallmentTypeKey];
    } else {
        [parameters setValue:@1 forKey:InstallmentTypeKey];
    }

    if([[LocationManager sharedManager] getLocation] != nil) {
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    if(loyalty) {
        [parameters setObject:loyalty forKey:LoyaltyKey];
    }

    
    [self.manager POST:PayTransaction parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

-(void)offlinePayTransaction:(NSString *)sessionToken withTransactionId:(NSString *)transactionId andCardId:(NSString *)cardId payMode:(PaymentMode)payMode amount:(NSNumber *)amount installments:(NSNumber *)installments cupomUIID:(NSString *)cupomUIID campaignUUID:(NSString *)campaignUUID merchantKeyId:(NSString *)merchantKeyId blob:(NSString *)blob waitForTransaction:(BOOL)waitForTransaction{

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *installmentsNumber = @(1);

    formatter.numberStyle = NSNumberFormatterNoStyle;

    //Encode Blob in base64
    if (blob != nil) {
        //Decode from URLEncoding
        blob = [blob stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:cardId forKey:CardIDKey];
    [parameters setValue:transactionId forKey:TransactionIDKey];
    [parameters setValue:@([amount intValue]) forKey:AmountKey];
    [parameters setValue:@(payMode) forKey:PayMode];
    [parameters setValue:merchantKeyId forKey:MerchantKeyId];
    [parameters setValue:blob  forKey:TransactionData];
    [parameters setValue:[NSNumber numberWithBool:waitForTransaction] forKey:WaitForTransaction];


    //Parametro só é enviado quando parcelado e não a vista
    if (installmentsNumber.intValue > 1){
        [parameters setValue:@([installments intValue]) forKey:Installments];
    }

    if (cupomUIID != nil) {
        [parameters setValue:cupomUIID forKey:CouponUUID];
    }

    if (campaignUUID != nil) {
        [parameters setValue:campaignUUID forKey:CampaignUUID];
    }

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    
    [self.manager POST:OfflinePayTransaction parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

-(void)refundTransactionWithId:(NSString *)transactionId{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:transactionId forKey:TransactionIDKey];
    [parameters setValue:@YES forKey:WaitForTransaction];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    NSLog(@"%@", parameters);
    [self.manager POST:RefundTransaction parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) openTunnel {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [self.manager POST:OpenTunnelMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (AFHTTPRequestOperationManager *) waitForTunnel:(NSString *) tunnelToken  {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:tunnelToken forKey:TunnelTokenKey];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager.requestSerializer setTimeoutInterval:45];

    [manager POST:WaitForTunnelMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

    return manager;
}

-(void)thirdPartyLogin:(NSString *)socialToken fromSocialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *appName = Lib4allPreferences.sharedInstance.thirdPartyLoginAppName;
    [parameters setValue:appName forKey:ThirdPartyAccount];
    [parameters setValue:socialToken forKey:ThirdPartyToken];
    [parameters setValue:@(socialMedia) forKey:ThirdPartyType];

    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    [parameters setValue:Lib4allVersion forKey:LibVersionKey];

    NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
    UIDevice *currentDevice = [UIDevice currentDevice];
    [device setValue:@1 forKey:DeviceTypeKey];
    [device setValue:currentDevice.localizedModel forKey:DeviceModelKey];
    [device setValue:currentDevice.systemVersion forKey:OSVersionKey];
    [parameters setObject:device forKey:DeviceKey];
    [parameters setValue:@(nativeSDK) forKey:NativeSDKKey];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager.requestSerializer setTimeoutInterval:45];

    [manager POST:ThirdPartyLogin parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        if ([[responseObject valueForKey:@"hasAccount"] boolValue]) {
            User *sharedUser = [User sharedUser];
            // Garante que os dados do usuário anterior foram removidos
            [[PersistenceHelper sharedHelper] removeEntities];
            sharedUser.currentState = UserStateOnLogin;
            sharedUser.token = [responseObject valueForKey:SessionTokenKey];
        }


        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

-(void)resendEmailPaymentSlip:(NSString *)transactionId{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    [parameters setValue:transactionId forKey:TransactionIDKey];


    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }

    NSLog(@"%@", parameters);
    [self.manager POST:ResendEmailPaymentSlipMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

-(void)getMerchantData:(NSString *)transactionId andAmount:(NSNumber *)amount isPaymentToken:(BOOL)isPaymentToken {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if ([[User sharedUser] currentState] == UserStateLoggedIn) {
        [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    }
    if(isPaymentToken) {
        [parameters setValue:transactionId forKey:TransactionTokenKey];
    } else {
        [parameters setValue:transactionId forKey:TransactionIDKey];
    }
    if(amount) {
        [parameters setValue:amount forKey:AmountKey];
    }
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:GetMerchantData parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

-(void)getTransactionDetails:(NSString *)transactionId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if ([[User sharedUser] currentState] == UserStateLoggedIn) {
        [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    }
    [parameters setValue:transactionId forKey:TransactionIDKey];
    
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:GetTransactionDetails parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void)handleError:(NSDictionary *)responseObj {
    if (responseObj[ErrorKey]){
        self.failureCase(responseObj[ErrorKey][ErrorCodeKey],responseObj[ErrorKey][ErrorMessageKey]);
    }else{
        self.failureCase(nil, @"Erro ao se comunicar com o servidor");
    }
}

@end
