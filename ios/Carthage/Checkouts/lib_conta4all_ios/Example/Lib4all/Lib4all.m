//
//  Lib4all.m
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Lib4all.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Transaction.h"
#import "CreditCard.h"
#import "User.h"
#import "BaseNavigationController.h"
#import "CardsTableViewController.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "Preferences.h"
#import "PersistenceHelper.h"
#import "WebViewController.h"
#import "QRCodeViewController.h"
#import "LayoutManager.h"
#import "NSData+AES.h"
#import "SignFlowController.h"
#import "SignInViewController.h"
#import <ZDCChat/ZDCChat.h>
#import "CreditCardsList.h"
#import "CallbacksDelegate.h"
#import "CardAdditionFlowController.h"
#import "PaymentFlowController.h"
#import "LoginPaymentAction.h"
#import "PaymentDetailsViewController.h"
#import "QRCodeParser.h"
#import "GenericDataViewController.h"
#import "SISUNameDataField.h"
#import "FXKeychain.h"
#import "NSBundle+Lib4allBundle.h"
#import "CancellationDetailsViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "Lib4allPreferences.h"
#import "LoyaltyServices.h"
#import "PrePaidServices.h"
#import "SettingsTableViewController.h"
#import "NSData+AES.h"

@implementation Lib4all

+ (instancetype)sharedInstance {
    static Lib4all *sharedInstance = nil;

    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[Lib4all alloc] init];
        }
    }

    return sharedInstance;
}

- (id)init {
    self = [super init];

    if (self) {
        [PersistenceHelper sharedHelper];

        NSAssert([Lib4allPreferences sharedInstance].applicationID != nil && [Lib4allPreferences sharedInstance].applicationVersion != nil,
                 @"LIB4ALL: Antes de instanciar a classe Lib4all, você deve configurar o applicationID e o applicationVersion.");

        NSArray *stringParts = [[Lib4allPreferences sharedInstance].applicationID componentsSeparatedByString:@"_"];
        NSAssert(stringParts.count == 3 && [stringParts[0] isEqualToString:@"IOS"],
                 @"LIB4ALL: ApplicationID deve ter o formato IOS_ApplicationName_Version.");
    }

    return self;
}

// MARK: - Métodos de classe de configuração da biblioteca

+ (void)setEnvironment:(Environment)environment {
    [[Lib4allPreferences sharedInstance] setEnvironment:environment];
}

+ (Environment)environment {
    return [Lib4allPreferences sharedInstance].environment;
}

+ (void)setBalanceType:(NSString *)balanceType {
    [[Lib4allPreferences sharedInstance] setBalanceType:balanceType];
}

+ (NSString *)balanceType {
    return [Lib4allPreferences sharedInstance].balanceType;
}

+ (void)setBalanceTypeFriendlyName:(NSString *)balanceTypeFriendlyName {
    [[Lib4allPreferences sharedInstance] setBalanceTypeFriendlyName:balanceTypeFriendlyName];
}

+ (void)setWizardAppName:(NSString *)wizardAppName {
    [[Lib4allPreferences sharedInstance] setWizardAppName:wizardAppName];
}

+ (NSString *)balanceTypeFriendlyName {
    return [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
}

+ (void)setEnableTransferWithCreditCard:(BOOL)isEnabled {
    [Lib4allPreferences sharedInstance].isEnabledTransferWithCreditCard = isEnabled;
}

+ (void)setThirdPartyLoginAppName:(NSString *)appName {
    [[Lib4allPreferences sharedInstance] setThirdPartyLoginAppName:appName];
}

+ (NSString *)thirdPartyLoginAppName {
    return [Lib4allPreferences sharedInstance].thirdPartyLoginAppName;
}


+ (void)setProductionEnvironment:(BOOL)isProductionEnvironment {
    if (isProductionEnvironment) {
        [[Lib4allPreferences sharedInstance] setEnvironment:EnvironmentProduction];
    } else {
        [[Lib4allPreferences sharedInstance] setEnvironment:EnvironmentTest];
    }
}

+(void)setAnalyticsTrackingId:(NSString *)trackingId{
    [[Lib4allPreferences sharedInstance] setTrackingID:trackingId];
}

+(void)setAnalytics: (id)tracking{
    [[Lib4allPreferences sharedInstance] setAnalytics:tracking];
}

+ (void)setApplicationID:(NSString *)applicationID {
    [[Lib4allPreferences sharedInstance] setApplicationID:applicationID];
}

+ (NSString *)applicationID {
    return [[Lib4allPreferences sharedInstance] applicationID];
}

+ (void)setApplicationVersion:(NSString *)applicationVersion {
    [[Lib4allPreferences sharedInstance] setApplicationVersion:applicationVersion];
}

+ (NSString *)applicationVersion {
    return [[Lib4allPreferences sharedInstance] applicationVersion];
}

+ (void)setRegisterWithoutCardAddition:(BOOL)registerWithoutCardAddition {
    [Lib4allPreferences sharedInstance].registerWithoutCardAddition = registerWithoutCardAddition;
}

//métodos antigos deprecados:
+ (void)setAcceptedPaymentMode:(PaymentMode)paymentMode {

    NSAssert(paymentMode == PaymentModeCredit || paymentMode == PaymentModeDebit || paymentMode == PaymentModeCreditAndDebit, @"Payment mode não suportado. Utilize a função setAcceptedPaymentTypes.");

    if (paymentMode == PaymentModeCredit) {
        [[Lib4allPreferences sharedInstance] setAcceptedPaymentTypes:@[@(Credit)]];
    } else if (paymentMode == PaymentModeDebit) {
        [[Lib4allPreferences sharedInstance] setAcceptedPaymentTypes:@[@(Debit)]];
    } else if (paymentMode == PaymentModeCreditAndDebit) {
        [[Lib4allPreferences sharedInstance] setAcceptedPaymentTypes:@[@(Credit), @(Debit)]];
    }

}

+ (PaymentMode)acceptedPaymentMode {

    if ([[[Lib4allPreferences sharedInstance] acceptedPaymentTypes] containsObject:@(Credit)] && [[[Lib4allPreferences sharedInstance] acceptedPaymentTypes] containsObject:@(Debit)])
        return PaymentModeCreditAndDebit;
    else if ([[[Lib4allPreferences sharedInstance] acceptedPaymentTypes] containsObject:@(Credit)])
        return PaymentModeCredit;
    else if ([[[Lib4allPreferences sharedInstance] acceptedPaymentTypes] containsObject:@(Debit)])
        return PaymentModeDebit;
    else {
        NSAssert(false, @"O app aceita outro modo de pagamento que não é crédito ou débito. Utilize a função acceptedPaymentTypes.");
        return 0;
    }
}

//métodos novos:

+(void) setTokenScreenTitle:(NSString *)tokenScreenTitle {
    [Lib4allPreferences sharedInstance].tokenScreenTitle = tokenScreenTitle;
}

+ (void) openAddCardScreenWithViewController:(UIViewController *)viewController {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo.");
    
    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:[Lib4all acceptedPaymentTypes] andAcceptedBrands:[Lib4all acceptedBrands]];
    flowController.isFromAddCardMenu = YES;
    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
    [flowController startFlowWithViewController:viewController];
}

