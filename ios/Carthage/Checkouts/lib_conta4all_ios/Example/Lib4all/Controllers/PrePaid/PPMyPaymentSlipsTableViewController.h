//
//  PPMyPaymentSlipsTableViewController.h
//  Example
//
//  Created by Luciano Bohrer on 22/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPaymentSlipsViewController.h"

@interface PPMyPaymentSlipsTableViewController : UIViewController

@property (weak, nonatomic) PPPaymentSlipsViewController *parentVC;

- (void) loadData;
@end
