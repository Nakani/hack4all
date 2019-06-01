//
//  CancellationDetailsViewController.h
//  Example
//
//  Created by Luciano Bohrer on 24/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

@interface CancellationDetailsViewController : UIViewController
@property (nonatomic, strong) Transaction *transactionInfo;
@property (copy) void (^didFinishPayment)();

@end