+ (NSString *)getBlobForTefPayment:(NSString *)cardId tag:(NSString *)tag {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo.");
    
    User *sharedUser = [User sharedUser];
    
    NSString *sessionId = sharedUser.sessionId;
    
    int timestamp = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] intValue];
    NSString *timestampAndCardId = [NSString stringWithFormat:@"a=%d&b=%@", timestamp, cardId];
    NSData *encondedTimestampAndCardId = [[timestampAndCardId dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataWithKey:sharedUser.token];
    NSString *base64TimestampAndCardId = [encondedTimestampAndCardId base64EncodedStringWithOptions:0];
    NSString *urlTimestampAndCardId = [base64TimestampAndCardId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    return [NSString stringWithFormat:@"a=%@&b=%@&c=%@", sessionId, urlTimestampAndCardId, tag];
}

+ (void) validatePromocode:(NSString *)promocode transactionId:(NSString *)transactionId amount:(NSNumber *) amount completion:(void (^)(BOOL valid, NSNumber * newAmount, NSNumber * discountAmount, NSMutableDictionary * loyalty, NSString * message)) completion {
    
    [self validatePromocode:promocode transactionId:transactionId merchantId:nil amount:amount completion:completion];
}

+ (void) validatePromocode:(NSString *)promocode transactionId:(NSString * _Nullable)transactionId merchantId:(NSString * _Nullable)merchantId amount:(NSNumber *_Nonnull) amount completion:(void (^_Nullable)(BOOL valid, NSNumber * _Nullable newAmount, NSNumber * _Nullable discountAmount, NSMutableDictionary * _Nullable loyalty, NSString * _Nullable message)) completion {
    
    NSAssert(transactionId != nil || merchantId != nil,
             @"LIB4ALL: Somente transactionId ou merchantId deve ser nulo.");
    
    LoyaltyServices *client = [LoyaltyServices new];
    
    
    client.successCase = ^(NSDictionary *response) {
        [[LoadingViewController sharedManager] finishLoading:nil];
        
        BOOL valid = [[response valueForKey:@"claimed"] boolValue];
        NSNumber *newAmount;
        NSNumber *discountAmount;
        NSMutableDictionary *loyalty;
        NSString *message = @"";
        
        if(valid) {
            newAmount = [[NSNumber alloc] initWithLong:[[response valueForKey:@"newAmount"] longValue]];
            discountAmount = [[NSNumber alloc] initWithLong:[[response valueForKey:@"discountAmount"] longValue]];
            
            loyalty = [[NSMutableDictionary alloc] init];
            [loyalty setValue:@(2) forKey:VersionKey];
            [loyalty setValue:[response valueForKey:@"programId"] forKey:ProgramIdKey];
            [loyalty setValue:[response valueForKey:@"campaignUUID"] forKey:CampaignUuidKey];
            [loyalty setValue:[response valueForKey:@"couponUUID"] forKey:CouponUuidKey];
            [loyalty setValue:[response valueForKey:@"code"] forKey:CodeKey];
            
            
            message = @"Código válido";
            
        }
        
        completion(valid, newAmount, discountAmount, loyalty, message);
    };
    
    client.failureCase = ^(NSString *cod, NSString *msg){
        NSLog(@"%@",msg);
        NSString *message = @"";
        if([cod  isEqual: @"24442669"]) {
            message = @"Código inválido";
        } else if([cod  isEqual: @""]) {
            message = @"Código inválido para este estabelecimento";
        } else {
            message= msg;
        }
        
        completion(false, nil, nil, nil, message);
    };
    
    [client     promoCode:promocode
        withTransactionId:transactionId
             orMerchantId:merchantId
                andAmount:amount];

    
}

+ (void) setAcceptedPaymentTypes: (NSArray *) paymentTypes {
    [[Lib4allPreferences sharedInstance] setAcceptedPaymentTypes:paymentTypes];
}

+ (NSArray *) acceptedPaymentTypes {
    return [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
}


+ (void)setAcceptedBrands:(NSArray *)acceptedBrands {
    NSSet *acceptedBrandsSet = [[NSSet alloc] initWithArray:acceptedBrands];
    [[Lib4allPreferences sharedInstance] setAcceptedBrands:acceptedBrandsSet];
}

+ (NSArray *)acceptedBrands {
    NSSet* acceptedBrandsSet = [[Lib4allPreferences sharedInstance] acceptedBrands];
    NSMutableArray *acceptedBrands = [[NSMutableArray alloc] initWithCapacity:acceptedBrandsSet.count];

    for (NSNumber *brand in acceptedBrandsSet) {
        [acceptedBrands addObject:brand];
    }

    return acceptedBrands;
}

+ (void)setRequireFullName:(BOOL)requireFullName {
    [[Lib4allPreferences sharedInstance] setRequireFullName:requireFullName];
}

+ (BOOL)requireFullName {
    return [[Lib4allPreferences sharedInstance] requireFullName];
}

+ (void)setRequireCpfOrCnpj:(BOOL)requireCpfOrCnpj {
    [[Lib4allPreferences sharedInstance] setRequireCpfOrCnpj:requireCpfOrCnpj];
}

+ (void)setChatDepartment:(NSString *)department {
    [[Lib4allPreferences sharedInstance] setChatDepartment:department];
}

+ (BOOL)requireCpfOrCnpj {
    return [[Lib4allPreferences sharedInstance] requireCpfOrCnpj];
}

+ (void)setRequireBirthdate:(BOOL)requireBirthdate {
    [Lib4allPreferences sharedInstance].requireBirthdate = requireBirthdate;
}

+ (BOOL)requireBirthdate {
    return [Lib4allPreferences sharedInstance].requireBirthdate;
}

+ (void)setTermsOfServiceURL:(NSURL *)termsOfServiceURL {
    [[Lib4allPreferences sharedInstance] setTermsOfServiceURL:termsOfServiceURL];
}

+ (NSURL *)termsOfServiceURL {
    return [[Lib4allPreferences sharedInstance] termsOfServiceURL];
}

+ (void)setCustomerData:(NSDictionary *)data {
    [[Lib4allPreferences sharedInstance] setCustomerData:data];
}

+ (NSDictionary *)customerData {
    return [[Lib4allPreferences sharedInstance] customerData];
}

+ (void)disableAntiFraudRuleForProperty:(NSString *)property {
    [Lib4allPreferences sharedInstance].requiredAntiFraudItems[property] = @NO;
}

+ (void)setButtonColor:(UIColor *)buttonColor andGradient:(UIColor * _Nullable)gradientColor {
    [LayoutManager sharedManager].mainButtonColor = buttonColor;
    if(gradientColor) {
        [LayoutManager sharedManager].mainButtonGradientColor = gradientColor;
    } else {
        [LayoutManager sharedManager].mainButtonGradientColor = buttonColor;
    }
}

+ (void)setLoaderColor:(UIColor *)color {
    [Lib4allPreferences sharedInstance].loaderColor = color;
}

+ (void)setFonts:(NSString *)fontName andBoldFont:(NSString *)boldFontName {
    LayoutManager *layout = [LayoutManager sharedManager];
    layout.fontName = fontName;
    layout.boldFontName = boldFontName;
}

+ (void)setColors:(UIColor *)backgroundColor primaryColor:(UIColor *)primaryColor gradientColor:(UIColor *)gradientColor lightFontColor:(UIColor *)lightFontColor darkFontColor:(UIColor *)darkFontColor {
    LayoutManager *layout = [LayoutManager sharedManager];
    layout.backgroundColor         = backgroundColor;
    layout.primaryColor            = primaryColor;
    layout.mainButtonColor         = primaryColor;
    layout.gradientColor           = gradientColor;
    layout.mainButtonGradientColor = gradientColor;
    layout.lightFontColor          = lightFontColor;
    layout.darkFontColor           = darkFontColor;
}

+ (void)setFontsSizes:(CGFloat)miniFontSize midFontSize:(CGFloat)midFontSize regularFontSize:(CGFloat)regularFontSize titleFontSize:(CGFloat)titleFontSize subTitleFontSize:(CGFloat)subTitleFontSize navigationTitleFontSize:(CGFloat)navigationTitleFontSize {
    LayoutManager *layout = [LayoutManager sharedManager];
    layout.miniFontSize = miniFontSize;
    layout.midFontSize = midFontSize;
    layout.regularFontSize = regularFontSize;
    layout.titleFontSize = titleFontSize;
    layout.subTitleFontSize = subTitleFontSize;
    layout.navigationTitleFontSize = navigationTitleFontSize;
}

+ (void)setBarStyle:(UIBarStyle)barStyle {
    LayoutManager *layout = [LayoutManager sharedManager];
    layout.barStyle = barStyle;
}

// MARK: - Métodos de instância

- (void)getUserBalanceWithCompletion:(void (^_Nonnull)(NSString * _Nullable reasonMessage, double balance))completion {
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        completion(msg, 0.0);
    };
    
    services.successCase = ^(NSDictionary *response) {
        double balance = [[response objectForKey:@"balance"] doubleValue];
        completion(nil, balance);
    };
    
    [services balance];
}

- (void)showProfileController:(UIViewController *)controller {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de exibir o perfil.");

    [controller presentViewController:[[ProfileViewController alloc] init] animated:true completion:nil];
}

- (void)callLogin:(UIViewController *_Nonnull)vc hideCloseButton:(BOOL)hideCloseButton completion:(void (^_Nullable)(NSString * _Nullable phoneNumber, NSString *_Nullable emailAddress, NSString *_Nullable sessionToken))completion {
    
    NSAssert([[User sharedUser] currentState] != UserStateLoggedIn,
             @"LIB4ALL: Já existe usuário logado no aplicativo. Deve ser feito logout antes de iniciar novo login.");
    
    SignFlowController *signFlowController = [[SignFlowController alloc] init];
    signFlowController.requirePaymentData = NO;
    signFlowController.loginCompletion = completion;
    
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    UINavigationController *destinationNv = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    SignInViewController *destination = [[destinationNv viewControllers] objectAtIndex:0];
    destination.hideCloseButton = hideCloseButton;
    destination.signFlowController = signFlowController;
    
    [vc presentViewController:destinationNv animated:true completion:nil];
}

- (void)callLogin:(UIViewController *)vc completion:(void (^)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken))completion {
    [self callLogin:vc hideCloseButton:NO completion:completion];

}

