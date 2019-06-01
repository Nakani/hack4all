//
//  Transaction.h
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Merchant.h"
#import "CreditCard.h"

@interface Transaction : NSObject

@property (nonatomic, copy) NSString *transactionID;
@property (nonatomic, copy) NSString *subscriptionID;
@property (nonatomic, copy) NSNumber *amount;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *paidAt;
@property (nonatomic, strong) Merchant *merchant;
@property (nonatomic, strong) CreditCard *card;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *acceptedModes;
@property (nonatomic, copy) NSString *acceptedBrands;
@property (nonatomic, copy) NSString *blob;
@property (assign) BOOL isCancellation;
@property NSNumber *installments;
@property (assign) BOOL acceptsPromoCodes;
@property (assign) BOOL acceptsOfflinePayment;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSArray *)getAcceptedModes;
- (NSArray *)getAcceptedBrands;

@end
