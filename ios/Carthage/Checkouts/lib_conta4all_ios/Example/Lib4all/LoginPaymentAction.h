//
//  MainButtonAction.h
//  Example
//
//  Created by 4all on 02/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallbacksDelegate.h"

@interface LoginPaymentAction : NSObject

@property (nonatomic, weak) id<CallbacksDelegate> delegate;
@property (nonatomic, strong) UIViewController *controller;

//Propridade a ser setada quando for pagamento com qrcode
@property BOOL isQrCodePayment;

-(void)callMainAction:(UIViewController *)controller delegate:(id<CallbacksDelegate>)delegate acceptedPaymentTypes: (NSArray*) paymentTypes acceptedBrands: (NSArray *) brands checkingAccount:(NSString *)checkingAccount;

@end
