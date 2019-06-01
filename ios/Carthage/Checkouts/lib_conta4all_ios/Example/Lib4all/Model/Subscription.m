//
//  Subscription.m
//  Example
//
//  Created by Cristiano Matte on 31/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Subscription.h"
#import "ServicesConstants.h"

@implementation Subscription

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.subscriptionID = dictionary[SubscriptionIDKey];
        self.recurringAmount = dictionary[RecurringAmountKey];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        self.nextPaymentDate = [dateFormatter dateFromString:dictionary[NextPaymentDateKey]];
        
        self.status = dictionary[StatusKey];
        
        
        self.merchant = [[Merchant alloc] initWithJSONDictionary:dictionary[MerchantInfoKey]];
    }
    
    return self;
}

@end
