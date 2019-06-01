//
//  Transaction.m
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Transaction.h"
#import "ServicesConstants.h"
#import "Lib4allPreferences.h"
#import "Lib4all.h"

@implementation Transaction

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.transactionID = dictionary[TransactionIDKey];
        
        if (![dictionary[SubscriptionIDKey] isEqual:[NSNull null]]) {
            self.subscriptionID = dictionary[SubscriptionIDKey];
        }
        
        self.amount = dictionary[AmountKey];
        self.status = dictionary[StatusKey];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = DateFormat;
        
        self.createdAt = [dateFormatter dateFromString:dictionary[CreatedAtKey]];
        self.paidAt = [dateFormatter dateFromString:dictionary[PaidAtKey]];
        id installments = dictionary[@"installments"];
        if (installments && installments != [NSNull null]) {
        self.installments = installments;
        }
        

        self.merchant = [[Merchant alloc] initWithJSONDictionary:dictionary[MerchantInfoKey]];
    }
    
    return self;
}

-(NSArray *)getAcceptedModes{
    NSMutableArray *arrayAcceptedModes = [[NSMutableArray alloc] init];
    
    int length = (int)self.acceptedModes.length;
    
    for (int i = 0; i < length; i++) {
        
        switch (i) {
            case 0:
                if ([self.acceptedModes characterAtIndex:i] == '1') {
                    [arrayAcceptedModes addObject:@(Credit)];
                }
                break;
            case 1:
                if ([self.acceptedModes characterAtIndex:i] == '1') {
                    [arrayAcceptedModes addObject:@(Debit)];
                }
                break;
            case 2:
                if ([self.acceptedModes characterAtIndex:i] == '1'){
                    [arrayAcceptedModes addObject:@(CheckingAccount)];
                }
                break;
            case 3:
                if ([self.acceptedModes characterAtIndex:i] == '1'){
                    [arrayAcceptedModes addObject:@(PatRefeicao)];
                }
                break;
            case 4:
                if ([self.acceptedModes characterAtIndex:i] == '1'){
                    [arrayAcceptedModes addObject:@(PatAlimentacao)];
                }
                break;
                    default:
                break;
        }
    }

    if ([arrayAcceptedModes containsObject:@(Credit)] && [arrayAcceptedModes containsObject:@(Debit)]) {
        [arrayAcceptedModes addObject:@(PaymentModeCreditAndDebit)];
    }
    
    if (arrayAcceptedModes.count == 0) {
        [arrayAcceptedModes addObjectsFromArray:Lib4all.acceptedPaymentTypes];
    }
    
    return arrayAcceptedModes;
}

-(NSArray *)getAcceptedBrands{
    NSMutableArray *arrayAcceptedBrands = [[NSMutableArray alloc] init];
    int length = (int)self.acceptedBrands.length;
    
    for (int i = 1; i < length+1; i++) {
        
        switch (i) {
            //VISA
            case 1:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandVisa)];
                }
                break;
            //MASTERCARD
            case 2:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandMastercard)];
                }
                break;
            //DINERS
            case 3:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandDiners)];
                }
                break;
            //ELO
            case 4:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandElo)];
                }
                break;
            //AMEX
            case 5:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandAmex)];
                }
                break;
            //DISCOVER
            case 6:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandDiscover)];
                }
                break;
            //AURA
            case 7:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandAura)];
                }
                break;
            //JCB
            case 8:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandJCB)];
                }
                break;
            //HIPERCARD
            case 9:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandHiper)];
                }
                break;
            //MAESTRO
            case 10:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandMaestro)];
                }
                break;
            //TICKET
            case 11:
                if ([self.acceptedBrands characterAtIndex:i-1] == '1') {
                    [arrayAcceptedBrands addObject:@(CardBrandTicket)];
                }
                break;
            default:
                break;
        }
    }
    
    if (arrayAcceptedBrands.count == 0) {
        [arrayAcceptedBrands addObjectsFromArray:Lib4all.acceptedBrands];
    }
    
    return arrayAcceptedBrands;
}

@end
