//
//  NSData+AES.m
//  Example
//
//  Created by Cristiano Matte on 20/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES)

- (NSData *)AES256EncryptedDataWithKey:(NSString *)key {
    return [self AES256Operation:kCCEncrypt key:key];
}

- (NSData *)AES256DecryptedDataWithKey:(NSString *)key {
    return [self AES256Operation:kCCDecrypt key:key];
}

- (NSData *)AES256Operation:(CCOperation)operation key:(NSString *)key {
    // A chave deve ter sempre 256 bits, com padding de 0 ao final se for menor
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    // Converte a key para NSData e copia seus bytes para o keyPtr
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:0];
    memcpy(keyPtr, keyData.bytes, keyData.length);
    
    // Aloca o buffer para os dados a serem criptografados ou descriptografados
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

@end