-(void)callSignUp:(UIViewController *)vc completion:(void (^)(NSString *, NSString *, NSString *))completion{
    NSAssert([[User sharedUser] currentState] != UserStateLoggedIn,
             @"LIB4ALL: Já existe usuário logado no aplicativo. Deve ser feito logout antes de iniciar novo cadastro.");

    SignFlowController *signFlowController = [[SignFlowController alloc] init];
    signFlowController.requirePaymentData = NO;
    signFlowController.isLogin = NO;
    signFlowController.loginCompletion = completion;

    GenericDataViewController *startController = [GenericDataViewController getConfiguredControllerWithdataFieldProtocol:[[SISUNameDataField alloc] init]];
    startController.signFlowController = signFlowController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:startController];

    //Torna a navigation bar transparente
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = YES;
    navigationController.view.backgroundColor = [UIColor clearColor];
    navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[LayoutManager sharedManager].lightFontColor, NSFontAttributeName:[[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] navigationTitleFontSize]]}];
    [navigationController setTitle:@"Cadastro"];
    [navigationController.navigationBar setTintColor:[LayoutManager sharedManager].lightFontColor];

    [vc presentViewController:navigationController animated:YES completion:nil];
}

-(void)callLoginWithPayment:(UIViewController *)vc delegate:(id<CallbacksDelegate>) delegate{

    [self callLoginWithPayment:vc delegate:delegate paymentTypes:[[Lib4allPreferences sharedInstance] acceptedPaymentTypes] andAcceptedBrands: [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects]] ;
}

