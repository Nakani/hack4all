//
//  UserAddress.m
//  Example
//
//  Created by Adriano Soares on 05/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UserAddress.h"
//#import "ServicesConstants.h"
#import "PersistenceHelper.h"

@implementation UserAddress


NSString * const AddressesFileName = @"Addresses.json";
NSString * const IdKey             = @"id";
NSString * const NameKey           = @"name";
NSString * const StreetKey         = @"street";
NSString * const NumberKey         = @"number";
NSString * const ComplementKey     = @"complement";
NSString * const NeighborhoodKey   = @"neighborhood";
NSString * const ReferenceKey      = @"reference";
NSString * const CityKey           = @"city";
NSString * const ZipKey            = @"zip";
NSString * const ProvinceKey       = @"province";
NSString * const CountryKey        = @"country";
NSString * const isDefaultKey      = @"isDefault";

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.addressId    = nil;
        self.name         = nil;
        self.street       = nil;
        self.number       = nil;
        self.complement   = nil;
        self.neighborhood = nil;
        self.reference    = nil;
        self.city         = nil;
        self.zip          = nil;
        self.province     = nil;
        self.country      = nil;
        self.isDefault    = NO;
    }
    
    return self;
}


- (instancetype)initWithJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.addressId    = [json objectForKey:IdKey];
        self.name         = [json objectForKey:NameKey];
        self.street       = [json objectForKey:StreetKey];
        if ([json objectForKey:NumberKey] && [json objectForKey:NumberKey] != [NSNull null]) {
            self.number       = [json objectForKey:NumberKey];
        }

        if ([json objectForKey:ComplementKey] && [json objectForKey:ComplementKey] != [NSNull null]) {
            self.complement       = [json objectForKey:ComplementKey];
        }

        self.neighborhood = [json objectForKey:NeighborhoodKey];
        if ([json objectForKey:ReferenceKey] && [json objectForKey:ReferenceKey] != [NSNull null]) {
            self.reference    = [json objectForKey:ReferenceKey];
        }
        self.city         = [json objectForKey:CityKey];
        self.zip          = [json objectForKey:ZipKey];
        if ([json objectForKey:ProvinceKey] && [json objectForKey:ProvinceKey] != [NSNull null]) {
            self.province     = [json objectForKey:ProvinceKey];
        }
        self.province     = [json objectForKey:ProvinceKey];
        self.country      = [json objectForKey:CountryKey];
        self.isDefault    = [[json objectForKey:isDefaultKey] boolValue];
    }

    return self;

}

+ (NSArray *)loadAddresses {
    NSMutableArray *addressList = [[NSMutableArray alloc] init];

    NSString *filePath              = [PersistenceHelper pathForFilename:AddressesFileName];
    NSArray *addresses = (NSArray *)[PersistenceHelper loadJSONObjectFromFile:filePath];
    
    if (addresses) {
        for (int i = 0; i < addresses.count; i++) {
            UserAddress *address = [[UserAddress alloc] initWithJson:addresses[i]];
            [addressList addObject:address];
        
        }
    }
    
    
    return addressList;
}

+ (BOOL)saveAddresses: (NSArray *)address {
    NSString *filePath              = [PersistenceHelper pathForFilename:AddressesFileName];
    return [PersistenceHelper saveJSONObject:address toFile:filePath];
}

+ (BOOL)removeAddresses {
    NSString *filePath              = [PersistenceHelper pathForFilename:AddressesFileName];
    return [PersistenceHelper removeContentOfFile:filePath];
}


@end
