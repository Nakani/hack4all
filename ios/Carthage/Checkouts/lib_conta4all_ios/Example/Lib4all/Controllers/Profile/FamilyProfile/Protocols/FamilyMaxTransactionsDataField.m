//
//  FamilyMaxTransactionsDataField.m
//  Example
//
//  Created by Adriano Soares on 26/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyMaxTransactionsDataField.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"

@implementation FamilyMaxTransactionsDataField
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
        self.navigationTitle = @"Definir máximo de transações";
        self.currentLabel    = @"Número máximo de transações atual";
        self.title           = @"Digite o novo número";
        
        self.serverKey       = @"totalTransactionsLimit";
        
        self.keyboardType    = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    
    return YES;
}

- (NSString *)currentValueFormatted:(NSString *)data {
    return data;
}

- (NSString *)serverFormattedData:(NSString *) data {
    if (data.length == 0) return nil;
    return data;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
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
                     self.serverKey: [NSNumber numberWithDouble:[data doubleValue]]
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

/*
// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [[newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (newString.length > 0 && [newString doubleValue] > 0) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        textField.text = [formatter stringFromNumber: [NSNumber numberWithFloat:[newString doubleValue]/100]];
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    } else {
        textField.text = @"";
    }
    
    return NO;
}
*/
@end
