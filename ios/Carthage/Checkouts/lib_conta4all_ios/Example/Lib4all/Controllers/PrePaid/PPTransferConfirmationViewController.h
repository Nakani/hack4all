//
//  PPTransferConfirmationViewController.h
//  Example
//
//  Created by Gabriel Miranda Silveira on 16/04/18.
//  Copyright © 2018 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallbacksDelegate.h"
@interface PPTransferConfirmationViewController : UIViewController <CallbacksDelegate>

@property NSString *name;
@property NSString *phoneNumber;
@property NSString *cpf;
@property NSString *descriptionMessage;
@property double amount;
@property BOOL userHasAccount;


@end
