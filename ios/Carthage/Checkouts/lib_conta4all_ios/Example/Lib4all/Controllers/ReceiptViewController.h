//
//  ReceiptViewController.h
//  Example
//
//  Created by 4all on 30/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "Loyalty.h"

@interface ReceiptViewController : UIViewController

@property (nonatomic, strong) Loyalty *loyaltyInfo;
@property (nonatomic, strong) Transaction *transactionInfo;
@property (nonatomic, strong) NSString *discountAmount;
@property (nonatomic, strong) NSString *finalTotalAmount;
@property BOOL isPaymentToken;
@property NSString *paymentTokenInstallmentParcel;
@property float paymentTokenInstallmentValue;
@property (copy) void (^didFinishPayment)();

@end
