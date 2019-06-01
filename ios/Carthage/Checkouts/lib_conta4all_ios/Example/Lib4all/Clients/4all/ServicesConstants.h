//
//  ServicesConstants.h
//  Example
//
//  Created by Cristiano Matte on 04/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#ifndef ServicesConstants_h
#define ServicesConstants_h

/*
 * URLs
 */
static NSString* const            ProductionBaseURL = @"https://conta.api.4all.com";
static NSString* const PrepareCardProductionBaseURL = @"https://vault.api.4all.com";
static NSString* const               HomologBaseURL = @"https://conta.homolog-interna.4all.com";
static NSString* const    PrepareCardHomologBaseURL = @"https://vault.homolog-interna.4all.com";
static NSString* const                  TestBaseURL = @"https://conta.test.4all.com";
static NSString* const       PrepareCardTestBaseURL = @"https://vault.test.4all.com";


static NSString* const     PrePaidProductionBaseURL = @"https://api.4all.com/";
static NSString* const        PrePaidHomologBaseURL = @"https://test.api.4all.com/";
static NSString* const           PrePaidTestBaseURL = @"https://test.api.4all.com/";

static NSString* const     LoyaltyProductionBaseURL = @"https://loyalty.4all.com/mid/";
static NSString* const        LoyaltyHomologBaseURL = @"https://loyalty.homolog.4all.com/mid/";
static NSString* const           LoyaltyTestBaseURL = @"https://loyalty.homolog.4all.com/mid/";

/*
 * Server Data Formats
 */
static NSString* const DateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";

/*
 * JSON Keys
 */
static NSString* const           DeviceTypeKey = @"deviceType";
static NSString* const          DeviceModelKey = @"deviceModel";
static NSString* const            OSVersionKey = @"osVersion";
static NSString* const           IdentifierKey = @"identifier";
static NSString* const              SendSMSKey = @"sendSms";
static NSString* const         SendLoginSMSKey = @"sendLoginSms";
static NSString* const               DeviceKey = @"device";
static NSString* const          GeoLocationKey = @"geolocation";
static NSString* const           LoginTokenKey = @"loginToken";
static NSString* const            ChallengeKey = @"challenge";
static NSString* const         SessionTokenKey = @"sessionToken";
static NSString* const            SessionIDKey = @"sessionId";
static NSString* const        CreationTokenKey = @"creationToken";
static NSString* const        ApplicationIDKey = @"applicationId";
static NSString* const         EmailAddressKey = @"emailAddress";
static NSString* const   MaskedEmailAddressKey = @"maskedEmailAddress";
static NSString* const          PhoneNumberKey = @"phoneNumber";
static NSString* const          MaskedPhoneKey = @"maskedPhone";
static NSString* const         RequestVaultKey = @"requestVaultKey";
static NSString* const               AccessKey = @"accessKey";
static NSString* const             CardTypeKey = @"type";
static NSString* const              BrandIDKey = @"brandId";
static NSString* const               CreditKey = @"credit";
static NSString* const                DebitKey = @"debit";
static NSString* const       PatAlimentacaoKey = @"patAlimentacao";
static NSString* const          PatRefeicaoKey = @"patRefeicao";

