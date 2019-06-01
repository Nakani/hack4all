//
//  SignInViewController.h
//  Example
//
//  Created by Cristiano Matte on 22/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignFlowController.h"
#import "SocialSignInDelegate.h"

@interface SignInViewController : UIViewController <SocialSignInDelegate>

@property (strong, nonatomic) SignFlowController *signFlowController;
@property BOOL hideCloseButton;

@end
