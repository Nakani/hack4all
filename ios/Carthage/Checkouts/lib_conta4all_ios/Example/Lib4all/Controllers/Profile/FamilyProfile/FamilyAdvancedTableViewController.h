//
//  FamilyAdvancedTableViewController.h
//  Example
//
//  Created by Adriano Soares on 17/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyAdvancedTableViewController : UITableViewController <UITextFieldDelegate>

@property BOOL isCreation;

@property (strong, nonatomic) NSString *cardID;

@property (strong, nonatomic) NSMutableDictionary *sharedDetails;

@property (nonatomic, copy) void (^completion)(NSString *, NSDictionary *);

@end
