//
//  LoyaltyServices.m
//  Example
//
//  Created by Natanael Ribeiro on 15/08/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "LoyaltyServices.h"
#import "User.h"
#import "Lib4allPreferences.h"
#import "ServicesConstants.h"
#import "LocationManager.h"

@interface LoyaltyServices ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation LoyaltyServices

- (id)init {
    self = [super init];
    
    if(self) {
        NSString *baseURLString;
        
        switch ([Lib4allPreferences sharedInstance].environment) {
            case EnvironmentTest:
                baseURLString = LoyaltyTestBaseURL;
                break;
            case EnvironmentHomologation:
                baseURLString = LoyaltyHomologBaseURL;
                break;
            case EnvironmentProduction:
                baseURLString = LoyaltyProductionBaseURL;
                break;
        }
        
        self.baseURL = [NSURL URLWithString:baseURLString];
        
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
        self.manager.requestSerializer  = [AFJSONRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.requestSerializer.timeoutInterval = 60;
    }
    
    return self;
}

-(void)promoCode:(NSString *)code withTransactionId:(NSString * _Nullable)transactionId orMerchantId:(NSString * _Nullable)merchantId andAmount:(NSNumber *_Nonnull)amount {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:[User sharedUser].token forKey:SessionTokenKey];
    NSString *applicationID = [[Lib4allPreferences sharedInstance] applicationID];
    if (applicationID != nil) {
        [parameters setValue:applicationID forKey:ApplicationIDKey];
    }
    if (transactionId) {
        [parameters setValue:transactionId forKey:TransactionIDKey];
    } else if (merchantId) {
        [parameters setValue:merchantId forKey:MerchantIdKey];
    }
    [parameters setValue:code forKey:CodeKey];
    [parameters setValue:@([amount intValue]) forKey:AmountKey];
    
    NSLog(@"%@", parameters);
    
    [self.manager POST:PromoCode parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.successCase(responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleError:operation.responseObject];
    }];

}

- (void)handleError:(NSDictionary *)responseObj {
    if (responseObj[@"errorMessage"]){
        self.failureCase(responseObj[ErrorCodeKey],responseObj[@"errorMessage"]);
    } else if(responseObj[ErrorKey][ErrorCodeKey]) {
        self.failureCase(responseObj[ErrorKey][ErrorCodeKey],responseObj[ErrorKey][ErrorMessageKey]);
    } else{
        self.failureCase(nil, @"Erro ao se comunicar com o servidor");
    }
}

@end
