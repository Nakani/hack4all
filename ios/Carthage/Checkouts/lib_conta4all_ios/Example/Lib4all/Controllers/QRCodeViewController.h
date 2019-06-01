//
//  QRCodeViewController.h
//  Example
//
//  Created by Adriano Soares on 30/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeViewController : UIViewController

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *nameEC;

@property (strong, nonatomic) NSString *campaignUUID;
@property (strong, nonatomic) NSString *couponUUID;

@property int amount;


@end