static NSString* const           LastDigitsKey = @"lastDigits";
static NSString* const            IsDefaultKey = @"default";
static NSString* const             CardDataKey = @"cardData";
static NSString* const            CardNonceKey = @"cardNonce";
static NSString* const          WaitForCardKey = @"waitForCard";
static NSString* const               CardIDKey = @"cardId";
static NSString* const               StatusKey = @"status";
static NSString* const     CardBrandLogoUrlKey = @"brandLogoUrl";
static NSString* const      CardDescriptionKey = @"description";
static NSString* const   CardExpirationDateKey = @"expirationDate";
static NSString* const          CardBalanceKey = @"balance";
static NSString* const      CardShowBalanceKey = @"showBalance";
static NSString* const   CardBalanceMessageKey = @"balanceMessage";
static NSString* const           CardAskCvvKey = @"askCvv";
static NSString* const        CardCvvFormatKey = @"cvvFormat";
static NSString* const       CardCvvMessageKey = @"cvvMessage";
static NSString* const            ItemIndexKey = @"itemIndex";
static NSString* const            ItemCountKey = @"itemCount";
static NSString* const             CardListKey = @"cardList";
static NSString* const      TransactionListKey = @"transactionList";
static NSString* const     SubscriptionListKey = @"subscriptionList";
static NSString* const        TransactionIDKey = @"transactionId";
static NSString* const     TransactionTokenKey = @"transactionToken";
static NSString* const       SubscriptionIDKey = @"subscriptionId";
static NSString* const               AmountKey = @"amount";
static NSString* const            CreatedAtKey = @"createdAt";
static NSString* const               PaidAtKey = @"paidAt";
static NSString* const         MerchantInfoKey = @"merchantInfo";
static NSString* const             CardInfoKey = @"cardInfo";
static NSString* const         MerchantNameKey = @"name";
static NSString* const           CategoryIDKey = @"categoryId";
static NSString* const        StreetAddressKey = @"streetAddress";
static NSString* const                 CityKey = @"city";
static NSString* const                StateKey = @"state";
static NSString* const                  UrlKey = @"url";
static NSString* const                 TrueKey = @"true";
static NSString* const                 DataKey = @"data";
static NSString* const                ErrorKey = @"error";
static NSString* const            ErrorCodeKey = @"code";
static NSString* const         ErrorMessageKey = @"message";
static NSString* const                  CPFKey = @"cpf";
static NSString* const            BirthdateKey = @"birthdate";
static NSString* const           CardNumberKey = @"cardNumber";
static NSString* const           CardholderKey = @"cardholderName";
static NSString* const       ExpirationDateKey = @"expirationDate";

static NSString* const         SecurityCodeKey = @"securityCode";
static NSString* const          PreferencesKey = @"preferences";
static NSString* const ReceivePaymentEmailsKey = @"receivePaymentEmails";
static NSString* const     PhoneChangeTokenKey = @"phoneChangeToken";
static NSString* const                  CpfKey = @"cpf";
static NSString* const             FullNameKey = @"fullName";
static NSString* const           CustomerIdKey = @"customerId";
static NSString* const         RequiredDataKey = @"requiredAccountData";
static NSString* const          LackingDataKey = @"lackingAccountData";
static NSString* const          AccountDataKey = @"accountData";
static NSString* const            PhotoDataKey = @"photoData";
static NSString* const             EmployerKey = @"employer";
static NSString* const          JobPositionKey = @"jobPosition";
static NSString* const            AddressesKey = @"addresses";
static NSString* const            AddressIDKey = @"addressId";
static NSString* const          AddressNameKey = @"name";
static NSString* const        AddressStreetKey = @"street";
static NSString* const         NeighborhoodKey = @"neighborhood";
static NSString* const           AddressZipKey = @"zip";
static NSString* const             ProvinceKey = @"province";
static NSString* const              CountryKey = @"country";
static NSString* const        AddressNumberKey = @"number";
static NSString* const    AddressComplementKey = @"complement";
static NSString* const     AddressReferenceKey = @"reference";
static NSString* const      RecurringAmountKey = @"recurringAmount";
static NSString* const      NextPaymentDateKey = @"nextPaymentDate";
static NSString* const             PasswordKey = @"password";
static NSString* const     RecurringBalanceKey = @"recurringBalance";
static NSString* const         IntervalTypeKey = @"intervalType";
static NSString* const        IntervalValueKey = @"intervalValue";
static NSString* const             IsSharedKey = @"shared";
static NSString* const                  BinKey = @"bin";
static NSString* const        SharedDetailsKey = @"sharedDetails";
static NSString* const           IsProviderKey = @"sharedProvider";
static NSString* const   PendingSharedCardsKey = @"pendingSharedCards";
static NSString* const          HasPasswordKey = @"hasPassword";
static NSString* const    IsPasswordBlockedKey = @"isPasswordBlocked";
static NSString* const          OldPasswordKey = @"oldPassword";
static NSString* const          NewPasswordKey = @"newPassword";
static NSString* const      WaitForTransaction = @"waitForTransaction";
static NSString* const  DontCancelOnTimeoutKey = @"dontCancelOnTimeout";
static NSString* const                 PayMode = @"paymentMode";
static NSString* const           MerchantKeyId = @"merchantKeyId";
static NSString* const           MerchantIdKey = @"merchantId";
static NSString* const         TransactionData = @"transactionData";
static NSString* const            Installments = @"installments";
static NSString* const              CouponUUID = @"couponUUID";
static NSString* const            CampaignUUID = @"campaignUUID";
static NSString* const            OldCardIDKey = @"oldCardId";
static NSString* const           LibVersionKey = @"libVersion";

