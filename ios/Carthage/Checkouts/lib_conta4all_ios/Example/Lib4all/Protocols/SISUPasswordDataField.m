//
//  SISUPasswordDataField.m
//  Example
//
//  Created by 4all on 18/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUPasswordDataField.h"
#import "GenericDataViewController.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"
#import "Lib4allPreferences.h"

@implementation SISUPasswordDataField

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize attrTitle = _attrTitle;
@synthesize textFieldPlaceHolder = _textFieldPlaceHolder;
@synthesize textFieldImageName = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey = _serverKey;
@synthesize keyboardType = _keyboardType;
@synthesize preSettedField = _preSettedField;


- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"Muito bom, defina uma senha para a sua Conta.";
        
        _subTitle = @"A senha deve conter no mínimo 6 caracteres. Evite sequências numéricas ou informações pessoais.";
        _textFieldPlaceHolder = @"Senha";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    dataController.signFlowController.enteredPassword = data;
    [dataController.signFlowController viewControllerDidFinish:vc];

}

- (BOOL)isDataValid:(NSString *)data {
    if (data.length < 6) {
        return NO;
    }
    /*
     if ([pin rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location == NSNotFound) {
     return NO;
     }
     if ([pin rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
     return NO;
     }
     if ([pin rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789012"]].location == NSNotFound) {
     return NO;
     }
     */
    int validationLength = 4;
    
    for (int i = 0; i <= data.length - validationLength; i++) {
        NSString *passwordSubstring = [data substringWithRange:NSMakeRange(i, validationLength)];
        
        if ([@"0123456789012" containsString:passwordSubstring]) {
            return NO;
        }
        if ([@"9876543210987" containsString:passwordSubstring]) {
            return NO;
        }
        for (int j = 0; j <= 9; j++ ) {
            NSString *repetitionString = [NSString stringWithFormat:@"%d%d%d%d", j, j, j, j];
            if ([repetitionString containsString:passwordSubstring]) {
                return NO;
            }
        }
        
        NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzabc";
        NSString *reversedAlphabet = @"zyxwvutsrqponmlkjihgfedcbazyx";
        if ([alphabet containsString:[passwordSubstring lowercaseString]]){
            return NO;
        }
        
        if ([reversedAlphabet containsString:[passwordSubstring lowercaseString]]){
            return NO;
        }
    }
    
    
    validationLength = 6;
    for (int i = 0; i <= data.length - validationLength; i++) {
        NSString *passwordSubstring = [data substringWithRange:NSMakeRange(i, validationLength)];
        NSString *phoneNumber = [_phoneNumber stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                                                                                  withString:@""
                                                                                                     options:NSRegularExpressionSearch
                                                                                                       range:NSMakeRange(0, _phoneNumber.length)];
        
        phoneNumber = [phoneNumber substringFromIndex:2];
        
        if ([phoneNumber containsString:passwordSubstring]){
            return NO;
        }
        if (_cpf != nil && ![_cpf isEqualToString:@""]) {
            if ([_cpf containsString:passwordSubstring]){
                return NO;
            }
        }
    }
    
    NSString *email = [_emailAddress componentsSeparatedByString:@"@"][0];
    if ([data containsString:email]){
        return NO;
    }
    
    return YES;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"senha"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}
@end
