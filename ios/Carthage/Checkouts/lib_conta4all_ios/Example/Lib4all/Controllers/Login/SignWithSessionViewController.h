//
//  SignWithSessionViewController.h
//  Example
//
//  Created by Adriano Soares on 08/02/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignFlowController.h"

@interface SignWithSessionViewController : UIViewController

@property (strong, nonatomic) SignFlowController *signFlowController;

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *sessionToken;

@end
