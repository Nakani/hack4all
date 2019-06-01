//
//  Preferences.m
//  Example
//
//  Created by Cristiano Matte on 31/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Preferences.h"
#import "PersistenceHelper.h"

@implementation Preferences

NSString * const PreferencesFileName = @"preferences.json";
NSString * const ReceivePaymentEmailsKey = @"ReceivePaymentEmails";

+ (id)sharedPreferences {
    static Preferences *sharedPreferences = nil;
    
    @synchronized(self) {
        if (sharedPreferences == nil) {
            sharedPreferences = [[Preferences alloc] init];
            [sharedPreferences load];
            [[PersistenceHelper sharedHelper] registerEntity:sharedPreferences];
        }
    }
    
    return sharedPreferences;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.receivePaymentEmails = YES;
    }
    
    return self;
}

- (BOOL)save {
    NSString *filePath = [PersistenceHelper pathForFilename:PreferencesFileName];
    NSDictionary *preferencesDictionary = @{ReceivePaymentEmailsKey: [NSNumber numberWithBool:self.receivePaymentEmails]};
    
    return [PersistenceHelper saveJSONObject:preferencesDictionary toFile:filePath];
}

- (BOOL)load {
    NSString *filePath = [PersistenceHelper pathForFilename:PreferencesFileName];
    NSDictionary *preferencesDictionary = (NSDictionary *)[PersistenceHelper loadJSONObjectFromFile:filePath];
    
    if (preferencesDictionary == nil) {
        return NO;
    }
    
    if ([preferencesDictionary valueForKey:ReceivePaymentEmailsKey] != nil) {
        self.receivePaymentEmails = [((NSNumber *)[preferencesDictionary valueForKey:ReceivePaymentEmailsKey]) boolValue];
    }
    
    return YES;
}

- (BOOL)remove {
    NSString *filePath = [PersistenceHelper pathForFilename:PreferencesFileName];
    BOOL success = [PersistenceHelper removeContentOfFile:filePath];
    
    // Se arquivo foi removido com sucesso, reinicia os dados das sharedPreferences
    if (success) {
        Preferences *sharedPreferences = [Preferences sharedPreferences];
        sharedPreferences.receivePaymentEmails = YES;
    }
    
    return success;
}

@end