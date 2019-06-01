//
//  DateUtil.m
//  Example
//
//  Created by Cristiano Matte on 16/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSString *)convertDateString:(NSString *)date fromFormat:(NSString *)originFormat toFormat:(NSString *)destinationFormat {
    // Converte a data do formato origem para o formato destino
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    NSDateFormatter *originDateFormatter = [[NSDateFormatter alloc] init];
    originDateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    originDateFormatter.dateFormat = originFormat;
    originDateFormatter.locale = locale;

    
    NSDateFormatter *destinationDateFormatter = [[NSDateFormatter alloc] init];
    destinationDateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    destinationDateFormatter.dateFormat = destinationFormat;
    destinationDateFormatter.locale = locale;

    return [destinationDateFormatter stringFromDate:[originDateFormatter dateFromString:date]];
}

+ (BOOL)isValidBirthdateString:(NSString *)birthdate {
    BOOL dateIsValid = YES;
    
    if (birthdate.length < 10) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    NSDate *date = [dateFormatter dateFromString:birthdate];
    
    // Aceita apenas datas anteriores a atual
    dateIsValid = (date != nil) && ([date compare:[NSDate date]] == NSOrderedAscending);
    
    if (dateIsValid){
        // Pega valor do dia, mês e ano;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        
        dateIsValid = components.year > 1900;
    }

    
    return dateIsValid;
}

+ (BOOL)isOverEighteen:(NSDate *)birthdate {
    NSDate *eighteenYearsAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear
                                                                        value:-18
                                                                       toDate:[NSDate date]
                                                                      options:0];

    return !([birthdate compare:eighteenYearsAgo] != NSOrderedAscending);
}

+ (NSString *)convertWeekDays: (NSArray *)days {
    if (days.count == 7) {
        return @"Todos os dias";
    }
    if (days.count == 2 &&  [days containsObject:@6] &&  [days containsObject:@0]) {
        return @"Finais de semana";
    }
    if (days.count == 5 && ![days containsObject:@6] && ![days containsObject:@0]) {
        return @"seg a sex";
    }
    NSArray *daysLabel = @[@"dom", @"seg", @"ter", @"qua", @"qui", @"sex", @"sáb"];
    NSMutableArray *selectedDays = [[NSMutableArray alloc] init];
    for (int i = 0; i < daysLabel.count; i++) {
        if ([days containsObject:[NSNumber numberWithInt:i]]) {
            [selectedDays addObject:daysLabel[i]];
        }
    
    }
    return [selectedDays componentsJoinedByString:@" "];
}

@end
