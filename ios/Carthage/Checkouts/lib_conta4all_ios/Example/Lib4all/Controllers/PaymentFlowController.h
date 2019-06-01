//
//  PaymentFlowController.h
//  Example
//
//  Created by Cristiano Matte on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowController.h"

@interface PaymentFlowController : NSObject <FlowController>

@property (copy, nonatomic) void (^paymentCompletion)();

@end
