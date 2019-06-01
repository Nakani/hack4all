//
//  FamilyMonthDayViewController.h
//  Example
//
//  Created by Adriano Soares on 31/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyMonthDayViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property BOOL isCreation;

@property (strong, nonatomic) NSString *serverKey;
@property (strong, nonatomic) NSString *data;

@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *customerId;

@property (nonatomic, copy) void (^completion)(NSString *);

@end
