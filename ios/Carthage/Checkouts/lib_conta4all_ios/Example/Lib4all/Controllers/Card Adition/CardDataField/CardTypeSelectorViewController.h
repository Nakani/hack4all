//
//  CardTypeSelectorViewController.h
//  Example
//
//  Created by Adriano Soares on 25/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignFlowController.h"
#import "CardAdditionFlowController.h"

@interface CardTypeSelectorViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) CardAdditionFlowController *flowController;

- (void)setAccceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands;

@end
