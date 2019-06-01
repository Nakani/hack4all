//
//  PrePaidServices.h
//  Example
//
//  Created by Adriano Soares on 14/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface PrePaidServices : NSObject

typedef NS_ENUM(NSInteger, StatementSource) {
    StatementSourceAll,
    StatementSourceIncoming,
    StatementSourceOutgoing,
    
};

typedef NS_ENUM(NSInteger, TransactionPayMode) {
    TransactionPayModeCredit = 1,
    TransactionPayModeDebit,
    TransactionPayModePaymentSlip,
    TransactionPayModeAutoDebit,
    TransactionPayModeCheckingAccount
};

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *balanceType;
@property (copy) void (^successCase)(id data);
@property (copy) void (^failureCase)(NSString *errorID, NSString * errorMessage);


- (void) balance;

- (void) listStatements:(StatementSource)source ;
- (void) listStatements:(StatementSource)source before:(double)lastCreatedAt ;
- (void) paymentCashIn:(double)lastCreatedAt;
- (void) createPaymentCashIn:(double)amount payMode:(TransactionPayMode)payMode receiverCpf:(NSString *)cpf receiverPhoneNumber:(NSString *)phoneNumber description:(NSString *)description cardId:(NSString *)cardId password:(NSString * _Nullable)password;
- (void) getSummary:(double) after;
- (void) p2pTransferToId:(NSString *)destinationIdentifier amout:(NSNumber *)amount description:(NSString *)description password:(NSString *)password destinationCpf:(NSString *)cpf;

@end
