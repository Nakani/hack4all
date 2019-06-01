//
//  Header.h
//  Example
//
//  Created by Luciano Bohrer on 01/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lib4allPreferences.h"

@protocol SocialSignInDelegate <NSObject>
@optional
- (void) socialLoginDidFinishWithToken:(NSString *)token fromSocialMedia:(SocialMedia)socialMedia nativeSDK:(BOOL)nativeSDK;

@end
