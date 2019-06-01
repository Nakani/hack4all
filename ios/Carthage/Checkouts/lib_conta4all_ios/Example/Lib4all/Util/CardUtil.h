//
//  CardUtil.h
//  Example
//
//  Created by Cristiano Matte on 21/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CardType) {
    CardTypeCredit = 1,
    CardTypeDebit = 2,
    CardTypeCreditAndDebit = 3,
    CardTypePatRefeicao = 4,
    CardTypePatAlimentacao = 5
};

typedef NS_ENUM(NSInteger, CardBrand) {
    CardBrandVisa = 1,
    CardBrandMastercard = 2,
    CardBrandDiners = 3,
    CardBrandElo = 4,
    CardBrandAmex = 5,
    CardBrandDiscover = 6,
    CardBrandAura = 7,
    CardBrandJCB = 8,
    CardBrandHiper = 9,
    CardBrandMaestro = 10,
    CardBrandFourAll = 11,
    CardBrandTicket = 12,
    NumOfBrands = 13
};

@interface CardUtil : NSObject

+ (CardBrand)getBrandWithCardNumber:(NSString *)cardNumber;

@end
