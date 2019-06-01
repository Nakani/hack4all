//
//  ComponentViewController.h
//  Lib4all
//
//  Created by 4all on 3/29/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lib4allPreferences.h"
#import "CallbacksDelegate.h"

//@protocol CallbacksDelegate <NSObject>
//
//@optional
//- (BOOL) callbackShouldPerformButtonAction;
//- (void) callbackLogin:(NSString *)sessionToken email:(NSString *)email phone:(NSString *)phone;
//- (void) callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode;
//- (void) callbackPosVenda:(NSString *)email telefone:(NSString *)telefone status:(NSString *) status dateTime:(NSString *)dateTime;
//
//@end

@interface ComponentViewController : UIViewController

@property (nonatomic, strong) NSString *buttonTitleWhenNotLogged;
@property (nonatomic, strong) NSString *buttonTitleWhenLogged;
@property (nonatomic, weak) id<CallbacksDelegate> delegate;
@property BOOL requireFullName __deprecated;
@property BOOL requireCpfOrCnpj __deprecated;
//@property PaymentMode acceptedPaymentMode __deprecated;
@property (strong, nonatomic) NSString *termsOfServiceUrl __deprecated;
@property NSArray *acceptedPaymentTypes;
@property NSArray *acceptedBrands;
@property BOOL disabledCreditCardPayment;
@property BOOL isQrCodePayment;

- (id)init;
- (id)initWithAcceptedPaymentMode:(PaymentMode)paymentMode __deprecated_msg("Use initWithAcceptedPaymentTypes:(NSArray of PaymentType) andAcceptedBrands:(NSArray of CardBrand) instead.");
- (id)initWithAcceptedPaymentTypes:(NSArray *)arrayPaymentTypes andAcceptedBrands:(NSArray *)arrayBrands;

- (void)updateComponentViews;
-(void)callOnClick:(BOOL)isCheckingAccount;

@end
