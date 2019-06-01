//
//  UserAddress.h
//  Example
//
//  Created by Adriano Soares on 05/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAddress : NSObject


@property (strong, nonatomic) NSString *addressId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *complement;
@property (strong, nonatomic) NSString *neighborhood;
@property (strong, nonatomic) NSString *reference;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *zip;
@property (strong, nonatomic) NSString *province;
@property (strong, nonatomic) NSString *country;
@property BOOL isDefault;

- (instancetype)initWithJson:(NSDictionary *)json;

+ (NSArray *)loadAddresses;
+ (BOOL)saveAddresses: (NSArray *)address;
+ (BOOL)removeAddresses;

@end
