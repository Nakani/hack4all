//
//  FamilyExpirationDateDataField.m
//  Example
//
//  Created by Adriano Soares on 26/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyExpirationDateDataField.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"

#import "NSString+Mask.h"
#import "DateUtil.h"
#import "ServicesConstants.h"

@implementation FamilyExpirationDateDataField

@synthesize navigationTitle             = _navigationTitle;
@synthesize currentLabel                = _currentLabel;
@synthesize title                       = _title;
@synthesize textFieldPlaceHolder        = _textFieldPlaceHolder;
@synthesize textFieldImageName          = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey                   = _serverKey;
@synthesize keyboardType                = _keyboardType;

@synthesize cardId                      = _cardId;
@synthesize customerId                  = _customerId;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationTitle = @"Definir prazo do vínculo";
        self.currentLabel    = @"Prazo do vínculo atual";
        self.title           = @"Digite um novo prazo para o vínculo da conta";
        
        self.textFieldPlaceHolder = @"DD/MM/AAAA";
        
        self.serverKey       = @"expirationDate";
        
        self.keyboardType    = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    BOOL dateIsValid = YES;
    if (data.length == 0) {
        return YES;
    }
    
    if (data.length < 10) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    NSDate *date = [dateFormatter dateFromString:data];
    
    // Aceita apenas datas anteriores a atual
    dateIsValid = (date != nil) && ([date compare:[NSDate date]] == NSOrderedDescending);
    return dateIsValid;
}

- (NSString *)currentValueFormatted:(NSString *)data {
    return [DateUtil convertDateString:data fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
}

- (NSString *)serverFormattedData:(NSString *)data {
    if (data.length == 0) {
        return nil;
    }
    
    return [DateUtil convertDateString:data fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"] ;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *)) completion{
    Services *service = [[Services alloc] init];
    
    LoadingViewController *loader = [[LoadingViewController alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [loader finishLoading:^{
            [vc presentViewController:alert animated:YES completion:nil];
        }];
        
    };
    
    service.successCase = ^(NSDictionary *response) {
        [loader finishLoading:^{
            if (completion) {
                completion(data);
            }
        }];
        
    };
    
    if (_cardId && _customerId) {
        NSDictionary *dict;
        if (data) {
            dict = @{
                     self.serverKey: data
                     };
        } else {
            dict = @{
                     self.serverKey: [NSNull null]
                     };
        }
        [service updateSharedCard:self.cardId customerId:self.customerId withData:dict];
        
        [loader startLoading:vc title:@"Aguarde..."];
    }
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [newString stringByReplacingOccurrencesOfString:@"/" withString:@"" ];
    textField.text = [newString stringByApplyingMask:@"##/##/####" maskCharacter:'#'];
    
    return NO;
}

@end
