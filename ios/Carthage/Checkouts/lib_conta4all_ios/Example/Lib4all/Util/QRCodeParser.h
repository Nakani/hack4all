//
//  QRCodeParser.h
//  Example
//
//  Created by 4all on 24/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@interface QRCodeParser : NSObject

-(NSMutableDictionary *)generateDictionaryFromQRContent:(NSString *)contentQrCode;
-(Transaction *)parseToTransaction:(NSString *)contentQrCode;


@end
