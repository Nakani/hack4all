//
//  CurrencyUtil.m
//  Example
//
//  Created by Adriano Soares on 27/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CurrencyUtil.h"

@implementation CurrencyUtil

+ (NSString *) currencyFormatter:(double) amount {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *value = [formatter stringFromNumber: [NSNumber numberWithDouble:amount/100.0]];
    value = [value stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    return value;
}

+ (NSString *) cleanCurrency: (NSString *) currency {
    return [[currency componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

+ (double) currencyToDouble: (NSString *) currency {
    NSString *raw = [CurrencyUtil cleanCurrency:currency];
    return [raw doubleValue];
}

@end
