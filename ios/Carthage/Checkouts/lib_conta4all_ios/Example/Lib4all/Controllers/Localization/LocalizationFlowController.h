//
//  LocalizationFlowController.h
//  Example
//
//  Created by Cristiano Matte on 05/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationFlowController : NSObject

@property BOOL onLoginOrAccountCreation;
@property BOOL presentModally;
@property (copy) void (^completionBlock)(UIViewController *viewController);

@property BOOL isFromAddCardMenu;

- (void)startFlowWithViewController:(UIViewController *)viewController;
- (void)viewControllerDidFinish:(UIViewController *)viewController;

@end
