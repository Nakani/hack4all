//
//  DetailsManager.h
//  Example
//
//  Created by Luciano Acosta on 12/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ReceiptType) {
    ReceiptTypeTransaction,
    ReceiptTypeDeposit,
    ReceiptTypeTransfer,
    ReceiptTypeWithdraw,
    ReceiptTypeCashInPaymentSlip,
    ReceiptTypeCashback
};
@interface DetailsManager : NSObject

-(UIView *)getConfiguredViewByType:(ReceiptType)receiptType withDataToFill:(NSDictionary *)data;

@end
