//
//  BirthdateDataField.m
//  Example
//
//  Created by Adriano Soares on 02/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "BirthdateDataField.h"
#import "NSString+Mask.h"
#import "DateUtil.h"
#import "ServicesConstants.h"
#import "Lib4all.h"

@implementation BirthdateDataField

@synthesize title = _title;
@synthesize subTitle = _subTitle;
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
        _title = @"Precisamos saber, qual sua data de nascimento?";
        _textFieldPlaceHolder = @"Data de nascimento";
        _textFieldImageName = @"iconStar";
        _textFieldWithErrorImageName = @"iconStar";
        _serverKey = @"birthdate";
        _keyboardType = UIKeyboardTypeNumberPad;
        NSDictionary *customerData = [Lib4all customerData];
        if (customerData[@"birthdate"] != nil) {
            _preSettedField = customerData[@"birthdate"];
            _preSettedField = [_preSettedField stringByApplyingMask:@"##/##/####" maskCharacter:'#'];
        }
        
    }
    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    return [DateUtil isValidBirthdateString:data];
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [DateUtil convertDateString:data fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"] ;
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
