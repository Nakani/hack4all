//
//  PPTransactionsTableViewController.h
//  Example
//
//  Created by Adriano Soares on 08/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPBalanceViewController.h"
typedef NS_ENUM(NSInteger, PPTransactionFilter)
{
    PPTransactionFilterAll,
    PPTransactionFilterIn,
    PPTransactionFilterOut

};

@interface PPTransactionsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property PPTransactionFilter transactionFilter;
@property (weak) PPBalanceViewController *rootViewController;

@property (nonatomic, copy) void (^didScroll)(UIScrollView*);


- (void) loadData;

@end
