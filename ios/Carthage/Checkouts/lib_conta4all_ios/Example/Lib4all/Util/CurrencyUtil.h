//
//  CurrencyUtil.h
//  Example
//
//  Created by Adriano Soares on 27/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyUtil : NSObject

+ (NSString *) currencyFormatter:(double) amount;
+ (NSString *) cleanCurrency: (NSString *) currency;
+ (double) currencyToDouble: (NSString *) currency;

@end
