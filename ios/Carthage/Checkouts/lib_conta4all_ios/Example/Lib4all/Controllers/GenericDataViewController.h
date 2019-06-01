//
//  GenericDataViewController.h
//  Example
//
//  Created by 4all on 12/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataFieldProtocol.h"
#import "SignFlowController.h"

@interface GenericDataViewController : UIViewController

@property (nonatomic, strong) id<DataFieldProtocol> dataFieldProtocol;
@property (strong, nonatomic) SignFlowController *signFlowController;
@property (copy) void (^mainButtonAction)(id responseData);
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) LoadingViewController *loadingView;

+ (GenericDataViewController *)getConfiguredControllerWithdataFieldProtocol:(id<DataFieldProtocol>)protocol;
@end
