//
//  User.m
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "User.h"
#import "PersistenceHelper.h"

@implementation User

NSString * const UserFileName = @"user.json";
NSString * const CustomerIdKey = @"customerId";
NSString * const EmailAddressKey = @"emailAddress";
NSString * const PhoneNumberKey = @"phoneNumber";
NSString * const CpfKey = @"cpf";
NSString * const FullNameKey = @"fullName";
NSString * const TokenKey = @"sessionToken";
NSString * const BirthdateKey = @"birthdate";
NSString * const EmployerKey = @"employer";
NSString * const JobPositionKey = @"jobPosition";
NSString * const SessionIdKey = @"sessionId";
NSString * const TotpKey = @"totpKey";
NSString * const touchIdKey = @"touchIdEnabled";
NSString * const shouldAskForTouchIdKey = @"shouldAskForTouchId";
NSString * const ProfilePictureKey = @"profilePicture";


+ (instancetype)sharedUser {
    static User *sharedUser = nil;
    
    @synchronized(self) {
        if (sharedUser == nil) {
            sharedUser = [[User alloc] init];
            [sharedUser load];
            
            [[PersistenceHelper sharedHelper] registerEntity:sharedUser];
        }
    }
    
    return sharedUser;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.currentState = UserStateNil;
        self.hasPassword = NO;
        self.isPasswordBlocked = NO;
        self.isTouchIdEnabled = NO;
        self.shouldAskForTouchId = YES;
        
        self.customerId = nil;
        self.emailAddress = nil;
        self.phoneNumber = nil;
        self.cpf = nil;
        self.fullName = nil;
        self.token = nil;
        self.maskedEmail = nil;
        self.maskedPhone = nil;
        self.accessKey = nil;
        self.birthdate = nil;
        self.employer = nil;
        self.jobPosition = nil;
        self.sessionId = nil;
        self.totpKey = nil;
        self.profilePictureBase64 = nil;
        
        
        id preferedPaymentType = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferredPaymentMethod"];
        if (preferedPaymentType == nil) {
            preferedPaymentType = @0;
            [[NSUserDefaults standardUserDefaults] setObject:preferedPaymentType forKey:@"preferredPaymentMethod"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.preferredPaymentMethod = [preferedPaymentType integerValue];
    }
    
    return self;
}

- (BOOL)save {
    NSString *filePath = [PersistenceHelper pathForFilename:UserFileName];
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    
    if(self.currentState != UserStateLoggedIn) {
        return NO;
    }
    
    if (![self.customerId isEqual:[NSNull null]] && ![self.customerId isEqualToString:@""]) {
        [userDictionary setValue:self.customerId forKey:CustomerIdKey];
    }
    if (![self.emailAddress isEqual:[NSNull null]] && ![self.emailAddress isEqualToString:@""]) {
        [userDictionary setValue:self.emailAddress forKey:EmailAddressKey];
    }
    if (![self.phoneNumber isEqual:[NSNull null]] && ![self.phoneNumber isEqualToString:@""]) {
        [userDictionary setValue:self.phoneNumber forKey:PhoneNumberKey];
    }
    if (![self.cpf isEqual:[NSNull null]] && ![self.cpf isEqualToString:@""]) {
        [userDictionary setValue:self.cpf forKey:CpfKey];
    }
    if (![self.fullName isEqual:[NSNull null]] && ![self.fullName isEqualToString:@""]) {
        [userDictionary setValue:self.fullName forKey:FullNameKey];
    }
    if (![self.token isEqual:[NSNull null]] && ![self.token isEqualToString:@""]) {
        [userDictionary setValue:self.token forKey:TokenKey];
    }
    if (![self.birthdate isEqual:[NSNull null]] && ![self.birthdate isEqualToString:@""]) {
        [userDictionary setValue:self.birthdate forKey:BirthdateKey];
    }
    if (![self.employer isEqual:[NSNull null]] && ![self.employer isEqualToString:@""]) {
        [userDictionary setValue:self.employer forKey:EmployerKey];
    }
    if (![self.jobPosition isEqual:[NSNull null]] && ![self.jobPosition isEqualToString:@""]) {
        [userDictionary setValue:self.jobPosition forKey:JobPositionKey];
    }
    if (![self.sessionId isEqual:[NSNull null]] && ![self.sessionId isEqualToString:@""]) {
        [userDictionary setValue:self.sessionId forKey:SessionIdKey];
    }
    if (![self.totpKey isEqual:[NSNull null]] && ![self.totpKey isEqualToString:@""]) {
        [userDictionary setValue:self.totpKey forKey:TotpKey];
    }
    if (![self.profilePictureBase64 isEqual:[NSNull null]] && ![self.profilePictureBase64 isEqualToString:@""]) {
        [userDictionary setValue:self.profilePictureBase64 forKey:ProfilePictureKey];
    }
    [userDictionary setValue:[NSNumber numberWithBool:self.isTouchIdEnabled] forKey:touchIdKey];
    [userDictionary setValue:[NSNumber numberWithBool:self.shouldAskForTouchId] forKey:shouldAskForTouchIdKey];
    
    return [PersistenceHelper saveJSONObject:userDictionary toFile:filePath];
}

- (BOOL)load {
    NSString *filePath = [PersistenceHelper pathForFilename:UserFileName];
    NSDictionary *userDictionary = (NSDictionary *)[PersistenceHelper loadJSONObjectFromFile:filePath];
    
    if (userDictionary == nil) {
        return NO;
    }
    
    if ([userDictionary valueForKey:CustomerIdKey] != nil && ![[userDictionary valueForKey:CustomerIdKey] isEqual:[NSNull null]]) {
        self.customerId = [userDictionary valueForKey:CustomerIdKey];
    }
    if ([userDictionary valueForKey:EmailAddressKey] != nil && ![[userDictionary valueForKey:EmailAddressKey] isEqual:[NSNull null]]) {
        self.emailAddress = [userDictionary valueForKey:EmailAddressKey];
    } else if ([userDictionary valueForKey:@"email"] != nil && ![[userDictionary valueForKey:@"email"] isEqual:[NSNull null]]) {
        self.emailAddress = [userDictionary valueForKey:@"email"];
    }
    if ([userDictionary valueForKey:PhoneNumberKey] != nil && ![[userDictionary valueForKey:PhoneNumberKey] isEqual:[NSNull null]]) {
        self.phoneNumber = [userDictionary valueForKey:PhoneNumberKey];
    } else if ([userDictionary valueForKey:@"phone"] != nil && ![[userDictionary valueForKey:@"phone"] isEqual:[NSNull null]]) {
        self.phoneNumber = [userDictionary valueForKey:@"phone"];
    }
    if ([userDictionary valueForKey:CpfKey] != nil && ![[userDictionary valueForKey:CpfKey] isEqual:[NSNull null]]) {
        self.cpf = [userDictionary valueForKey:CpfKey];
    }
    if ([userDictionary valueForKey:FullNameKey] != nil && ![[userDictionary valueForKey:FullNameKey] isEqual:[NSNull null]]) {
        self.fullName = [userDictionary valueForKey:FullNameKey];
    }
    if ([userDictionary valueForKey:TokenKey] != nil && ![[userDictionary valueForKey:TokenKey] isEqual:[NSNull null]]){
        self.token = [userDictionary valueForKey:TokenKey];
        self.currentState = UserStateLoggedIn;
    }
    if ([userDictionary valueForKey:BirthdateKey] != nil && ![[userDictionary valueForKey:BirthdateKey] isEqual:[NSNull null]]) {
        self.birthdate = [userDictionary valueForKey:BirthdateKey];
    }
    if ([userDictionary valueForKey:EmployerKey] != nil && ![[userDictionary valueForKey:EmployerKey] isEqual:[NSNull null]]) {
        self.employer = [userDictionary valueForKey:EmployerKey];
    }
    if ([userDictionary valueForKey:JobPositionKey] != nil && ![[userDictionary valueForKey:JobPositionKey] isEqual:[NSNull null]]) {
        self.jobPosition = [userDictionary valueForKey:JobPositionKey];
    }
    if ([userDictionary valueForKey:SessionIdKey] != nil && ![[userDictionary valueForKey:SessionIdKey] isEqual:[NSNull null]]) {
        self.sessionId = [userDictionary valueForKey:SessionIdKey];
    }
    if ([userDictionary valueForKey:TotpKey] != nil && ![[userDictionary valueForKey:TotpKey] isEqual:[NSNull null]]) {
        self.totpKey = [userDictionary valueForKey:TotpKey];
    }
    if ([userDictionary valueForKey:touchIdKey] != nil && ![[userDictionary valueForKey:touchIdKey] isEqual:[NSNull null]]) {
        self.isTouchIdEnabled = [[userDictionary valueForKey:touchIdKey] boolValue];
    }
    if ([userDictionary valueForKey:shouldAskForTouchIdKey] != nil && ![[userDictionary valueForKey:shouldAskForTouchIdKey] isEqual:[NSNull null]]) {
        self.shouldAskForTouchId = [[userDictionary valueForKey:shouldAskForTouchIdKey] boolValue];
    }
    if ([userDictionary valueForKey:ProfilePictureKey] != nil && ![[userDictionary valueForKey:ProfilePictureKey] isEqual:[NSNull null]]) {
        self.profilePictureBase64 = [userDictionary valueForKey:ProfilePictureKey];
    }

    return YES;
}

- (BOOL)remove {
    NSString *filePath = [PersistenceHelper pathForFilename:UserFileName];
    BOOL success = [PersistenceHelper removeContentOfFile:filePath];
    
    // Se arquivo foi removido com sucesso, remove os dados do sharedUser
    if (success) {
        User *sharedUser = [User sharedUser];
        sharedUser.currentState = UserStateNil;
        sharedUser.hasPassword = NO;
        sharedUser.isPasswordBlocked = NO;
        sharedUser.isTouchIdEnabled = NO;
        self.shouldAskForTouchId = YES;
        
        sharedUser.customerId = nil;
        sharedUser.emailAddress = nil;
        sharedUser.phoneNumber = nil;
        sharedUser.cpf = nil;
        sharedUser.fullName = nil;
        sharedUser.token = nil;
        sharedUser.maskedEmail = nil;
        sharedUser.maskedPhone = nil;
        sharedUser.accessKey = nil;
        sharedUser.birthdate = nil;
        sharedUser.employer = nil;
        sharedUser.jobPosition = nil;
        sharedUser.sessionId = nil;
        sharedUser.totpKey = nil;
        sharedUser.profilePictureBase64 = nil;
    }

    return success;
}

@end
