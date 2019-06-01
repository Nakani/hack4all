//
//  Services.h
//  Example
//
//  Created by 4all on 4/5/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Lib4allPreferences.h"
#import "UserAddress.h"


@interface Services : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURL *prepareCardBaseURL;
@property (copy) void (^successCase)(id data);
@property (copy) void (^failureCaseWithData)(id data);
@property (copy) void (^failureCase)(NSString *errorID, NSString * errorMessage);
@property (nonatomic, strong) NSString *balanceType;

- (id)init;
- (void)startLoginWithIdentifier:(NSString *)identifier;
- (void)startLoginWithIdentifier:(NSString *)identifier requiredData:(NSArray *)data isCreation:(BOOL)isCreation;
- (void)completeLoginWithChallenge:(NSString *)challenge;
- (void)completeLoginWithChallenge:(NSString *)challenge accountData:(NSDictionary *)data socialData:(NSMutableDictionary *)socialData;
- (void)completeLoginWithPassword:(NSString *)password socialData:(NSMutableDictionary *)socialData;
- (void)refreshSessionWithSessionToken:(NSString *)sessionToken ;
- (void)sendLoginSms;
- (void)sendLoginEmail;
- (void)logout;
- (void)startCustomerCreationWithPhoneNumber:(NSString *)phone emailAddress:(NSString *)email;
- (void)completeCustomerCreationWithChallenge:(NSString *)challenge password:(NSString *)password;
- (void)completeCustomerCreationWithChallenge:(NSString *)challenge password:(NSString *)password accountData:(NSDictionary *)data socialData:(NSDictionary *)socialData;
- (void)requestVaultKey;
- (void)prepareCard:(NSMutableDictionary *)card;
- (void)addCardWithCardNonce:(NSString *)cardNonce scannedCard:(BOOL)scannedCard;
- (void)deleteCardWithCardID:(NSString *)cardID;
- (void)getCardDetailsWithCardID:(NSString *)cardID;
- (void)setDefaultCardWithCardID:(NSString *)cardID;
- (void)listCards;
- (void)getAccountData:(NSArray *)data;
- (void)getAccountDataByTerm:(NSString *)term;
- (void)setAccountData:(NSDictionary *)data;
- (void)setAccountPhoto:(NSString *)base64Photo;
-(void)getAccountPhoto;
- (void)getAccountPreferences:(NSArray *)preferences;
- (void)setAccountPreferences:(NSDictionary *)preferences;
- (void)changeEmailAddress:(NSString *)email;
- (void)requestEmailConfirmation;
- (void)setPhoneNumber:(NSString *)phoneNumber;
- (void)confirmPhoneNumber:(NSString *)phone withChallenge:(NSString *)challenge phoneChangeToken:(NSString *)changeToken;
- (void)resendSMSChallengeForPhoneChangeToken:(NSString *)changeToken;
- (void)listTransactionsWithStartingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount;
- (void)listSubscriptionsWithStartingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount;
- (void)listTransactionsWithSubscriptionID:(NSString *)subscriptionID startingItemIndex:(NSNumber *)itemIndex itemCount:(NSNumber *)itemCount;
- (void)getSubscriptionDetailsWithSubscriptionID:(NSString *)subscriptionId;
- (void)setGeolocation;
- (void)setNewPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword;
- (void)startPasswordRecoveryWithIdentifier:(NSString *)identifier;
- (void) validateCpf:(NSString *)cpf;
- (void)validateSmsOrEmailWithChallenge:(NSString *)challenge;
- (void) addAddress:(UserAddress *) address;
- (void) setDefaultAddress:(NSString *) addressId;
- (void) deleteAddress:(NSString *) addressId;
- (void) addSharedCard:(NSString *) cardId phoneNumber:(NSString *) phoneNumber withData: (NSDictionary *) data intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue;
- (void) addSharedCard:(NSString *) cardId phoneNumber:(NSString *) phoneNumber withBalance: (NSNumber *) balance intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue;
- (void) acceptSharedCard:(NSString *) cardId;
- (void) deleteSharedCard:(NSString *) cardId custumerId:(NSString *) customerId;
- (void) updateSharedCard:(NSString *) cardId custumerId:(NSString *) custumerId withBalance: (NSNumber *) balance;
- (void) updateSharedCard:(NSString *) cardId custumerId:(NSString *) custumerId withBalance: (NSNumber *) balance intervalType:(NSNumber *) intervalType intervalValue: (NSNumber *) intervalValue ;
- (void) updateSharedCard:(NSString *) cardId customerId:(NSString *) customerId withData: (NSDictionary *) data;

- (void) setCardForSubscriptions:(NSString *) cardId oldCardId:(NSString *)oldCardId;
- (void) checkStatus;
-(void)checkPassword:(NSString *)password;
//Payment
-(void)payTransaction:(NSString *)sessionToken withTransactionId:(NSString *)transactionId andCardId:(NSString *)cardId payMode:(PaymentMode)payMode amount:(NSNumber *)amount installments:(NSNumber *)installments waitForTransaction:(BOOL)waitForTransaction loyalty:(NSDictionary *)loyalty isPaymentToken:(BOOL)isPaymentToken;
//Offline Payment
-(void)offlinePayTransaction:(NSString *)sessionToken withTransactionId:(NSString *)transactionId andCardId:(NSString *)cardId payMode:(PaymentMode)payMode amount:(NSNumber *)amount installments:(NSNumber *)installments cupomUIID:(NSString *)cupomUIID campaignUUID:(NSString *)campaignUUID merchantKeyId:(NSString *)merchantKeyId blob:(NSString *)blob waitForTransaction:(BOOL)waitForTransaction;

-(void)refundTransactionWithId:(NSString *)transactionId;
-(void)resendEmailPaymentSlip:(NSString *)transactionId;
-(void)getMerchantData:(NSString *)transactionId andAmount:(NSNumber *)amount isPaymentToken:(BOOL)isPaymentToken;
-(void)getTransactionDetails:(NSString *)transactionId;

- (void) openTunnel;
- (AFHTTPRequestOperationManager *) waitForTunnel:(NSString *)tunnelToken;
- (void)thirdPartyLogin:(NSString *)socialToken fromSocialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK;

@end
