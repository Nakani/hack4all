//
//  CpfCnpjUtil.m
//  Example
//
//  Created by Cristiano Matte on 14/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CpfCnpjUtil.h"

@implementation CpfCnpjUtil

+ (NSString *)getClearCpfOrCnpjNumberFromMaskedNumber:(NSString *)number {
    return [[[number stringByReplacingOccurrencesOfString:@"." withString:@""]
             stringByReplacingOccurrencesOfString:@"-" withString:@""]
            stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

+ (BOOL)isValidCpfOrCnpj:(NSArray *)cpfOrCnpj {
    if (cpfOrCnpj == nil) {
        return NO;
    }
    
    BOOL isCpf = cpfOrCnpj.count <= 11;
    BOOL fieldValid;
    
    if (isCpf) {
        fieldValid = [CpfCnpjUtil isValidCpfNumber:cpfOrCnpj];
    } else {
        fieldValid = [CpfCnpjUtil isValidCnpjNumber:cpfOrCnpj];
    }
    
    return fieldValid;
}

+ (BOOL)isValidCpfNumber:(NSArray *)cpfArray {
    if (cpfArray.count != 11) {
        return NO;
    }
    
    int cpf[cpfArray.count];
    for (int i = 0; i < cpfArray.count; i++) {
        NSNumber *number = (NSNumber *)[cpfArray objectAtIndex:i];
        
        if (number == nil) {
            return NO;
        }
        
        cpf[i] = [number intValue];
    }
    
    int checksum = 0;
    
    // Calcula o primeiro dígito verificador
    checksum = ((cpf[0] * 10) + (cpf[1] * 9) + (cpf[2] * 8) + (cpf[3] * 7) + (cpf[4] * 6) +
                (cpf[5] * 5) + (cpf[6] * 4) + (cpf[7] * 3) + (cpf[8] * 2)) % 11;
    checksum = 11 - checksum > 9 ? 0 : 11 - checksum;
    
    if (checksum != cpf[9]) {
        return NO;
    }
    
    // Calcula o segundo dígito verificador
    checksum = ((cpf[0] * 11) + (cpf[1] * 10) + (cpf[2] * 9) + (cpf[3] * 8) + (cpf[4] * 7) +
                (cpf[5] * 6) + (cpf[6] * 5) + (cpf[7] * 4) + (cpf[8] * 3) + (cpf[9] * 2)) % 11;
    checksum = 11 - checksum > 9 ? 0 : 11 - checksum;
    
    if (checksum != cpf[10]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isValidCnpjNumber:(NSArray *)cnpjArray {
    if (cnpjArray.count != 14) {
        return NO;
    }
    
    int cnpj[cnpjArray.count];
    for (int i = 0; i < cnpjArray.count; i++) {
        NSNumber *number = (NSNumber *)[cnpjArray objectAtIndex:i];
        
        if (number == nil) {
            return NO;
        }
        
        cnpj[i] = [number intValue];
    }
    
    int checksum = 0;
    
    // Calcula o primeiro dígito verificador
    checksum = ((cnpj[0] * 5) + (cnpj[1] * 4) + (cnpj[2] * 3) + (cnpj[3] * 2) +
                (cnpj[4] * 9) + (cnpj[5] * 8) + (cnpj[6] * 7) + (cnpj[7] * 6) +
                (cnpj[8] * 5) + (cnpj[9] * 4) + (cnpj[10] * 3) + (cnpj[11] * 2)) % 11;
    checksum = 11 - checksum > 9 ? 0 : 11 - checksum;
    
    if (checksum != cnpj[12]) {
        return NO;
    }
    
    // Calcula o segundo dígito verificador
    checksum = ((cnpj[0] * 6) + (cnpj[1] * 5) + (cnpj[2] * 4) + (cnpj[3] * 3) +
                (cnpj[4] * 2) + (cnpj[5] * 9) + (cnpj[6] * 8) + (cnpj[7] * 7) + (cnpj[8] * 6) +
                (cnpj[9] * 5) + (cnpj[10] * 4) + (cnpj[11] * 3) + (cnpj[12] * 2)) % 11;
    checksum = 11 - checksum > 9 ? 0 : 11 - checksum;
    
    if (checksum != cnpj[13]) {
        return NO;
    }
    
    return YES;
}

@end
