//
//  LoyaltyServices.h
//  Example
//
//  Created by Natanael Ribeiro on 15/08/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Lib4allPreferences.h"

@interface LoyaltyServices : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (copy) void (^successCase)(id data);
@property (copy) void (^failureCase)(NSString *errorID, NSString * errorMessage);

-(id)init;
-(void)promoCode:(NSString *)code withTransactionId:(NSString * _Nullable)transactionId orMerchantId:(NSString * _Nullable)merchantId andAmount:(NSNumber *_Nonnull)amount;

@end
