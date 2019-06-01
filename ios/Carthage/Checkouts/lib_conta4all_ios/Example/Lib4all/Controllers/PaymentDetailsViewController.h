//
//  PaymentDetailsViewController.h
//  Example
//
//  Created by 4all on 12/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallbacksDelegate.h"
#import "Transaction.h"

@interface PaymentDetailsViewController : UIViewController<CallbacksDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Transaction *transactionInfo;
@property (assign) BOOL isMerchantOffline;
@property (copy) void (^didFinishPayment)();

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end



