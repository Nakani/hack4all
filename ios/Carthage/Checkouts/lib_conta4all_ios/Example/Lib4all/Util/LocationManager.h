//
//  LocationManager.h
//  Example
//
//  Created by 4all on 4/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int    accuracy;

+ (instancetype)sharedManager;

- (NSDictionary *)getLocation;
- (void)updateLocationWithCompletion:(void (^)(BOOL success, NSDictionary *location))completion;

@end
