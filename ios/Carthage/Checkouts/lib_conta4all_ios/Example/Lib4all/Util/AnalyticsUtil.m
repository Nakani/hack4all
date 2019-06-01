//
//  AnalyticsUtil.m
//  Example
//
//  Created by Luciano Bohrer on 06/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "AnalyticsUtil.h"
#import "Lib4allPreferences.h"
#ifdef USE_FIREBASE
#import "FirebaseAnalytics.h"
#endif

@implementation AnalyticsUtil

+(void)createScreenViewWithName:(NSString *)name{
    id analytics = [[Lib4allPreferences sharedInstance] analytics];
    if (analytics) {
        
//        [analytics setScreenName:name screenClass:nil];
//        GAI *gai = (GAI *) analytics;
//
//        if ([[Lib4allPreferences sharedInstance] trackingID]) {
//            id<GAITracker> tracker = [gai trackerWithTrackingId:[[Lib4allPreferences sharedInstance] trackingID]];
//            [tracker set:kGAIScreenName value:name];
//            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//        }
    }

}

+(void)createEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label andValue:(NSNumber *)value{
    id analytics = [[Lib4allPreferences sharedInstance] analytics];
    if (analytics) {
        
//        [analytics logEventWithName:@"Teste" parameters:nil];
//        GAI *gai = (GAI *) analytics;
//        
//        if ([[Lib4allPreferences sharedInstance] trackingID]) {
//            id<GAITracker> tracker = [gai trackerWithTrackingId:[[Lib4allPreferences sharedInstance] trackingID]];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
//                                                                  action:action
//                                                                   label:label
//                                                                   value:value] build]];
//        }
    }
}

+ (void) logEventWithName:(NSString *)eventName andParameters:(NSDictionary *_Nullable)parameters {
    id analytics = [[Lib4allPreferences sharedInstance] analytics];
    if (analytics) {
#ifdef USE_FIREBASE
        // Isso foi feito para que o app hospedeiro não seja orbigado a importar o firabase
        // Se o app hospedeiro da lib setar a flag USE_FIREBASE ao preprocessador, iremos usar o framework do firebase,
        // caso contrário não faz nada
        if ([analytics isKindOfClass:FIRAnalytics.class]) {
            [analytics logEventWithName:eventName parameters:parameters];
        }
#endif
    }
}

@end
