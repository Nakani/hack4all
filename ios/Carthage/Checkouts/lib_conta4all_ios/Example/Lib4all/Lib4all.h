//
//  Lib4all.h
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComponentViewController.h"
#import "CardComponentViewController.h"
#import "User.h"
#import "ProfileViewController.h"
#import "LoadingViewController.h"
#import "PopUpBoxViewController.h"
#import "Lib4allPreferences.h"
#import "CardUtil.h"
#import "Button4all.h"


//Umbrella header
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"
#import "AboutViewController.h"
#import "AccountCreatedViewController.h"
#import "AuxiliaryActionButton.h"
#import "BEMAnimationManager.h"
#import "BEMCheckBox.h"
#import "BEMPathManager.h"
#import "BaseNavigationController.h"
#import "BirthdateDataField.h"
#import "BlockedPasswordViewController.h"
#import "CPFDataField.h"
#import "CardAdditionWelcomeViewController.h"
#import "CardExpirationProtocol.h"
#import "CardFieldProtocol.h"
#import "CardFieldViewController.h"
#import "CardNameProtocol.h"
#import "CardNumberProtocol.h"
#import "CardSecurityCodeProtocol.h"
#import "CardTypeSelectorViewController.h"
#import "CardsTableViewController.h"
#import "ChallengeViewController.h"
#import "ChangeEmailAddressViewController.h"
#import "ChangeNameViewController.h"
#import "ChangePhoneNumberViewController.h"
#import "ChoosePaymentTypeViewController.h"
#import "CompleteDataViewController.h"
#import "CompleteTransactionStatementViewController.h"
#import "ConfirmationDialogViewController.h"
#import "CpfCnpjUtil.h"
#import "CreditCard.h"
#import "CreditCardsList.h"
#import "DataFieldProtocol.h"
#import "DataFieldViewController.h"
#import "DateUtil.h"
#import "FXKeychain.h"
#import "FamilyAdvancedTableViewController.h"
#import "FamilyBalanceDataField.h"
#import "FamilyConfirmViewController.h"
#import "FamilyContactViewController.h"
#import "FamilyDataFieldProtocol.h"
#import "FamilyDataFieldViewController.h"
#import "FamilyDetailsViewController.h"
#import "FamilyExpirationDateDataField.h"
#import "FamilyHourTableViewController.h"
#import "FamilyMaxTransactionsDataField.h"
#import "FamilyPerTransactionDataField.h"
#import "FamilyProfileTableViewController.h"
#import "FamilySetBalanceViewController.h"
#import "FamilyWeekDayTableViewController.h"
#import "ForgotPasswordViewController.h"
#import "GenericDataViewController.h"
#import "GradientView.h"
#import "HelpViewController.h"
#import "INTULocationManager.h"
#import "INTULocationManager+Internal.h"
#import "INTULocationRequest.h"
#import "INTULocationRequestDefines.h"
#import "Lib4allInfo.h"
#import "LocalizationFlowController.h"
#import "LocalizationPermissionViewController.h"
#import "LocalizationRequiredViewController.h"
#import "LocationManager.h"
#import "LoginPaymentAction.h"
#import "MainActionButton.h"
#import "Merchant.h"
#import "NSBundle+Lib4allBundle.h"
#import "NSData+AES.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "NameDataField.h"
#import "PasswordViewController.h"
#import "PaymentDetailsViewController.h"
#import "PaymentFlowController.h"
#import "PersistenceHelper.h"
#import "PinConfirmationViewController.h"
#import "PinViewController.h"
#import "Preferences.h"
#import "QRCodeMerchantOfflineViewController.h"
#import "QRCodeParser.h"
#import "QRCodeViewController.h"
#import "MyReachability.h"
#import "ReceiptViewController.h"
#import "SISUBirthdateDataField.h"
#import "SISUCPFDataField.h"
#import "SISUEmailDataField.h"
#import "SISUNameDataField.h"
#import "SISUPasswordDataField.h"
#import "SISUPasswordConfirmationDataField.h"
#import "SISUPhoneNumberDataField.h"
#import "SISUTokenSmsDataField.h"
#import "SMSTokenDelegate.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "SignWithSessionViewController.h"
#import "SimpleTransactionStatementViewController.h"
#import "Subscription.h"
#import "SubscriptionDetailsView.h"
#import "SubscriptionsViewController.h"
#import "SystemLocalizationRequiredViewController.h"
#import "TermsViewController.h"
#import "TokenTextField.h"
#import "TransactionDetailsViewController.h"
#import "UIAlertView+Error.h"
#import "UIButton+Color.h"
#import "UIColor+HexString.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "UIImage+Color.h"
#import "ErrorTextField.h"
#import "UIImage+Lib4all.h"
#import "UITextFieldMask.h"
#import "UIView+Gradient.h"
#import "UserAddress.h"
#import "UserDataViewController.h"
#import "WebViewController.h"
#import "WelcomeViewController.h"
#import "CancellationDetailsViewController.h"
#import "SocialContainerViewController.h"
#ifdef USE_FIREBASE
#import <Firebase/Firebase.h>
#endif
// MARK : - User state delegate


