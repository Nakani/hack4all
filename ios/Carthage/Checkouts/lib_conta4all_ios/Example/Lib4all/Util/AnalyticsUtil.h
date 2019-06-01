//
//  AnalyticsUtil.h
//  Example
//
//  Created by Luciano Bohrer on 06/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsUtil : NSObject

+ (void) createScreenViewWithName:(NSString *)name;

+ (void) createEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label andValue:(NSString *)value;

+ (void) logEventWithName:(NSString *)eventName andParameters:(NSDictionary *_Nullable)parameters;

@end
