//
//  Loyalty.m
//  Example
//
//  Created by Natanael Ribeiro on 15/08/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "Loyalty.h"
#import "ServicesConstants.h"
#import "Lib4allPreferences.h"
#import "Lib4all.h"

@implementation Loyalty

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.programId    = dictionary[ProgramIdKey];
        self.campaignUUID = dictionary[CampaignUuidKey];
        self.couponUUID   = dictionary[CouponUuidKey];
        self.code         = dictionary[CodeKey];
    }
    
    return self;
}

@end
