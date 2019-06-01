//
//  TransactionDetailsViewController.h
//  Example
//
//  Created by Cristiano Matte on 03/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

@interface TransactionDetailsViewController : UIViewController

@property BOOL showAsSubscriptionDetails;
@property (strong, nonatomic) Transaction *transaction;
@property (copy) void (^closeViewControllerBlock)();

@end
