//
//  NSString+Mask.m
//  Example
//
//  Created by Cristiano Matte on 14/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

@implementation NSString (Mask)

- (NSString *)stringByApplyingMask:(NSString *)mask maskCharacter:(char)maskCharacter {
    NSMutableString *maskedString = [[NSMutableString alloc] initWithString:@""];
    
    int maskIterator = 0;
    int stringIterator = 0;
    
    while (stringIterator < self.length && maskIterator < mask.length) {
        if ([mask characterAtIndex:maskIterator] == maskCharacter) {
            [maskedString appendFormat:@"%c", [self characterAtIndex:stringIterator]];
            stringIterator++;
        } else {
            [maskedString appendFormat:@"%c", [mask characterAtIndex:maskIterator]];
        }
        
        maskIterator++;
    }
    
    return maskedString;
}

@end