@protocol UserStateDelegate <NSObject>

@optional
- (void)userDidLogin;
- (void)userDidLogout;

@end

// MARK: - Lib4all

@interface Lib4all : NSObject

@property (strong, nonatomic) id<UserStateDelegate> userStateDelegate;

+ (instancetype)sharedInstance;

// MARK: - Métodos de classe de configuração da biblioteca

+ (void)setEnvironment:(Environment)environment;

+ (Environment)environment;

+ (void)setBalanceType:(NSString *)balanceType;

+ (NSString *)balanceType;

+ (void)setAppWebsiteUrl:(NSURL *)url;

+ (void)setAppContactUrl:(NSURL *)url;

+ (void)hideSummaryButton:(BOOL)hide;

+ (void)setBalanceTypeFriendlyName:(NSString *)balanceTypeFriendlyName;

+ (void)setWizardAppName:(NSString *)wizardAppName;

+ (NSString *)balanceTypeFriendlyName;

+ (void)setEnableTransferWithCreditCard:(BOOL)isEnabled;

+ (void)setThirdPartyLoginAppName:(NSString *)appName;

+ (NSString *)thirdPartyLoginAppName;

+ (void)setProductionEnvironment:(BOOL)isProductionEnvironment __deprecated;

+ (void)setAnalyticsTrackingId:(NSString *)trackingId;

+ (void)setAnalytics:(id) tracking;

+ (void)setApplicationID:(NSString *)applicationID;

+ (NSString *)applicationID;

+ (void)setApplicationVersion:(NSString *)applicationVersion;

+ (NSString *)applicationVersion;

+ (void)setRegisterWithoutCardAddition:(BOOL)registerWithoutCardAddition;

//métodos antigos

+ (void)setAcceptedPaymentMode:(PaymentMode)paymentMode __deprecated_msg("Use setAcceptedPaymentTypes:(NSArray of PaymentType) instead.");

+ (PaymentMode)acceptedPaymentMode __deprecated_msg("use (NSArray of PaymentType)acceptedPaymentTypes instead.");

//métodos novos:

+(void) setTokenScreenTitle:(NSString *)tokenScreenTitle;

+ (void) openAddCardScreenWithViewController:(UIViewController *)viewController;

+ (NSString *)getBlobForTefPayment:(NSString *)cardId tag:(NSString *)tag;

+ (void) validatePromocode:(NSString *)promocode transactionId:(NSString * _Nullable)transactionId merchantId:(NSString * _Nullable)merchantId amount:(NSNumber *_Nonnull) amount completion:(void (^_Nullable)(BOOL valid, NSNumber * _Nullable newAmount, NSNumber * _Nullable discountAmount, NSMutableDictionary * _Nullable loyalty, NSString * _Nullable message)) completion;

