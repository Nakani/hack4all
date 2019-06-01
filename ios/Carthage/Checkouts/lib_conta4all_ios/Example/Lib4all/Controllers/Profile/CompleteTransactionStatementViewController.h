//
//  CompleteTransactionStatementViewController.h
//  Example
//
//  Created by Cristiano Matte on 28/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TransactionsPeriod) {
    TransactionsPeriodNone = 0,
    TransactionsPeriod3Days = 1,
    TransactionsPeriod30Days = 2,
    TransactionsPeriod90Days = 3,
    TransactionsPeriod365Days = 4,
    TransactionsPeriodAll = 5
};

@interface CompleteTransactionStatementViewController : UIViewController

@property (strong, atomic) NSMutableArray *downloadedTransactions;
@property (nonatomic) TransactionsPeriod currentDownloadedTransactionsPeriod;

@end
