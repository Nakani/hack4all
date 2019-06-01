//
//  CardUtil.m
//  Example
//
//  Created by Cristiano Matte on 21/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CardUtil.h"

@implementation CardUtil

+ (CardBrand)getBrandWithCardNumber:(NSString *)cardNumber {
    NSRegularExpression *regex;
    
    // Remove todo caractere não numérico do número do cartão
    cardNumber = [[cardNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    //Verifica se o cartão é da bandeira Hipercard
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(384100|384140|384160|606282)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandHiper;
    }
    
    // Verifica se o cartão é da bandeira elo
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(636368|636369|438935|504175|451416|636297|5067|4576|4011|506699)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandElo;
    }
    
    // Verifica se o cartão é da bandeira JCB
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(3528|3529|353|354|355|356|357|358)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandJCB;
    }
    
    // Verifica se o cartão é da bandeira Discover
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(6011|644|645|646|647|648|649|65)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandDiscover;
    }
    
    // Verifica se o cartão é da bandeira Diners
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(300|301|302|303|304|305|3095|36|38|39)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandDiners;
    }
    
    // Verifica se o cartão é da bandeira Amex
    regex = [[NSRegularExpression alloc] initWithPattern:@"^(34|37)[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandAmex;
    }
    
    // Verifica se o cartão é da bandeira Aura
    regex = [[NSRegularExpression alloc] initWithPattern:@"^50[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandAura;
    }
    
    // Verifica se o cartão é da bandeira Visa
    regex = [[NSRegularExpression alloc] initWithPattern:@"^4[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandVisa;
    }
    
    // Verifica se o cartão é da bandeira Mastercard
    regex = [[NSRegularExpression alloc] initWithPattern:@"^5[0-9]+$"
                                                 options:0
                                                   error:nil];
    if ([regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, [cardNumber length])] > 0) {
        return CardBrandMastercard;
    }
    
    return 0;
}

@end
