//
//  Lib4allPreferences.h
//  Example
//
//  Created by Cristiano Matte on 21/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ComponentViewController;

typedef NS_ENUM(NSInteger, PaymentMode) {
    PaymentModeCredit = 1,
    PaymentModeDebit = 2,
    PaymentModeCreditAndDebit = 3,
    PaymentModeChecking = 5,
    PaymentModePatRefeicao = 6,
    PaymentModePatAlimentacao = 7,
};


typedef NS_ENUM(NSInteger, PaymentType) {
    Credit = 0,
    Debit = 1,
    CheckingAccount = 2,
    PatRefeicao = 3,
    PatAlimentacao = 4,
    NumOfTypes = 5
};

typedef NS_ENUM(NSInteger, Environment) {
    EnvironmentTest = 1,
    EnvironmentHomologation = 2,
    EnvironmentProduction = 3
};

typedef NS_ENUM(NSInteger, ProfileOption) {
    ProfileOptionReceipt = 1,
    ProfileOptionSubscriptions = 2,
    ProfileOptionUserData = 3,
    ProfileOptionUserCards = 4,
    ProfileOptionSettings = 5,
    ProfileOptionHelp = 6,
    ProfileOptionAbout = 7,
    ProfileOptionFamily = 8,
    ProfileOptionPayMethods = 9
};

typedef NS_ENUM(NSInteger, PrepaidOption) {
    PrepaidOptionBalance,
    PrepaidOptionToken,
    PrepaidOptionTransfer,
    PrepaidOptionDeposit,
    PrepaidOptionCashOut

};
typedef NS_ENUM(NSInteger, SocialMedia) {
    SocialMediaFacebook = 1,
    SocialMediaGoogle = 2
};

@interface Lib4allPreferences : NSObject

@property Environment environment;
@property BOOL requireFullName;
@property BOOL requireCpfOrCnpj;
@property BOOL requireBirthdate;

//@property PaymentMode acceptedPaymentMode; esta propriedade não será mais usada, foi substituida por acceptedPaymentTypes, que é mais dinâmica
@property NSArray * acceptedPaymentTypes;
@property (copy, nonatomic) NSURL *termsOfServiceURL;
@property (copy, nonatomic) NSURL *appWebsiteURL;
@property (copy, nonatomic) NSURL *appContactURL;
@property (copy, nonatomic) NSSet *acceptedBrands;
@property (copy, nonatomic) NSString *applicationID;
@property (copy, nonatomic) NSString *trackingID;
@property (copy, nonatomic) NSString *applicationVersion;
@property (copy, nonatomic) NSString *chatDepartment;
@property (copy, nonatomic) NSString *balanceType;
@property (copy, nonatomic) NSString *balanceTypeFriendlyName;
@property (copy, nonatomic) NSString *wizardAppName;
@property (copy, nonatomic) NSString *thirdPartyLoginAppName;
@property (copy, nonatomic) NSString *tokenScreenTitle;
@property BOOL isBalanceFloatingButtonEnabled;
@property BOOL isEnabledTransferWithCreditCard;
@property BOOL isCardOCREnabled;
@property BOOL registerWithoutCardAddition;
@property UIImage *prepaidAccountImage;
@property UIImage *appIcon;
@property (strong, nonatomic) ComponentViewController *currentVisibleComponent;
@property (strong, nonatomic) NSMutableDictionary *requiredAntiFraudItems;
@property (strong, nonatomic) NSDictionary *customerData;
@property BOOL hideSummaryButton;

@property (strong, nonatomic) id analytics;

@property (strong, nonatomic) UIColor *loaderColor;

@property (copy) BOOL(^isNotificationHabilitatedBlock)();
@property (copy) void(^didChangeNotificationSwitchBlock)(BOOL isOn);

+ (instancetype)sharedInstance;

@end
