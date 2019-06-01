//
//  CardExpirationProtocol.m
//  Example
//
//  Created by 4all on 26/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardExpirationProtocol.h"
#import "NSStringMask.h"
#import "NSString+Mask.h"
#import "AnalyticsUtil.h"

@implementation CardExpirationProtocol

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize attrTitle = _attrTitle;
@synthesize textFieldPlaceHolder = _textFieldPlaceHolder;
@synthesize textFieldImageName = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey = _serverKey;
@synthesize keyboardType = _keyboardType;
@synthesize preSettedField = _preSettedField;
@synthesize onUpdateField = _onUpdateField;
@synthesize flowController = _flowController;
@synthesize optional = _optional;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"Ótimo, agora falta pouco, só precisamos das informações do seu cartão";
        _textFieldPlaceHolder = @"Data de validade";
        _keyboardType = UIKeyboardTypeNumberPad;
        _optional = NO;
    }
    return self;
}


- (BOOL)isDataValid:(NSString *)data {
    NSString *regex = @"[0-9]{2}/[0-9]{2}";

    return [self checkIfContentIsValid:data regex:regex];
}
- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByReplacingOccurrencesOfString:@"/" withString:@"" ];;
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
    if (_onUpdateField != nil) {
        _onUpdateField(nil, nil, newString, nil);
    }
    textField.text = [newString stringByApplyingMask:@"##/##" maskCharacter:'#'];
    
    return NO;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    [AnalyticsUtil logEventWithName:@"digitacao_validade_cartao" andParameters:nil];
    
    self.flowController.expirationDate = data;
    self.flowController.enteredExpirationDate = data;
    completion(data);
    
}
-(BOOL)checkIfContentIsValid:(NSString *)text regex:(NSString *)regex{
    
    BOOL returnValue;
    NSMutableString *cleanText = [[text stringByReplacingOccurrencesOfString:@"(" withString:@""] mutableCopy];
    cleanText = [[cleanText stringByReplacingOccurrencesOfString:@")" withString:@""] mutableCopy];
    cleanText = [[cleanText stringByReplacingOccurrencesOfString:@"-" withString:@""] mutableCopy];
    cleanText = [[cleanText stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    
    
    if([text length]==0){
        returnValue = NO;
    }else{
        
        if (cleanText.length == 4) {
            [cleanText insertString:@"/" atIndex:2];
        }
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:cleanText options:0 range:NSMakeRange(0, [cleanText length])];
        
        if (regExMatches == 0) {
            returnValue = NO;
        } else {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"cartão"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}
@end
