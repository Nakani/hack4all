//
//  FamilyConfirmViewController.h
//  Example
//
//  Created by Adriano Soares on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyConfirmViewController : UIViewController

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *cardID;

@property double amount;

@property (strong, nonatomic) NSDictionary *sharedDetails;

@end
