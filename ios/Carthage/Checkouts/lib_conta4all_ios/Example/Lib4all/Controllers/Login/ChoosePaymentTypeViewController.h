//
//  ChoosePaymentTypeViewController.h
//  Example
//
//  Created by Cristiano Matte on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignFlowController.h"
#import "CallbacksDelegate.h"

@interface ChoosePaymentTypeViewController : UIViewController <CallbacksDelegate>

@property (strong, nonatomic) SignFlowController *signFlowController;

@end
