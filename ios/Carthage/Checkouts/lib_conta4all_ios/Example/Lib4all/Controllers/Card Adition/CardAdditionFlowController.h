//
//  CardAdditionFlowController.h
//  Example
//
//  Created by Cristiano Matte on 01/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowController.h"
#import "CardUtil.h"
#import "CardIO.h"

@interface CardAdditionFlowController : NSObject <FlowController, CardIOPaymentViewControllerDelegate>

@property (copy, nonatomic) void (^loginWithPaymentCompletion)(NSString *sessionToken, NSString *cardId, NSString *cvv);
@property (copy, nonatomic) void (^loginCompletion)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken);

@property NSArray * acceptedPaymentTypes;
@property NSArray * acceptedBrands;

@property CardType selectedType;

@property NSString *cardNumber;
@property NSString *cardNumberFromPhoto;
@property NSString *cardName;
@property NSString *expirationDate;
@property NSString *CVV;

@property NSString *enteredCardNumber;
@property NSString *enteredCardName;
@property NSString *enteredExpirationDate;
@property NSString *enteredCVV;
@property (strong, nonatomic) NSMutableArray *requiredFields;

@property BOOL isFromAddCardMenu;
@property BOOL isCardOCREnabled;

- (instancetype)initWithAcceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands;
-(void)goBackWithErrors:(NSArray *)errors from:(UIViewController *)viewController;
@end
