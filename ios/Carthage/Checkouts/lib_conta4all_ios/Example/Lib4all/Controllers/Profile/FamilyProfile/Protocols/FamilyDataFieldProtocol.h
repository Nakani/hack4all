//
//  FamilyDataFieldProtocol.h
//  Example
//
//  Created by Adriano Soares on 20/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FamilyDataFieldProtocol <UITextFieldDelegate>

@required
@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) NSString *currentLabel;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *textFieldPlaceHolder;
@property (strong, nonatomic) NSString *textFieldImageName;
@property (strong, nonatomic) NSString *textFieldWithErrorImageName;
@property (strong, nonatomic) NSString *serverKey;
@property UIKeyboardType keyboardType;
@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *customerId;

- (BOOL)isDataValid:(NSString *)data;
- (NSString *)currentValueFormatted:(NSString *)data;
- (NSString *)serverFormattedData:(NSString *)data;

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion;





@end
