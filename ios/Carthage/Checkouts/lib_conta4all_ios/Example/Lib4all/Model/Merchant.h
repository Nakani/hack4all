//
//  Merchant.h
//  Example
//
//  Created by Cristiano Matte on 28/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchant : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *categoryID;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *cpfOrCnpj;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *merchantKeyId;
@property (nonatomic, copy) NSString *merchantLogo;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
