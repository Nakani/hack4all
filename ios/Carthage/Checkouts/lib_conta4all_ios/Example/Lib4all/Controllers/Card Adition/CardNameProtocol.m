//
//  CardNameProtocol.m
//  Example
//
//  Created by 4all on 26/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardNameProtocol.h"
#import "AnalyticsUtil.h"

@implementation CardNameProtocol

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
        _textFieldPlaceHolder = @"Nome no cartão";
        _keyboardType = UIKeyboardTypeDefault;
        _optional = false;
    }
    return self;
}


- (BOOL)isDataValid:(NSString *)data {
    NSString *regex = @"^[a-zA-Z]{2,26}$";

    return [self checkIfContentIsValid:data regex:regex];
}
- (NSString *)serverFormattedData:(NSString *)data {
    
    return data;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString];
    if (_onUpdateField != nil) {
        NSString *text = textField.text;
        _onUpdateField(nil, text, nil, nil);
    }
    return NO;
}


- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    [AnalyticsUtil logEventWithName:@"digitacao_titular_cartao" andParameters:nil];
    
    self.flowController.cardName = data;
    self.flowController.enteredCardName = data;
    completion(data);
}

-(BOOL)checkIfContentIsValid:(NSString *)text regex:(NSString *)regex{
    
    BOOL returnValue;
    NSString *cleanText = [text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@")" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([text length]==0 || [text componentsSeparatedByString:@" "].count <= 1) {
        returnValue = NO;
    }else{
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
