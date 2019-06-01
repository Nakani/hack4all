//
//  LayoutManager.h
//  Example
//
//  Created by Luciano Acosta on 27/04/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutManager : NSObject

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *darkBackgroundColor;
@property (nonatomic, strong) UIColor *red;
@property (nonatomic, strong) UIColor *errorColor;
@property (nonatomic, strong) UIColor *darkerGray;
@property (nonatomic, strong) UIColor *darkGray;
@property (nonatomic, strong) UIColor *mediumGray;
@property (nonatomic, strong) UIColor *lightGray;
@property (nonatomic, strong) UIColor *darkGreen;
@property (nonatomic, strong) UIColor *lightGreen;
@property (nonatomic, strong) UIColor *gradientColor;
@property (nonatomic, strong) UIColor *mainButtonColor;
@property (nonatomic, strong) UIColor *mainButtonGradientColor;
@property (nonatomic, strong) UIColor *lightFontColor;
@property (nonatomic, strong) UIColor *darkFontColor;
@property (nonatomic, strong) UIColor *debitStatementColor;
@property (nonatomic, strong) UIColor *creditStatementColor;
@property (nonatomic, strong) UIColor *paymentMethodHeaderColor;
@property (nonatomic, strong) UIColor *receiptColor;
@property (nonatomic, strong) UIColor *balanceIconColor;
@property (nonatomic, strong) UIColor *transactionsPaymentSlipColor;
@property (nonatomic, strong) UIColor *tokenProgressColor;
@property UIBarStyle barStyle;


@property CGFloat            miniFontSize;
@property CGFloat            midFontSize;
@property CGFloat            regularFontSize;
@property CGFloat            titleFontSize;
@property CGFloat            subTitleFontSize;
@property CGFloat            navigationTitleFontSize;

//Subscription status color
@property (nonatomic, strong) UIColor *status_undefined;
@property (nonatomic, strong) UIColor *status_paidOut;
@property (nonatomic, strong) UIColor *status_awaitingPayment;
@property (nonatomic, strong) UIColor *status_paymentDenied;
@property (nonatomic, strong) UIColor *status_canceled;
@property (nonatomic, strong) UIColor *status_unApprovedPayment;
@property (nonatomic, strong) UIColor *status_awaitingReversal;
@property (nonatomic, strong) UIColor *status_reversal;
@property (nonatomic, strong) UIColor *status_awaitingcontested;
@property (nonatomic, strong) UIColor *status_contested;
@property (nonatomic, strong) UIColor *status_processing;
@property (nonatomic, strong) UIColor *status_unApprovedReversal;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) NSString *boldFontName;





+ (instancetype)sharedManager;
- (UIFont *)fontWithSize:(CGFloat)size;
- (UIFont *)boldFontWithSize:(CGFloat)size;

@end
