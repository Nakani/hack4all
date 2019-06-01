//
//  CompleteDataViewController.h
//  Example
//
//  Created by Cristiano Matte on 12/08/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignFlowController.h"

@interface CompleteDataViewController : UIViewController

@property (strong, nonatomic) SignFlowController *signFlowController;

@property (strong, nonatomic) NSMutableDictionary *preSettedData;

@end
