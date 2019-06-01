//
//  CpfCnpjUtil.h
//  Example
//
//  Created by Cristiano Matte on 14/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpfCnpjUtil : NSObject

+ (NSString *)getClearCpfOrCnpjNumberFromMaskedNumber:(NSString *)number;
+ (BOOL)isValidCpfOrCnpj:(NSArray *)cpfOrCnpj;
+ (BOOL)isValidCpfNumber:(NSArray *)cpfArray;
+ (BOOL)isValidCnpjNumber:(NSArray *)cnpjArray;

@end
