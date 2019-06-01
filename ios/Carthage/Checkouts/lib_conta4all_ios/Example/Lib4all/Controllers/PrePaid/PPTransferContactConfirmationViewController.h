//
//  TransferConfirmationViewController.h
//  Example
//
//  Created by Luciano Bohrer on 14/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPTransferContactConfirmationViewController : UIViewController

@property (strong, nonatomic) NSString *rawId;
@property (strong, nonatomic) NSString *name;
@property BOOL userHasAccount;

@end
