//
//  User.h
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersistentEntityProtocol.h"


typedef NS_ENUM(NSInteger, UserState) {
    UserStateOnCreation,
    UserStateOnLogin,
    UserStateLoggedIn,
    UserStateNil
};

@interface User : NSObject <PersistentEntityProtocol>

@property UserState currentState;
@property BOOL hasPassword;
@property BOOL isPasswordBlocked;
@property BOOL isTouchIdEnabled;
@property BOOL shouldAskForTouchId;

@property NSInteger preferredPaymentMethod;

@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *cpf;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *maskedEmail;
@property (nonatomic, copy) NSString *maskedPhone;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *birthdate;
@property (nonatomic, copy) NSString *employer;
@property (nonatomic, copy) NSString *jobPosition;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *totpKey;
@property (nonatomic, copy) NSString *profilePictureBase64;

+ (instancetype)sharedUser;

@end