-(void)callLoginWithPayment:(UIViewController *)vc delegate:(id<CallbacksDelegate>)delegate paymentTypes:(NSArray *)paymentTypes andAcceptedBrands:(NSArray *)acceptedBrands{

    NSAssert([[User sharedUser] currentState] != UserStateLoggedIn,
             @"LIB4ALL: Já existe usuário logado no aplicativo. Deve ser feito logout antes de iniciar novo login.");

    //[[[LoginPaymentAction alloc] init] callMainAction:vc delegate:delegate acceptedPaymentTypes:paymentTypes acceptedBrands:acceptedBrands];
}

- (void)callPrevendaWithCardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode delegate:(id<CallbacksDelegate>) delegate checkingAccount:(NSString *)checkingAccount cvv:(NSString *)cvv{
    
    if ([delegate respondsToSelector:@selector(callbackPreVenda:cardId:paymentMode:cvv:)]) {
        PaymentFlowController *paymentFlowController = [[PaymentFlowController alloc] init];
        paymentFlowController.paymentCompletion = ^() {
            CreditCard *card = [[CreditCardsList sharedList] getCardWithID:cardId];
            [delegate callbackPreVenda:[[User sharedUser] token] cardId:card.cardId paymentMode:paymentMode cvv:cvv];
        };

        [paymentFlowController startFlowWithViewController:self];
        
    } else if ([delegate respondsToSelector:@selector(callbackPreVenda:cardId:paymentMode:)]) {
        PaymentFlowController *paymentFlowController = [[PaymentFlowController alloc] init];
        paymentFlowController.paymentCompletion = ^() {
            CreditCard *card = [[CreditCardsList sharedList] getCardWithID:cardId];
            [delegate callbackPreVenda:[[User sharedUser] token] cardId:card.cardId paymentMode:paymentMode];
        };
        
        [paymentFlowController startFlowWithViewController:self];    }
}

- (void)callLogin:(UIViewController *)vc requireFullName:(BOOL)requireFullName requireCpfOrCnpj:(BOOL)requireCpfOrCnpj completion:(void (^)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken))completion {
    
    NSAssert([[User sharedUser] currentState] != UserStateLoggedIn,
             @"LIB4ALL: Já existe usuário logado no aplicativo. Deve ser feito logout antes de iniciar novo login.");
    
    [[Lib4allPreferences sharedInstance] setRequireFullName:requireFullName];
    [[Lib4allPreferences sharedInstance] setRequireCpfOrCnpj:requireCpfOrCnpj];
    
    SignFlowController *signFlowController = [[SignFlowController alloc] init];
    signFlowController.requirePaymentData = NO;
    signFlowController.loginCompletion = completion;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]];
    UINavigationController *destinationNv = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    SignInViewController *destination = [[destinationNv viewControllers] objectAtIndex:0];
    destination.signFlowController = signFlowController;
    
    [vc presentViewController:destinationNv animated:true completion:nil];
}

- (void)callLogoutWithoutAction:(void(^)(BOOL success))completion {
    Services *service = [[Services alloc] init];
    ComponentViewController *component = [[Lib4allPreferences sharedInstance] currentVisibleComponent];
    
    FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
    NSString *sessionToken = [keychain objectForKey:@"sessionToken"];
    
    service.successCase = ^(NSDictionary *response) {
        if (component != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [component updateComponentViews];
            }];
        }
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logOut];
        if (completion) completion(YES);
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        if (component != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [component updateComponentViews];
            }];
        }
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logOut];
        if (completion) completion(NO);
    };
    
    [[[ZDCChat instance] api] endChat];
    
    if(sessionToken) {
        [keychain removeObjectForKey:@"sessionToken"];
    }
    [UserAddress removeAddresses];
    [service logout];

}

- (void)callLogout:(void(^)(BOOL success))completion {
    Services *service = [[Services alloc] init];
    ComponentViewController *component = [[Lib4allPreferences sharedInstance] currentVisibleComponent];

    FXKeychain *keychain = [[FXKeychain alloc] initWithService:@"4AllSharingSession" accessGroup:@"B4P3V9KUXN.4AllSessionSharing"];
    NSString *sessionToken = [keychain objectForKey:@"sessionToken"];

    service.successCase = ^(NSDictionary *response) {
        if (component != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [component updateComponentViews];
            }];
        }
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logOut];
        if (completion) completion(YES);
        [Lib4all.sharedInstance.userStateDelegate userDidLogout];
    };

    service.failureCase = ^(NSString *cod, NSString *msg) {
        if (component != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [component updateComponentViews];
            }];
        }
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logOut];
        if (completion) completion(NO);
        [Lib4all.sharedInstance.userStateDelegate userDidLogout];
        
    };

    [[[ZDCChat instance] api] endChat];

    if(sessionToken) {
        [keychain removeObjectForKey:@"sessionToken"];
    }
    [UserAddress removeAddresses];
    [service logout];
}

