//
//  FamilyWeekDayTableViewController.h
//  Example
//
//  Created by Adriano Soares on 25/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyWeekDayTableViewController : UITableViewController

@property BOOL isCreation;

@property (strong, nonatomic) NSString *serverKey;
@property (strong, nonatomic) NSArray *data;

@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *customerId;

@property (nonatomic, copy) void (^completion)(NSArray *);

@end
