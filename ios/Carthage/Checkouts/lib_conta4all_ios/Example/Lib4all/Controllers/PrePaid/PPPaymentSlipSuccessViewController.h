//
//  PPPaymentSlipSuccessViewController.h
//  Example
//
//  Created by Adriano Soares on 28/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPPaymentSlipSuccessViewController : UIViewController

@property NSString *paymentId;

@property double   amount;
@property NSString *expirationDate;
@property NSString *barCode;

@end
