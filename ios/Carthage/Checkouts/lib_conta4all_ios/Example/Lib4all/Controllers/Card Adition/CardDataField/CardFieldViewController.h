//
//  CardFieldViewController.h
//  Example
//
//  Created by Adriano Soares on 25/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardAdditionFlowController.h"
#import "CardFieldProtocol.h"

@interface CardFieldViewController : UIViewController

@property (strong, nonatomic) CardAdditionFlowController *flowController;
@property id<CardFieldProtocol> dataProtocol;
@property (assign) BOOL forceShowError;

@end