- (BOOL)hasUserLogged {
    if ([[User sharedUser] currentState] == UserStateLoggedIn) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)getAccountData {
    if ([[User sharedUser] currentState] != UserStateLoggedIn) {
        return nil;
    }

    User *user = [User sharedUser];
    NSMutableDictionary* accountData = [[NSMutableDictionary alloc] init];
    [accountData setValue:[user customerId] forKey:@"customerId"];
    [accountData setValue:[user emailAddress] forKey:@"email"];
    [accountData setValue:[user emailAddress] forKey:@"emailAddress"];
    [accountData setValue:[user phoneNumber] forKey:@"phone"];
    [accountData setValue:[user phoneNumber] forKey:@"phoneNumber"];
    [accountData setValue:[user token] forKey:@"sessionToken"];
    [accountData setValue:[user cpf] forKey:@"cpf"];
    [accountData setValue:[user fullName] forKey:@"fullName"];
    [accountData setValue:[user birthdate] forKey:@"birthdate"];
    [accountData setValue:[user employer] forKey:@"employer"];
    [accountData setValue:[user jobPosition] forKey:@"jobPosition"];
    [accountData setValue:[user sessionId] forKey:@"sessionId"];
    [accountData setValue:[user totpKey] forKey:@"totpKey"];
    [accountData setValue:[user profilePictureBase64] forKey:@"profilePicture"];
    
    return accountData;
}

- (void)getDefaultCreditCard:(void(^)(CreditCard *card))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CreditCard *defaultCard = [[CreditCardsList sharedList] getDefaultCard];
        
        if(defaultCard != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(defaultCard);
            });
        } else {
            Services *service = [[Services alloc] init];
            service.failureCase = ^(NSString *code, NSString *message) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            };
            
            service.successCase = ^(NSDictionary *response){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    CreditCard *defCard = [[CreditCardsList sharedList] getDefaultCard];
                    completion(defCard);
                });
            };
            
            [service listCards];

        }
    });
}

- (void)getAccountData:(NSArray *)data completionBlock:(void(^)(NSDictionary *data))completion {
    Services *service = [[Services alloc] init];

    service.successCase = ^(NSDictionary *response) {
        completion(response);
    };

    service.failureCase = ^(NSString *cod, NSString *msg) {
        NSMutableDictionary *error = [[NSMutableDictionary alloc] init];
        [error setValue:cod forKey:ErrorCodeKey];
        [error setValue:msg forKey:ErrorMessageKey];

        completion(error);
    };

    [service getAccountData:data];
}

- (void)setAccountData:(NSDictionary *)data completionBlock:(void(^)(NSDictionary *error))completion {
    Services *service = [[Services alloc] init];

    service.successCase = ^(NSDictionary *response) {
        completion(nil);
    };

    service.failureCase = ^(NSString *cod, NSString *msg) {
        NSMutableDictionary *error = [[NSMutableDictionary alloc] init];
        [error setValue:cod forKey:ErrorCodeKey];
        [error setValue:msg forKey:ErrorMessageKey];

        completion(error);
    };

    [service setAccountData:data];
}

- (void)showCardPickerInViewController:(UIViewController *)viewController completionBlock:(void(^)(NSString *cardID))completion{
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de exibir o seletor de cartões.");

    CardsTableViewController *cardPickerViewController = [[CardsTableViewController alloc] init];
    cardPickerViewController.onSelectCardAction = OnSelectCardReturnCardId;
    cardPickerViewController.didSelectCardBlock = completion;

    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:cardPickerViewController];

    [viewController presentViewController:navigationController animated:true completion:nil];
}

- (void)openDebitWebViewInViewController:(UIViewController *)viewController withUrl:(NSURL *)url completionBlock:(void(^)(BOOL success))completion {
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    WebViewController *webViewController = (WebViewController *)[storyboard
                                                                 instantiateViewControllerWithIdentifier:@"WebViewController"];

    /*
     * Configura as constraints e o layout do webViewController
     */
    webViewController.view.layer.opacity = 0.0;
    webViewController.view.layer.cornerRadius = 5.0;
    webViewController.view.layer.borderWidth = 1.0;
    webViewController.view.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
    webViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:webViewController.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:viewController.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:webViewController.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:viewController.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:10.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:webViewController.view
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:viewController.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-10.0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:webViewController.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:viewController.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.5
                                                                         constant:0.0];
    [viewController.view addSubview:webViewController.view];
    centerYConstraint.active = YES;
    leftConstraint.active = YES;
    rightConstraint.active = YES;
    heightConstraint.active = YES;

    /*
     * Configura a url a ser exibida e o bloco a ser executado quando o pagamento for finalizado
     */
    webViewController.url = url;

    __weak WebViewController *weakWebViewController = webViewController;
    webViewController.paymentCompletion = ^(BOOL success) {
        /*
         * Esconde o webViewController com animação
         */
        [weakWebViewController willMoveToParentViewController:nil];

        [UIView animateWithDuration:0.5 animations:^{
            weakWebViewController.view.layer.opacity = 0.0;
        } completion:^(BOOL finished) {
            [weakWebViewController removeFromParentViewController];
            [weakWebViewController.view removeFromSuperview];

            // Chama o callback passado por parâmetro
            completion(success);
        }];
    };

    /*
     * Exibe o webViewController com animação
     */
    [webViewController willMoveToParentViewController:viewController];

    [UIView animateWithDuration:0.5 animations:^{
        webViewController.view.layer.opacity = 1.0;
    } completion:^(BOOL finished) {
        [viewController addChildViewController:webViewController];
        [webViewController didMoveToParentViewController:viewController];
    }];
}

- (void)generateAndShowOfflineQrCode:(UIViewController *)viewController ec:(NSString *) ec transactionId:(NSString *)transactionId amount:(int) amount campaignUUID:(NSString *)campaignUUID couponUUID:(NSString *) couponUUID {

    
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    UINavigationController *destinationNv = [storyboard instantiateViewControllerWithIdentifier:@"QRCodeVC"];
    QRCodeViewController *destination = [[destinationNv viewControllers] objectAtIndex:0];

    destination.transactionId = transactionId;
    destination.nameEC = ec;
    destination.amount = amount;
    destination.campaignUUID = campaignUUID;
    destination.couponUUID = couponUUID;

    [viewController presentViewController:destinationNv animated:true completion:nil];

}

