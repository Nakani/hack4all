//
//  Loyalty.h
//  Example
//
//  Created by Natanael Ribeiro on 15/08/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Loyalty : NSObject

@property (nonatomic, copy) NSNumber *programId;
@property (nonatomic, copy) NSString *campaignUUID;
@property (nonatomic, copy) NSString *couponUUID;
@property (nonatomic, copy) NSString *code;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
