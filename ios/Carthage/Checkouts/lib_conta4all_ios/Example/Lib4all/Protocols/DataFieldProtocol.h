//
//  DataFieldProtocol.h
//  Example
//
//  Created by Cristiano Matte on 02/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DataFieldProtocol <UITextFieldDelegate>

@required
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;
@property (strong, nonatomic) NSString *textFieldPlaceHolder;
@property (strong, nonatomic) NSString *textFieldImageName;
@property (strong, nonatomic) NSString *textFieldWithErrorImageName;
@property (strong, nonatomic) NSString *serverKey;
@property UIKeyboardType keyboardType;
@property (strong, nonatomic) NSString *preSettedField;
@property (strong, nonatomic) NSMutableAttributedString *attrTitle;

- (BOOL)isDataValid:(NSString *)data;
- (NSString *)serverFormattedData:(NSString *)data;
- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion;
- (void) setAttrTitleForString:(NSString *)value;


@end
