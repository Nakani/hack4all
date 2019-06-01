//
//  DateUtil.h
//  Example
//
//  Created by Cristiano Matte on 16/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSString *)convertDateString:(NSString *)date fromFormat:(NSString *)originFormat toFormat:(NSString *)destinationFormat;
+ (BOOL)isValidBirthdateString:(NSString *)birthdate;
+ (BOOL)isOverEighteen:(NSDate *)birthdate;
+ (NSString *)convertWeekDays: (NSArray *)days;

@end
