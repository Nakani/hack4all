//
//  PPPaymentSlipsViewController.h
//  Example
//
//  Created by Luciano Bohrer on 22/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTabBarViewController.h"
#import "DetailsManager.h"


@interface PPPaymentSlipsViewController : UIViewController

@property MDTabBarViewController *tabBarViewController;
@property double fee;
@property double dueDays;

- (void) loadData;
- (void) showReceiptOfType:(ReceiptType)type withData:(NSDictionary *)receiptData;


@end
