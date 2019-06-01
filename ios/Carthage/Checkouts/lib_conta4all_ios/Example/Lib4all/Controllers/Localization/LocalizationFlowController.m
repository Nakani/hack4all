//
//  LocalizationFlowController.m
//  Example
//
//  Created by Cristiano Matte on 05/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LocalizationFlowController.h"
#import <CoreLocation/CoreLocation.h>
#import "SystemLocalizationRequiredViewController.h"
#import "LocalizationPermissionViewController.h"
#import "LocalizationRequiredViewController.h"
#import "BaseNavigationController.h"

@implementation LocalizationFlowController

- (void)startFlowWithViewController:(UIViewController *)viewController {
    UIViewController *destination;
    
    if (![CLLocationManager locationServicesEnabled]) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"SystemLocalizationRequiredViewController"];
        ((SystemLocalizationRequiredViewController *)destination).flowController = self;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"LocalizationPermissionViewController"];
        ((LocalizationPermissionViewController *)destination).flowController = self;
    } else {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"LocalizationRequiredViewController"];
        ((LocalizationRequiredViewController *)destination).flowController = self;
    }
    
    if (_presentModally) {
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:destination];
        [viewController presentViewController:navigationController animated:YES completion:nil];
    } else {
        [viewController.navigationController pushViewController:destination animated:YES];
    }
}

- (void)viewControllerDidFinish:(UIViewController *)viewController {
    UIViewController *destination;
    
    if (![CLLocationManager locationServicesEnabled]) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"SystemLocalizationRequiredViewController"];
        ((SystemLocalizationRequiredViewController *)destination).flowController = self;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"LocalizationPermissionViewController"];
        ((LocalizationPermissionViewController *)destination).flowController = self;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
               [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        destination = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                       instantiateViewControllerWithIdentifier:@"LocalizationRequiredViewController"];
        ((LocalizationRequiredViewController *)destination).flowController = self;
    } else {
        _completionBlock(viewController);
        return;
    }
    
    [viewController.navigationController pushViewController:destination animated:YES];
}

@end
