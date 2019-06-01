//
//  CardFieldProtocol.h
//  Example
//
//  Created by Adriano Soares on 26/04/17.
//  Copyright © 2017 4all. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CardAdditionFlowController.h"
#import "LayoutManager.h"
@protocol CardFieldProtocol <UITextFieldDelegate>

@required
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;
@property (strong, nonatomic) NSString *textFieldPlaceHolder;
@property (strong, nonatomic) NSString *textFieldImageName;
@property (strong, nonatomic) NSString *textFieldWithErrorImageName;
@property (strong, nonatomic) NSString *serverKey;
@property UIKeyboardType keyboardType;
@property BOOL optional;
@property (strong, nonatomic) NSString *preSettedField;
@property (strong, nonatomic) NSMutableAttributedString *attrTitle;

@property (weak, nonatomic) CardAdditionFlowController *flowController;


@property (nonatomic, copy) void (^onUpdateField)(NSString*, NSString*, NSString*, NSString*);


- (BOOL)isDataValid:(NSString *)data;
- (NSString *)serverFormattedData:(NSString *)data;
- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion;
- (BOOL)checkIfContentIsValid:(NSString *)text regex:(NSString *)regex;
- (void) setAttrTitleForString:(NSString *)value;

@end

