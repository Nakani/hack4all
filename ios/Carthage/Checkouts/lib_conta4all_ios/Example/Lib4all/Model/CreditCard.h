//
//  CreditCard.h
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardUtil.h"

@interface CreditCard : NSObject

@property (nonatomic, assign) CardType type;
@property (nonatomic, strong) NSString *cardId;
@property (nonatomic, strong) NSNumber *brandId;
@property (nonatomic, strong) NSString *lastDigits;
@property (nonatomic, strong) NSString *bin;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL isShared;
@property (nonatomic, strong) NSArray *sharedDetails;

@property (nonatomic, strong) NSString *brandLogoUrl;
@property (nonatomic, strong) NSString *cardDescription;
@property (nonatomic, strong) NSString *expirationDate;
@property (nonatomic, strong) NSNumber *balance;
@property (nonatomic, assign) BOOL showBalance;
@property (nonatomic, strong) NSString *balanceMessage;
@property (nonatomic, assign) BOOL askCvv;
@property (nonatomic, strong) NSString *cvvFormat;
@property (nonatomic, strong) NSString *cvvMessage;



- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSString *)getMaskedPan;
-(NSString *)getCardType;

- (BOOL) isProvider;

@end