+ (void) validatePromocode:(NSString *)promocode transactionId:(NSString *)transactionId amount:(NSNumber *) amount completion:(void (^)(BOOL valid, NSNumber * newAmount, NSNumber * discountAmount, NSMutableDictionary * loyalty, NSString * message)) completion;

+ (void) setAcceptedPaymentTypes: (NSArray *) paymentTypes;

+ (NSArray *) acceptedPaymentTypes;

+ (void)setAcceptedBrands:(NSArray *)acceptedBrands;

+ (NSArray *)acceptedBrands;

+ (void)setRequireFullName:(BOOL)requireFullName;

+ (BOOL)requireFullName;

+ (void)setRequireCpfOrCnpj:(BOOL)requireCpfOrCnpj;

+ (void)setChatDepartment:(NSString*)department;

+ (BOOL)requireCpfOrCnpj;

+ (void)setRequireBirthdate:(BOOL)requireBirthdate;

+ (BOOL)requireBirthdate;

+ (void)setTermsOfServiceURL:(NSURL *)termsOfServiceURL;

+ (NSURL *)termsOfServiceURL;

+ (void)setCustomerData:(NSDictionary *)data;

+ (NSDictionary *)customerData;

+ (void)disableAntiFraudRuleForProperty:(NSString *)property;

+ (void)setButtonColor:(UIColor *)buttonColor andGradient:(UIColor * _Nullable)gradientColor;

+ (void)setLoaderColor:(UIColor *)color;

+ (void)setFonts:(NSString *)fontName andBoldFont:(NSString *)boldFontName;

+ (void)setColors:(UIColor *)backgroundColor primaryColor:(UIColor *)primaryColor gradientColor:(UIColor *)gradientColor lightFontColor:(UIColor *)lightFontColor darkFontColor:(UIColor *)darkFontColor;

+ (void)setFontsSizes:(CGFloat)miniFontSize midFontSize:(CGFloat)midFontSize regularFontSize:(CGFloat)regularFontSize titleFontSize:(CGFloat)titleFontSize subTitleFontSize:(CGFloat)subTitleFontSize navigationTitleFontSize:(CGFloat)navigationTitleFontSize;

+ (void)setBarStyle:(UIBarStyle)barStyle;

// MARK: - Métodos de instância

- (void)getUserBalanceWithCompletion:(void (^_Nonnull)(NSString * _Nullable reasonMessage, double balance))completion;

- (void)showProfileController:(UIViewController *_Nonnull)controller;

- (void)callSignUp:(UIViewController *_Nonnull)vc completion:(void (^_Nullable)(NSString * _Nullable phoneNumber, NSString * _Nullable emailAddress, NSString * _Nullable sessionToken))completion;

- (void)callLogin:(UIViewController *_Nonnull)vc completion:(void (^_Nullable)(NSString * _Nullable phoneNumber, NSString *_Nullable emailAddress, NSString *_Nullable sessionToken))completion;

- (void)callLogin:(UIViewController *_Nonnull)vc hideCloseButton:(BOOL)hideCloseButton completion:(void (^_Nullable)(NSString * _Nullable phoneNumber, NSString *_Nullable emailAddress, NSString *_Nullable sessionToken))completion;

- (void)callLogin:(UIViewController *)vc requireFullName:(BOOL)requireFullName requireCpfOrCnpj:(BOOL)requireCpfOrCnpj completion:(void (^)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken))completion __attribute__((unavailable("User a função callLogin sem o parametro de termos e setar os termos em Lib4all.setTermsOfServiceURL()")));;

- (void)callLogin:(UIViewController *)vc termsOfServiceUrl:(NSString *)url requireFullName:(BOOL)requireFullName requireCpfOrCnpj:(BOOL)requireCpfOrCnpj completion:(void (^)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken))completion __deprecated;