static NSString* const          TunnelTokenKey = @"tunnelToken";
static NSString* const         ThirdPartyToken = @"thirdPartyToken";
static NSString* const          ThirdPartyType = @"thirdPartyType";
static NSString* const       ThirdPartyAccount = @"thirdPartyAccount";
static NSString* const            NativeSDKKey = @"nativeSDK";
static NSString* const                  TermKey = @"term";
static NSString* const                  TotpKey = @"totpKey";

//Loyalty
static NSString* const               LoyaltyKey = @"loyalty";
static NSString* const               VersionKey = @"version";
static NSString* const             ProgramIdKey = @"programId";
static NSString* const          CampaignUuidKey = @"campaignUUID";
static NSString* const            CouponUuidKey = @"couponUUID";
static NSString* const                  CodeKey = @"code";

//Installment
static NSString* const       InstallmentTypeKey = @"installmentType";
static NSString* const       MinInstallmentsKey = @"minInstallments";
static NSString* const       MaxInstallmentsKey = @"maxInstallments";
static NSString* const DescribedInstallmentsKey = @"describedInstallments";
static NSString* const  NumberOfInstallmentsKey = @"numberOfInstallments";
static NSString* const     InstallmentAmountKey = @"installmentAmount";

static NSString* const DestinationIdentifierKey = @"destinationIdentifier";
static NSString* const   DestinationDocumentKey = @"destinationDocument";
static NSString* const           DescriptionKey = @"description";
static NSString* const      CustomerDocumentKey = @"customerDocument";
static NSString* const              ReceiverKey = @"receiver";
static NSString* const           BalanceTypeKey = @"balanceType";

static NSString* const SubscriptionInOtherCardKey = @"subscriptionInOtherCard";

static NSString* const         AuthorizationKey = @"Authorization";
static NSString* const         LastCreatedAtKey = @"lastCreatedAt";
static NSString* const           PaymentModeKey = @"paymentMode";
static NSString* const         PaymentCashInKey = @"paymentCashIn";
static NSString* const               SuccessKey = @"success";
static NSString* const                 AfterKey = @"after";
static NSString* const               SummaryKey = @"summary";

/*
 * Methods
 */