- (void)generateAndShowOfflineQrCode:(UIViewController *)viewController ec:(NSString *) ec transactionId:(NSString *)transactionId amount:(int) amount {
    [self generateAndShowOfflineQrCode:viewController ec:ec transactionId:transactionId amount:amount campaignUUID:nil couponUUID:nil];
}

- (NSDictionary *)unwrapBase64OfflineQrCode: (NSString *)qrCodeBase64 {
    NSMutableDictionary *transactionData = [[NSMutableDictionary alloc] init];
    @try {
        //Remove X
        NSString *transactionString = [[qrCodeBase64 substringToIndex:3] stringByAppendingString:[qrCodeBase64 substringFromIndex:4]];

        //Decodifica o base64
        NSData *data = [[NSData alloc] initWithBase64EncodedString:transactionString options:0];

        transactionString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSArray *infos = [transactionString componentsSeparatedByString:@"_"];
        NSString *transactionID = infos[2];
        NSNumber *amount = [NSNumber numberWithInt:[infos[3] intValue]];
        NSString *EC = infos[4];


        [transactionData setValue:transactionID forKey:@"transactionId"];
        [transactionData setValue:amount forKey:@"amount"];
        [transactionData setValue:EC forKey:@"ec"];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }

    return transactionData;
}

- (NSString *)generateOfflinePaymentStringForTransactionID:(NSString *)transactionID cardID:(NSString *)cardID amount:(int)amount campaignUUID:(NSString *)campaignUUID couponUUID:(NSString *) couponUUID  {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de gerar query string para pagamento offline.");

    User *sharedUser = [User sharedUser];
    NSCharacterSet *urlBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"/+=\n"] invertedSet];

    // URL-codifica o sessionToken
    NSString *encodedSessionToken = [sharedUser.token stringByAddingPercentEncodingWithAllowedCharacters:urlBase64CharacterSet];

    // Gera a queryString de transactionData
    NSString *transactionData = [NSString stringWithFormat:@"A=%@&B=%@&C=%@&E=%d", encodedSessionToken, cardID, transactionID, amount];
    if (campaignUUID != nil && couponUUID != nil) {
        transactionData = [transactionData stringByAppendingString:[NSString stringWithFormat:@"&G=%@&F=%@", campaignUUID, couponUUID]];
    }

    // Encripta a queryString de transactionData, converte para base 64 e url-codifica o resultado
    NSData *encondedTransactionData = [[transactionData dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataWithKey:sharedUser.token];
    transactionData = [[encondedTransactionData base64EncodedStringWithOptions:0] stringByAddingPercentEncodingWithAllowedCharacters:urlBase64CharacterSet];

    // Retorna a queryString final com o sessionId e o transactionData
    return [NSString stringWithFormat:@"A=%@&B=%@", sharedUser.sessionId, transactionData];
}

- (NSString *)generateOfflinePaymentStringForTransactionID:(NSString *)transactionID cardID:(NSString *)cardID amount:(int)amount {
    return [self generateOfflinePaymentStringForTransactionID:transactionID cardID:cardID amount:amount campaignUUID:nil couponUUID:nil];
}

- (void)showChat {
    [ZDCChat initializeWithAccountKey:@"41j6mInD9i6LHjwvOXPmlvBQVbG6fceJ"];

    // Personaliza layout do chat
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    [[ZDCPreChatFormView appearance] setFormBackgroundColor:layoutManager.backgroundColor];
    [[ZDCOfflineMessageView appearance] setFormBackgroundColor:layoutManager.backgroundColor];
    [[ZDCChatView appearance] setChatBackgroundColor:layoutManager.backgroundColor];
    [[ZDCLoadingView appearance] setLoadingBackgroundColor:layoutManager.backgroundColor];
    [[ZDCLoadingErrorView appearance] setErrorBackgroundColor:layoutManager.backgroundColor];
    [[ZDCChatUI appearance] setChatBackgroundColor:layoutManager.backgroundColor];

    [[ZDCLoadingErrorView appearance] setButtonTitleColor:layoutManager.lightFontColor];
    [[ZDCLoadingErrorView appearance] setButtonBackgroundColor:layoutManager.darkGreen];

    [[ZDCVisitorChatCell appearance] setTextColor:layoutManager.lightFontColor];
    [[ZDCVisitorChatCell appearance] setBubbleColor:layoutManager.gradientColor];
    [[ZDCVisitorChatCell appearance] setBubbleBorderColor:layoutManager.darkGray];
    [[ZDCAgentChatCell appearance] setBubbleColor:layoutManager.primaryColor];
    [[ZDCAgentChatCell appearance] setBubbleBorderColor:layoutManager.darkGray];
    [[[ZDCChat instance] overlay] setEnabled:NO];

    // Adiciona dados do usuário logado
    User *user = [User sharedUser];
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        if ([self hasUserLogged]) {
            visitor.phone = user.phoneNumber;
            visitor.email = user.emailAddress;
            visitor.name = user.fullName;
        } else {
            visitor.phone = nil;
            visitor.email = nil;
            visitor.name = nil;
        }

    }];

    [[NSNotificationCenter defaultCenter] addObserver:Lib4all.sharedInstance selector:@selector(chatDidLayout:) name:ZDC_CHAT_UI_DID_LAYOUT object:nil];

    [ZDCChat startChat:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptional;
        config.preChatDataRequirements.email = ZDCPreChatDataRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequiredEditable;
        
        if([Lib4allPreferences sharedInstance].chatDepartment) {
            config.department = [Lib4allPreferences sharedInstance].chatDepartment;
            config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        } else {
            config.preChatDataRequirements.department = ZDCPreChatDataRequired;
        }
    }];
}

