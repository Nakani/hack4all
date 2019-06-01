//
//  Preferences.h
//  Example
//
//  Created by Cristiano Matte on 31/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersistentEntityProtocol.h"

@interface Preferences : NSObject <PersistentEntityProtocol>

@property (nonatomic) BOOL receivePaymentEmails;

+ (id)sharedPreferences;

@end
