//
//  CardNumberProtocol.m
//  Example
//
//  Created by Adriano Soares on 26/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardNumberProtocol.h"
#import "AnalyticsUtil.h"

@implementation CardNumberProtocol

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
        _textFieldPlaceHolder = @"Número no cartão";
        _keyboardType = UIKeyboardTypeNumberPad;
        _optional = false;

    }
    return self;
}


- (BOOL)isDataValid:(NSString *)data {
    
    NSString *regex = @"^[0-9]{12,19}$";
    
    return [self checkIfContentIsValid:data regex:regex];
    
}
- (NSString *)serverFormattedData:(NSString *)data {

    return [data stringByReplacingOccurrencesOfString:@" " withString:@""];
}


- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {    
    [AnalyticsUtil logEventWithName:@"digitacao_numero_cartao" andParameters:nil];
    
    self.flowController.cardNumber = data;
    self.flowController.enteredCardNumber = data;
    completion(data);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int cleanLenght = (int)[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    
    //Size limit
    if (cleanLenght == 18 && ![string isEqualToString:@""]){
        return NO;
    }
    
    if(cleanLenght == 0) {
        return YES;
    }
    
    if(![string isEqualToString:@""]
       && cleanLenght % 4 == 0 &&
       cleanLenght > 0 &&
       cleanLenght<16) {
        textField.text = [textField.text stringByAppendingString:@" "];
    } else if ([string isEqualToString:@""] &&
              cleanLenght % 4 == 1 &&
            textField.text.length % 5 == 1 &&
              textField.text.length > 0 &&
              cleanLenght < 16){
        //remove automatically the space
        textField.text = [textField.text substringToIndex:textField.text.length-1];
        range = NSMakeRange(range.location-1, range.length);
    }

    if (_onUpdateField != nil) {
        if (!(cleanLenght == 0 && [string isEqualToString:@""])) {
            NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
            text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            _onUpdateField(text, nil, nil, nil);
        }
    }
    
    return YES;
}

-(BOOL)checkIfContentIsValid:(NSString *)text regex:(NSString *)regex{
    
    BOOL returnValue;
    NSString *cleanText = [text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@")" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cleanText = [cleanText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([text length]==0){
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