- (void)openAccountScreen:(ProfileOption)profileOption inViewController:(UIViewController *)viewController {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de exibir a tela solicitada.");

    NSString *storyboardIdentifier;

    switch (profileOption) {
        case ProfileOptionReceipt:
            storyboardIdentifier = @"CompleteTransactionStatementViewController";
            break;
        case ProfileOptionSubscriptions:
            storyboardIdentifier = @"SubscriptionsViewController";
            break;
        case ProfileOptionUserData:
            storyboardIdentifier = @"MyDataViewController";
            break;
        case ProfileOptionUserCards:
            storyboardIdentifier = @"CardsTableViewController";
            break;
        case ProfileOptionSettings:
            storyboardIdentifier = @"SettingsTableViewController";
            break;
        case ProfileOptionHelp:
            [self showChat];
            break;
        case ProfileOptionAbout:
            storyboardIdentifier = @"AboutViewController";
            break;
        case ProfileOptionFamily:
            storyboardIdentifier = @"FamilyProfileTableViewController";
            break;
        case ProfileOptionPayMethods:
            storyboardIdentifier = @"PaymentMethodsTableViewController";
        default:
            break;
    }

    UIViewController *destinationViewController;
    if (storyboardIdentifier != nil) {
        NSBundle *bundle = [NSBundle getLibBundle];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
        
        destinationViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    }

    if (destinationViewController != nil) {
        BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destinationViewController];
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)openPrepaidScreen:(PrepaidOption)prepaidOption inViewController:(UIViewController *)viewController {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de exibir a tela solicitada.");

    NSString *storyboardIdentifier;

    switch (prepaidOption) {
        case PrepaidOptionBalance:
            storyboardIdentifier = @"PPBalanceViewController";
            break;
            
        case PrepaidOptionToken:
            storyboardIdentifier = @"PPTokenViewController";
            break;
            
        case PrepaidOptionTransfer:
            storyboardIdentifier = @"PPTransferController";
            break;
            
        case PrepaidOptionDeposit:
            storyboardIdentifier = @"PPCashInViewController";
            break;

        case PrepaidOptionCashOut:
            storyboardIdentifier = @"PPWithdrawViewController";
            break;
    }

    UIViewController *destinationViewController;
    if (storyboardIdentifier != nil) {
        NSBundle *bundle = [NSBundle getLibBundle];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PrePaid" bundle: bundle];

        destinationViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    }
    
    if (destinationViewController != nil) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            [((UINavigationController*)viewController) pushViewController:destinationViewController animated:YES];
        } else {
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destinationViewController];
            [viewController presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

- (void)openPaymentSuccessScreen:(NSNumber *)amount merchantName:(NSString *)merchantName merchantLogoUrl:(NSString *)merchantLogoUrl parcels:(NSNumber *)parcels inViewController:(UIViewController *)viewController {
    NSAssert([[User sharedUser] currentState] == UserStateLoggedIn,
             @"LIB4ALL: Não existe usuário logado no aplicativo. Deve ser feito login antes de exibir a tela solicitada.");
    
    Merchant *merchantInfo = [[Merchant alloc] init];
    merchantInfo.name = merchantName;
    merchantInfo.merchantLogo = merchantLogoUrl;
    
    Transaction *transactionInfo = [[Transaction alloc] init];
    transactionInfo.amount = amount;
    transactionInfo.merchant = merchantInfo;
    transactionInfo.installments = parcels;
    
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    
    NSString *storyboardIdentifier = @"ReceiptViewController";
    ReceiptViewController *destinationViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    destinationViewController.transactionInfo = transactionInfo;
    destinationViewController.finalTotalAmount = [amount stringValue];
    
    if (destinationViewController != nil) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            [((UINavigationController*)viewController) pushViewController:destinationViewController animated:YES];
        } else {
            BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destinationViewController];
            [viewController presentViewController:navigationController animated:YES completion:nil];
        }
    }
}


-(BOOL)qrCodeIsSupported:(NSString *)contentQrCode{
    BOOL isValid = YES;
    if (contentQrCode.length < 5) {
        return NO;
    }

    NSDictionary *paymentInfo = [[QRCodeParser new] generateDictionaryFromQRContent:contentQrCode];

    isValid = paymentInfo != nil ? YES : NO;

    return isValid;
}

-(void)handleQrCode:(NSString *)contentQrCode inViewController:(UIViewController *)viewController didFinishTransaction:(void (^)())didFinishTransaction{
    
    NSAssert([self qrCodeIsSupported:contentQrCode],
             @"LIB4ALL: QR Code não suportado pela aplicação. Deve ser verificado antes de chamar a função handleQrCode.");
    
    if([[User sharedUser] currentState] == UserStateLoggedIn) {
        
        [self internHandleQrCode:contentQrCode inViewController:viewController didFinishTransaction:didFinishTransaction];
        
    } else {
        
        [[Lib4all sharedInstance] callLogin:viewController completion:^(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken) {
            
            [self internHandleQrCode:contentQrCode inViewController:viewController didFinishTransaction:didFinishTransaction];
        }];
    }
}

- (UIViewController *_Nonnull)getUserDataScreenPassingNavigation:(UINavigationController *)navigationController {
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    
    UserDataViewController *destinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyDataViewController"];
    destinationViewController.isIndependentOfFlow = YES;
    destinationViewController.independentNavigation = navigationController;
    return destinationViewController;
}

- (UIViewController *_Nonnull)getSettingsScreenWithLogoutEnabled:(BOOL)logoutEnabled {
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    
    SettingsTableViewController *settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    settingsViewController.hideCloseButton = YES;
    settingsViewController.isLogoutEnabled = YES;
    return settingsViewController;
}

- (void)internHandleQrCode:(NSString *)contentQrCode inViewController:(UIViewController *)viewController didFinishTransaction:(void (^)())didFinishTransaction{
    Transaction *transactionInfo = [[[QRCodeParser alloc] init] parseToTransaction:contentQrCode];
    UIViewController *destinationViewController;
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle: bundle];
    NSString *controllerIdentifier = @"";
    
    if (transactionInfo.isCancellation) {
        controllerIdentifier = @"CancellationDetailsViewController";
    }else{
        controllerIdentifier = @"PaymentDetailsViewController";
    }
    
    BaseNavigationController *baseDestinationController = [storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
    
    
    if (transactionInfo.isCancellation) {
        destinationViewController = (CancellationDetailsViewController *)[[baseDestinationController viewControllers] objectAtIndex:0];
        ((CancellationDetailsViewController *)destinationViewController).transactionInfo   = transactionInfo;
        ((CancellationDetailsViewController *)destinationViewController).didFinishPayment = didFinishTransaction;
    }else{
        destinationViewController = (PaymentDetailsViewController *)[[baseDestinationController viewControllers] objectAtIndex:0];
        ((PaymentDetailsViewController *)destinationViewController).transactionInfo   = transactionInfo;
        ((PaymentDetailsViewController *)destinationViewController).isMerchantOffline = (transactionInfo.blob != nil && transactionInfo.merchant.merchantKeyId != nil);
        ((PaymentDetailsViewController *)destinationViewController).didFinishPayment = didFinishTransaction;
    }
    
    [viewController presentViewController:baseDestinationController animated:YES completion:nil];

}

