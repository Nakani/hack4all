//
//  CallbacksDelegate.h
//  Example
//
//  Created by 4all on 29/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lib4allPreferences.h"

@protocol CallbacksDelegate <NSObject>
@optional
- (BOOL) callbackShouldPerformButtonAction;
- (void) callbackLogin:(NSString *)sessionToken email:(NSString *)email phone:(NSString *)phone;
- (void) callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode __deprecated;
- (void) callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode cvv:(NSString *)cvv;
- (void) callbackPosVenda:(NSString *)email telefone:(NSString *)telefone status:(NSString *) status dateTime:(NSString *)dateTime;
- (void) socialLoginDidFinishWithToken:(NSString *)token fromSocialMedia:(SocialMedia)socialMedia;
- (void) didLoadPaymentType;

@end
