//
//  LocationManager.m
//  Example
//
//  Created by 4all on 4/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LocationManager.h"
#import "INTULocationManager.h"

@implementation LocationManager

+ (instancetype)sharedManager {
    static LocationManager *sharedUser = nil;
    
    @synchronized(self) {
        if (sharedUser == nil) {
            sharedUser = [[self alloc] init];
        }
    }
    
    return sharedUser;
}

- (instancetype)init {
    if (self = [super init]) {
        self.latitude   = 0.0;
        self.longitude  = 0.0;
        self.accuracy   = 0;
    }
    
    return self;
}


- (NSDictionary *)getLocation {
    NSDictionary *dictionary;
    
    if (self.latitude != 0.0 && self.longitude != 0.0) {
        dictionary = @{@"latitude" :[NSNumber numberWithDouble:self.latitude],
                       @"longitude":[NSNumber numberWithDouble:self.longitude],
                       @"accuracy" :[NSNumber numberWithInt:self.accuracy]};
    } else {
        [self updateLocationWithCompletion:nil];
        dictionary = nil;
    }
    
    return dictionary;
}

- (void)updateLocationWithCompletion:(void (^)(BOOL success, NSDictionary *location))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        INTULocationManager *locationManager = [INTULocationManager sharedInstance];
        [locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                    timeout:10.0
                                       delayUntilAuthorized:YES
                                                      block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                          if (status == INTULocationStatusSuccess) {
                                                              [LocationManager sharedManager].latitude = currentLocation.coordinate.latitude;
                                                              [LocationManager sharedManager].longitude = currentLocation.coordinate.longitude;
                                                              [LocationManager sharedManager].accuracy = (int)currentLocation.horizontalAccuracy;
                                                              if (completion) {
                                                                  completion(YES, [[LocationManager sharedManager] getLocation]);
                                                              }
                                                          } else {
                                                              if (completion) {
                                                                  completion(NO, nil);
                                                              }
                                                          }
                                                      }
         ];
    });
}

@end