// MARK: - Addresses

- (void) listAddresses:(void(^)(NSArray<UserAddress *> *addresses)) completion {
    Services *getAccountDataService = [[Services alloc] init];
    
    getAccountDataService.failureCase = ^(NSString *cod, NSString *msg) {
        if (completion) {
            completion([UserAddress loadAddresses]);
        }
    };
    
    getAccountDataService.successCase = ^(NSDictionary *response) {
        NSMutableArray *addressList = [[NSMutableArray alloc] init];
        
        NSArray *addresses = [response objectForKey:AddressesKey];
        for (int i = 0; i< addresses.count; i++ ) {
            [addressList addObject:[[UserAddress alloc] initWithJson:addresses[i]]];
        }
        [UserAddress saveAddresses:addresses];
        if (completion) {
            completion(addressList);
        }
        
    };
    
    [getAccountDataService getAccountData:@[AddressesKey]];
}

- (void) addAddress:(UserAddress *)address completion:(void(^)(BOOL success, UserAddress *userAddress)) completion {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        if (completion) {
            completion(NO, address);
        }
    };
    
    service.successCase = ^(NSDictionary *response) {
        if (completion) {
            address.addressId = [response objectForKey:AddressIDKey];
            completion(YES, address);
        }
        
    };
    
    [service addAddress:address];
}

- (void) setDefaultAddress:(NSString *)addressId completion:(void(^)(BOOL success)) completion {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        if (completion) {
            completion(NO);
        }
    };
    
    service.successCase = ^(NSDictionary *response) {
        if (completion) {
            completion(YES);
        }
        
    };
    
    [service setDefaultAddress:addressId];
}

- (void) deleteAddress:(NSString *)addressId completion:(void(^)(BOOL success)) completion {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        if (completion) {
            completion(NO);
        }
    };
    
    service.successCase = ^(NSDictionary *response) {
        if (completion) {
            completion(YES);
        }
        
    };
    
    [service deleteAddress:addressId];
}


// MARK: - Chat navigation bar

- (void)chatDidLayout:(NSNotification*)notification {
    ZDCChatViewController *controller = [ZDCChat instance].chatViewController;

    controller.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    controller.navigationController.navigationBar.translucent = NO;
    controller.navigationController.navigationBar.barTintColor = [[LayoutManager sharedManager] darkGreen];
    controller.navigationController.navigationBar.tintColor = [LayoutManager sharedManager].lightFontColor;
    [controller.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[LayoutManager sharedManager].lightFontColor,
                                                                            NSFontAttributeName:[[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize]}];

    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Voltar"
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:Lib4all.sharedInstance
                                                                                  action:@selector(closeChat)];
}

- (void)closeChat {
    ZDCChatViewController *controller = [ZDCChat instance].chatViewController;
    controller.navigationItem.leftBarButtonItem = nil;

    [controller dismissViewControllerAnimated:YES completion:nil];
}


//MARK: - Social SDK's

-(void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
//    [[CSClearDevice getInstance] setApp:[Lib4allPreferences sharedInstance].applicationID];
    
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                             didFinishLaunchingWithOptions:launchOptions];
    
    
}

//-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
//    
//    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                                  openURL:url
//                                                        sourceApplication:sourceApplication
//                                                               annotation:annotation];
//    
//    
//    if (handled == false) {
//        handled = [[GIDSignIn sharedInstance] handleURL:url
//                                      sourceApplication:sourceApplication
//                                             annotation:annotation];
//    }
//    return handled;
//}


-(void) applicationDidBecomeActive {
//    [FBSDKAppEvents activateApp];
    User *user = [User sharedUser];
    if (user.currentState == UserStateLoggedIn) {
        Services *services = [[Services alloc] init];
        services.failureCase = ^(NSString *cod, NSString *msg) { };
        services.successCase = ^(NSDictionary *response) { };
        [services getAccountData:@[CustomerIdKey, PhoneNumberKey, EmailAddressKey, CpfKey, FullNameKey, BirthdateKey, EmployerKey, JobPositionKey, TotpKey]];
    }
}

- (void) callComponentButtonClick:(UIViewController *)vc isCheckingAccount:(BOOL)isCheckingAccount delegate:(id<CallbacksDelegate>)delegate {
    NSLog(@"Entrei no callComponentButtonClick");
    NSArray *acceptedPaymentTypes = [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
    NSArray *acceptedBrands = [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects];
    NSString *checkingAccount = nil;
    if(isCheckingAccount) {
        checkingAccount = @"CHECKING_ACCOUNT";
    }
    NSLog(@"Antes de chamar callComponentButtonClick");
    LoginPaymentAction *loginPaymentAction = [[LoginPaymentAction alloc] init];
    [loginPaymentAction callMainAction:vc delegate:delegate acceptedPaymentTypes:acceptedPaymentTypes acceptedBrands:acceptedBrands checkingAccount:checkingAccount];
    NSLog(@"Depois de chamar callComponentButtonClick");
}

+ (void)hideSummaryButton:(BOOL)hide {
    [[Lib4allPreferences sharedInstance] setHideSummaryButton:hide];
}

+ (void)setAppWebsiteUrl:(NSURL *)url {
    [Lib4allPreferences sharedInstance].appWebsiteURL = url;
}

+ (void)setAppContactUrl:(NSURL *)url {
    [Lib4allPreferences sharedInstance].appContactURL = url;
}

@end
