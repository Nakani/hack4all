//
//  PPBalanceViewController.h
//  Example
//
//  Created by Adriano Soares on 09/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsManager.h"

@interface PPBalanceViewController : UIViewController

-(void)showReceiptOfType:(ReceiptType)type withData:(NSDictionary *)receiptData;


@end
