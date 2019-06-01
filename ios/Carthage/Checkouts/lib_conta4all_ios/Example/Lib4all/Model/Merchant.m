//
//  Merchant.m
//  Example
//
//  Created by Cristiano Matte on 28/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Merchant.h"
#import "ServicesConstants.h"

@implementation Merchant

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.name = dictionary[MerchantNameKey];
        self.categoryID = dictionary[CategoryIDKey];
        self.street = dictionary[StreetAddressKey];
        self.city = dictionary[CityKey];
        self.state = dictionary[StateKey];
        self.url = [NSURL URLWithString:dictionary[UrlKey]];
    }
    
    return self;
}

@end
