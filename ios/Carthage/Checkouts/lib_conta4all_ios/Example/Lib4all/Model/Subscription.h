//
//  Subscription.h
//  Example
//
//  Created by Cristiano Matte on 31/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Merchant.h"
#import "CreditCard.h"

@interface Subscription : NSObject

@property (nonatomic, copy) NSString *subscriptionID;
@property (nonatomic, copy) NSNumber *recurringAmount;
@property (nonatomic, copy) NSDate *nextPaymentDate;
@property (nonatomic, strong) Merchant *merchant;
@property (nonatomic, copy) NSNumber *status;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
