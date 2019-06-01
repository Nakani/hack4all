//
//  CreditCard.m
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CreditCard.h"
#import "ServicesConstants.h"

@implementation CreditCard

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.type = [dictionary[CardTypeKey] intValue];
        self.cardId = dictionary[CardIDKey];
        self.brandId = dictionary[BrandIDKey];
        self.lastDigits = dictionary[LastDigitsKey];
        self.status = dictionary[StatusKey];
        self.isDefault = [dictionary[IsDefaultKey] boolValue];
        self.isShared = [dictionary[IsSharedKey] boolValue];
        self.bin = dictionary[BinKey];
        if (self.isShared) {
            self.sharedDetails = [dictionary[SharedDetailsKey] array];
        }
        
    }
    
    return self;
}

- (NSString *)getMaskedPan {
    return [NSString stringWithFormat:@"•••• •••• •••• %@",self.lastDigits];
}

- (BOOL) isProvider {
    if (!self.isShared) {
        return YES;
    } else if ([self.sharedDetails[0][@"provider"] boolValue]) {
        return YES;
    }
    return NO;
}

-(NSString *)getCardType {
    NSString *cardType;
    
    switch (_type) {
        case CardTypeDebit:
            cardType = @"DÉBITO";
            break;
        case CardTypeCredit:
            cardType = @"CRÉDITO";
            break;
        case CardTypeCreditAndDebit:
            cardType = @"CRÉDITO E DÉBITO";
            break;
        default:
            //VALIDAR COM UX:
            cardType = @"Tipo de cartão não reconhecido";
    }
    
    return cardType;
}


@end
