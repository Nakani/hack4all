//
//  PPCreatePaymentSlipViewController.h
//  Example
//
//  Created by Adriano Soares on 27/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPaymentSlipsViewController.h"

@interface PPCreatePaymentSlipViewController : UIViewController

@property double fee;
@property double dueDays;
@property (weak, nonatomic) PPPaymentSlipsViewController *parentVC;

@end
