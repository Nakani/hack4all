//
//  NSData+AES.h
//  Example
//
//  Created by Cristiano Matte on 20/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES256EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES256DecryptedDataWithKey:(NSString *)key;

@end
