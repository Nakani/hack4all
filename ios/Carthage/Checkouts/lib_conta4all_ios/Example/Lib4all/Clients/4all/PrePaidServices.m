//
//  PrePaidServices.m
//  Example
//
//  Created by Adriano Soares on 14/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PrePaidServices.h"
#import "User.h"
#import "Lib4allPreferences.h"
#import "ServicesConstants.h"
#import "LocationManager.h"


@interface PrePaidServices ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation PrePaidServices

- (id)init {
    self = [super init];
    
    if(self) {
        NSString *baseURLString;
        
        switch ([Lib4allPreferences sharedInstance].environment) {
            case EnvironmentTest:
                baseURLString = PrePaidTestBaseURL;
                break;
            case EnvironmentHomologation:
                baseURLString = PrePaidHomologBaseURL;
                break;
            case EnvironmentProduction:
                baseURLString = PrePaidProductionBaseURL;
                break;
        }
        
        self.baseURL = [NSURL URLWithString:baseURLString];
        self.balanceType = [Lib4allPreferences sharedInstance].balanceType;
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
        self.manager.requestSerializer  = [AFJSONRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.requestSerializer.timeoutInterval = 60;
    }
    
    return self;
}

- (void) balance {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"sessionToken %@", [User sharedUser].token]  forHTTPHeaderField:AuthorizationKey];
    
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [parameters setValue:self.balanceType forKey:@"balanceType"];
    
    [self.manager GET:BalanceMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {
            if (self.successCase) {
                self.successCase(responseObject);
            }
        } else {
            [self handleError:operation.responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void) listStatements:(StatementSource)source  {
    [self listStatements: source before:0];
}

- (void) listStatements:(StatementSource)source before:(double)lastCreatedAt {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"sessionToken %@", [User sharedUser].token]  forHTTPHeaderField:AuthorizationKey];
    
    NSString *applicationName = [[Lib4allPreferences sharedInstance].applicationID componentsSeparatedByString:@"_"][1];
    [parameters setValue:applicationName forKey:@"applicationName"];
    [parameters setValue:self.balanceType forKey:@"balanceType"];
    [parameters setValue:@30 forKey:@"itemCount"];
    
    if (source == StatementSourceIncoming) {
        [parameters setValue:TrueKey forKey:@"onlyIncoming"];
    } else if (source == StatementSourceOutgoing) {
        [parameters setValue:TrueKey forKey:@"onlyOutgoing"];
    }
    
    if (lastCreatedAt > 0) {
        [parameters setValue:[NSNumber numberWithDouble:lastCreatedAt] forKey:LastCreatedAtKey];
    }
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager GET:StatementMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {
            //TODO: filtrar tipos não validos
            self.successCase([responseObject objectForKey:@"statement"]);
        } else {
            [self handleError:operation.responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void) paymentCashIn:(double)lastCreatedAt {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"sessionToken %@", [User sharedUser].token]  forHTTPHeaderField:AuthorizationKey];

    [parameters setValue:self.balanceType forKey:@"balanceType"];
    [parameters setValue:@30 forKey:@"itemCount"];
    [parameters setValue:[NSNumber numberWithInt:TransactionPayModePaymentSlip] forKey:PaymentModeKey];
    
    if (lastCreatedAt > 0) {
        [parameters setValue:[NSNumber numberWithDouble:lastCreatedAt] forKey:LastCreatedAtKey];
    }
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager GET:PaymentCashInMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {

            self.successCase([responseObject objectForKey:@"cashIns"]);
        } else {
            [self handleError:operation.responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void) createPaymentCashIn:(double)amount payMode:(TransactionPayMode)payMode receiverCpf:(NSString *)cpf receiverPhoneNumber:(NSString *)phoneNumber description:(NSString *)description cardId:(NSString *)cardId password:(NSString * _Nullable)password  {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"sessionToken %@", [User sharedUser].token]  forHTTPHeaderField:AuthorizationKey];
    
    [parameters setValue:self.balanceType forKey:BalanceTypeKey];
    [parameters setObject:[NSNumber numberWithDouble:amount]  forKey:AmountKey];
    [parameters setObject:[NSNumber numberWithInteger:payMode]  forKey:PayMode];
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    if (cardId != nil) {
        [parameters setValue:cardId forKey:CardIDKey];
    }
    
    if(password != nil) {
        [parameters setValue:password forKey:PasswordKey];
    }
    
    if(description != nil && ![description isEqualToString:@""]) {
        [parameters setValue:description forKey:DescriptionKey];
    }
    
    if (phoneNumber != nil) {
        NSMutableDictionary *receiverParameters = [[NSMutableDictionary alloc] init];
        [receiverParameters setValue:phoneNumber forKey:IdentifierKey];
        [receiverParameters setValue:self.balanceType forKey:BalanceTypeKey];
        if(![cpf isEqualToString:@""]) {
            [receiverParameters setValue:cpf forKey:CustomerDocumentKey];
        }
        [parameters setObject:receiverParameters forKey:ReceiverKey];
    }
    
    [self.manager POST:PaymentCashInMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {
            self.successCase(responseObject);
        } else {
            [self handleError:operation.responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}

- (void) getSummary:(double) after {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[User sharedUser].token forHTTPHeaderField:AuthorizationKey];
    
    NSString *applicationName = [[Lib4allPreferences sharedInstance].applicationID componentsSeparatedByString:@"_"][1];
    [parameters setValue:applicationName forKey:@"applicationName"];
    [parameters setValue:self.balanceType forKey:@"balanceType"];
    [parameters setValue:[NSNumber numberWithInteger:after*1000] forKey:AfterKey];

    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager GET:SummaryMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {
            self.successCase([responseObject objectForKey:SummaryKey]);
        } else {
            [self handleError:operation.responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}
- (void) p2pTransferToId:(NSString *)destinationIdentifier amout:(NSNumber *)amount description:(NSString *)description password:(NSString * _Nullable)password destinationCpf:(NSString *)cpf{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self.manager.requestSerializer setValue:[User sharedUser].token forHTTPHeaderField:AuthorizationKey];
    
    [parameters setValue:self.balanceType forKey:@"originBalanceType"];
    [parameters setValue:self.balanceType forKey:@"destinationBalanceType"];
    if (![cpf isEqualToString:@""]){
        [parameters setValue:cpf forKey:DestinationDocumentKey];
    }
    [parameters setValue:destinationIdentifier forKey:DestinationIdentifierKey];
    [parameters setValue:amount forKey:AmountKey];
    [parameters setValue:description forKey:DescriptionKey];
    if(password != nil) {
        [parameters setValue:password forKey:PasswordKey];
    }
    
    if([[LocationManager sharedManager] getLocation] != nil){
        [parameters setObject:[[LocationManager sharedManager] getLocation] forKey:GeoLocationKey];
    }
    
    [self.manager POST:P2PTransferMethod parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:SuccessKey] boolValue]) {
            self.successCase([responseObject objectForKey:@"transferId"]);
        } else {
            [self handleError:operation.responseObject];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];
}


- (void)handleError:(NSDictionary *)responseObj {
    if (responseObj[@"errorMessage"]){
        self.failureCase(responseObj[ErrorCodeKey],responseObj[@"errorMessage"]);
    }else{
        self.failureCase(nil, @"Erro ao se comunicar com o servidor");
    }
}

@end
