//
//  FamilyDataFieldViewController.h
//  Example
//
//  Created by Adriano Soares on 20/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilyDataFieldProtocol.h"

@interface FamilyDataFieldViewController : UIViewController

@property BOOL isCreation;

@property (nonatomic, copy) void (^completion)(NSString *);

@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) id<FamilyDataFieldProtocol> dataFieldProtocol;

@end
