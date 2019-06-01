//
//  CardAdditionWelcomeViewController.h
//  Example
//
//  Created by Cristiano Matte on 07/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardAdditionFlowController.h"

@interface CardAdditionWelcomeViewController : UIViewController

@property (strong, nonatomic) CardAdditionFlowController *flowController;
@property (copy, nonatomic) void (^loginCompletion)(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken);

@end
