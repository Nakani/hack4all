//
//  NSSting+Mask.h
//  Example
//
//  Created by Cristiano Matte on 14/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Mask)

- (NSString *)stringByApplyingMask:(NSString *)mask maskCharacter:(char)maskCharacter;

@end
