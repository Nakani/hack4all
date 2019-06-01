//
//  FlowController.h
//  Example
//
//  Created by Cristiano Matte on 09/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlowController <NSObject>

@property BOOL onLoginOrAccountCreation;

- (void)startFlowWithViewController:(UIViewController *)viewController;
- (void)viewControllerDidFinish:(UIViewController *)viewController;

@optional
- (void)viewControllerWillClose:(UIViewController *)viewController;

@end
