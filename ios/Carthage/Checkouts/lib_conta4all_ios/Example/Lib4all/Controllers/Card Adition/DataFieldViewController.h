//
//  DataFieldViewController.h
//  Example
//
//  Created by Cristiano Matte on 02/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlowController.h"
#import "DataFieldProtocol.h"

@interface DataFieldViewController : UIViewController

@property (strong, nonatomic) id<FlowController> flowController;
@property (strong, nonatomic) id<DataFieldProtocol> dataFieldProtocol;
@property BOOL dataIsRequired;

@end
