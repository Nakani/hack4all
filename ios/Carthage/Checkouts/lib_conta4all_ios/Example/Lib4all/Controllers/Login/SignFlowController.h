//
//  SignFlowController.h
//  Example
//
//  Created by Cristiano Matte on 22/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowController.h"

@interface SignFlowController : NSObject  <FlowController>

@property BOOL isLogin;
@property BOOL requirePaymentData;

@property BOOL requireFullName;
@property BOOL requireCpfOrCnpj;
@property BOOL requireBirthdate;

@property (copy, nonatomic) NSString* maskedPhoneNumber;
@property (copy, nonatomic) NSString* maskedEmailAddress;
@property (copy, nonatomic) NSString* enteredFullName;
@property (copy, nonatomic) NSString* enteredPhoneNumber;
@property (copy, nonatomic) NSString* enteredEmailAddress;
@property (copy, nonatomic) NSString* enteredPassword;
@property (copy, nonatomic) NSString* enteredChallenge;
@property (copy, nonatomic) NSString* selectedCardId;
@property (copy, nonatomic) NSString* validatedNumber;
@property (copy, nonatomic) NSString* validatedEmail;
@property (copy, nonatomic) NSString* validatedCpf;
@property (assign) BOOL isPhoneValidated;
@property (assign) BOOL isEmailValidated;
@property (assign) BOOL isCpfValidated;
@property (assign) BOOL skipPayment;
@property (assign) BOOL isSocialLogin;
@property (assign) BOOL askCvv;

@property (nonatomic) NSMutableDictionary* socialSignInData;
@property (nonatomic) NSMutableDictionary* accountData;

@property (copy, nonatomic) void (^loginCompletion)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken);
@property (copy, nonatomic) void (^loginWithPaymentCompletion)(NSString *sessionToken, NSString *cardId, NSString *cvv);


@property NSArray * acceptedPaymentTypes;
@property NSArray * acceptedBrands;

- (instancetype)initWithAcceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands;
-(void)finishSignUpWithViewController:(UIViewController *)viewController;
@end