-(void)callLoginWithPayment:(UIViewController *)vc delegate:(id<CallbacksDelegate>) delegate __deprecated;
-(void)callLoginWithPayment:(UIViewController *)vc delegate:(id<CallbacksDelegate>) delegate paymentTypes:(NSArray *)paymentTypes andAcceptedBrands:(NSArray *)acceptedBrands;

- (void)callLogoutWithoutAction: (void (^)(BOOL success))completion;

- (void)callLogout: (void (^)(BOOL success))completion;

- (BOOL)hasUserLogged;

- (NSDictionary *)getAccountData;

- (void)getDefaultCreditCard:(void(^)(CreditCard *card))completion;

- (void)getAccountData:(NSArray *)data completionBlock:(void(^)(NSDictionary *data))completion;

- (void)setAccountData:(NSDictionary *)data completionBlock:(void(^)(NSDictionary *error))completion;

- (void)showCardPickerInViewController:(UIViewController *)viewController completionBlock:(void(^)(NSString *cardID))completion;

- (void)showCardPickerInViewController:(UIViewController *)viewController completionBlock:(void(^)(NSString *cardID))completion withAcceptedPaymentTypes: (NSArray *)paymentTypes andAcceptedBrands: (NSArray *) acceptedBrands;

- (void)openDebitWebViewInViewController:(UIViewController *)viewController withUrl:(NSURL *)url completionBlock:(void(^)(BOOL success))completion;

- (void)generateAndShowOfflineQrCode:(UIViewController *)viewController ec:(NSString *) ec transactionId:(NSString *)transactionId amount:(int) amount campaignUUID:(NSString *)campaignUUID couponUUID:(NSString *) couponUUID;

- (void)generateAndShowOfflineQrCode:(UIViewController *)viewController ec:(NSString *) ec transactionId:(NSString *)transactionId amount:(int) amount;

- (NSDictionary *)unwrapBase64OfflineQrCode:(NSString *)qrCodeBase64;

- (NSString *)generateOfflinePaymentStringForTransactionID:(NSString *)transactionID cardID:(NSString *)cardID amount:(int)amount campaignUUID:(NSString *)campaignUUID couponUUID:(NSString *) couponUUID;

- (NSString *)generateOfflinePaymentStringForTransactionID:(NSString *)transactionID cardID:(NSString *)cardID amount:(int)amount;

- (void)showChat;

- (void)openAccountScreen:(ProfileOption)profileOption inViewController:(UIViewController *)viewController;

- (void)openPrepaidScreen:(PrepaidOption)prepaidOption inViewController:(UIViewController *)viewController;

- (void)openPaymentSuccessScreen:(NSNumber *)amount merchantName:(NSString *)merchantName merchantLogoUrl:(NSString *)merchantLogoUrl parcels:(NSNumber *)parcels inViewController:(UIViewController *)viewController;

- (BOOL)qrCodeIsSupported:(NSString *)contentQrCode;

- (void)handleQrCode:(NSString *)contentQrCode inViewController:(UIViewController *)viewController didFinishTransaction:(void (^)())didFinishTransaction;

- (UIViewController *_Nonnull)getUserDataScreenPassingNavigation:(UINavigationController *_Nonnull)navigationController;

- (UIViewController *_Nonnull)getSettingsScreenWithLogoutEnabled:(BOOL)logoutEnabled;

// MARK: - Addresses

- (void) listAddresses:(void(^)(NSArray<UserAddress *> *addresses)) completion;

- (void) addAddress:(UserAddress *)address completion:(void(^)(BOOL success, UserAddress *userAddress)) completion;

- (void) setDefaultAddress:(NSString *)addressId completion:(void(^)(BOOL success)) completion;

- (void) deleteAddress:(NSString *)addressId completion:(void(^)(BOOL success)) completion;

//Social Login SDK's
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)applicationDidBecomeActive;

- (void) callComponentButtonClick:(UIViewController *)vc isCheckingAccount:(BOOL)isCheckingAccount delegate:(id<CallbacksDelegate>)delegate;

@end
