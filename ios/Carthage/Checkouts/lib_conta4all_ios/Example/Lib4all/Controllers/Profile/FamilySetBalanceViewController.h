//
//  FamilySetBalanceViewController.h
//  Example
//
//  Created by Adriano Soares on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilySetBalanceViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *cardID;

@property (nonatomic, copy) void (^completion)(double);


@end
