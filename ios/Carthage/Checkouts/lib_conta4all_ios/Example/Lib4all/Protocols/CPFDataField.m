//
//  CPFDataField.m
//  Example
//
//  Created by Cristiano Matte on 02/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CPFDataField.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "CpfCnpjUtil.h"
#import "Lib4all.h"

@implementation CPFDataField

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize textFieldPlaceHolder = _textFieldPlaceHolder;
@synthesize textFieldImageName = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey = _serverKey;
@synthesize keyboardType = _keyboardType;
@synthesize preSettedField = _preSettedField;

- (instancetype)init {
    self  = [super init];
    
    if (self) {
        _title = @"Por favor, pode nos informar o seu  CPF?";
        _textFieldPlaceHolder = @"CPF/CNPJ";
        _textFieldImageName = @"iconCpf";
        _textFieldWithErrorImageName = @"iconCpf";
        _serverKey = @"cpf";
        _keyboardType = UIKeyboardTypeNumberPad;
        NSDictionary *customerData = [Lib4all customerData];
        if (customerData[@"cpf"] != nil) {
            _preSettedField = customerData[@"cpf"];
            if (_preSettedField.length <= 11) {
                _preSettedField = [_preSettedField stringByApplyingMask:@"###.###.###-##" maskCharacter:'#'];
            } else {
                _preSettedField = [_preSettedField stringByApplyingMask:@"##.###.###/####-##" maskCharacter:'#'];
            }
        }
        
    }

    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    NSArray *cpfOrCnpj = [[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:data] toNumberArray];
    return [CpfCnpjUtil isValidCpfOrCnpj:cpfOrCnpj];
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:data];
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:newString];
    
    if (newString.length <= 11) {
        textField.text = [newString stringByApplyingMask:@"###.###.###-##" maskCharacter:'#'];
    } else {
        textField.text = [newString stringByApplyingMask:@"##.###.###/####-##" maskCharacter:'#'];
    }
    
    return NO;
}

@end