static NSString* const               StartLoginMethod = @"/customer/startLogin";
static NSString* const            CompleteLoginMethod = @"/customer/completeLogin";
static NSString* const           RefreshSessionMethod = @"/customer/refreshSession";
static NSString* const             SendLoginSMSMethod = @"/customer/sendLoginSms";
static NSString* const           SendLoginEmailMethod = @"/customer/sendLoginEmail";
static NSString* const                   LogoutMethod = @"/customer/logout";
static NSString* const    StartCustomerCreationMethod = @"/customer/startCustomerCreation";
static NSString* const CompleteCustomerCreationMethod = @"/customer/completeCustomerCreation";
static NSString* const          RequestVaultKeyMethod = @"/customer/requestVaultKey";
static NSString* const              PrepareCardMethod = @"/prepareCard";
static NSString* const                  AddCardMethod = @"/customer/addCard";
static NSString* const               DeleteCardMethod = @"/customer/deleteCard";
static NSString* const           GetCardDetailsMethod = @"/customer/getCardDetails";
static NSString* const           SetDefaultCardMethod = @"/customer/setDefaultCard";
static NSString* const                ListCardsMethod = @"/customer/listCards";
static NSString* const           PayTransactionMethod = @"/customer/payTransaction";
static NSString* const           GetAccountDataMethod = @"/customer/getAccountData";
static NSString* const     GetAccountDataByTermMethod = @"/customer/getAccountDataByTerm";
static NSString* const           SetAccountDataMethod = @"/customer/setAccountData";
static NSString* const          SetAccountPhotoMethod = @"/customer/setAccountPhoto";
static NSString* const          GetAccountPhotoMethod = @"/customer/getAccountPhoto";
static NSString* const    GetAccountPreferencesMethod = @"/customer/getAccountPreferences";
static NSString* const    SetAccountPreferencesMethod = @"/customer/setAccountPreferences";
static NSString* const       ChangeEmailAddressMethod = @"/customer/changeEmailAddress";
static NSString* const RequestEmailConfirmationMethod = @"/customer/requestEmailConfirmation";
static NSString* const           SetPhoneNumberMethod = @"/customer/setPhoneNumber";
static NSString* const       ConfirmPhoneNumberMethod = @"/customer/confirmPhoneNumber";
static NSString* const       ResendSMSChallengeMethod = @"/customer/resendSmsChallenge";
static NSString* const         ListTransactionsMethod = @"/customer/listTransactions";
static NSString* const        ListSubscriptionsMethod = @"/customer/listSubscriptions";
static NSString* const   GetSubscriptionDetailsMethod = @"/customer/getSubscriptionDetails";
static NSString* const           SetGeolocationMethod = @"/customer/setGeolocation";
static NSString* const              SetPasswordMethod = @"/customer/setPassword";
static NSString* const    StartPasswordRecoveryMethod = @"/customer/startPasswordRecovery";
static NSString* const              ValidateCpfMethod = @"/customer/validateCpf";
static NSString* const        ValidateChallengeMethod = @"/customer/validateSmsOrEmailChallenge";
static NSString* const                 PayTransaction = @"/customer/payTransaction";
static NSString* const          OfflinePayTransaction = @"/customer/offlinePayTransaction";
static NSString* const              RefundTransaction = @"/customer/refundTransaction";

static NSString* const               AddAddressMethod = @"/customer/addAddress";
static NSString* const        SetDefaultAddressMethod = @"/customer/setDefaultAddress";
static NSString* const            DeleteAddressMethod = @"/customer/deleteAddress";

static NSString* const            AddSharedCardMethod = @"/customer/addSharedCard";
static NSString* const         AcceptSharedCardMethod = @"/customer/acceptSharedCard";
static NSString* const         DeleteSharedCardMethod = @"/customer/deleteSharedCard";
static NSString* const         UpdateSharedCardMethod = @"/customer/updateSharedCard";

static NSString* const  SetCardForSubscriptionsMethod = @"/customer/setCardForSubscriptions";
static NSString* const              CheckStatusMethod = @"/customer/checkStatus";
static NSString* const              CheckPasswordMethod = @"/customer/checkPassword";

static NSString* const               OpenTunnelMethod = @"/customer/openTunnel";
static NSString* const            WaitForTunnelMethod = @"/customer/waitForTunnel";
static NSString* const                ThirdPartyLogin = @"/customer/thirdPartyLogin";
static NSString* const   ResendEmailPaymentSlipMethod = @"/customer/resendEmailPaymentSlip";
static NSString* const                GetMerchantData = @"/customer/getMerchantData";
static NSString* const                GetTransactionDetails = @"/customer/getTransactionDetails";

static NSString* const                  BalanceMethod = @"customer/balance";
static NSString* const                StatementMethod = @"customer/statement";
static NSString* const              P2PTransferMethod = @"customer/p2pTransfer";
static NSString* const                  SummaryMethod = @"customer/summary";
static NSString* const            PaymentCashInMethod = @"customer/paymentCashIn";

static NSString* const                      PromoCode = @"coupon/promoCode";

#endif /* ServicesConstants_h */
