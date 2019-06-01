//
//  SISUBirthdateDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUBirthdateDataField.h"
#import "Lib4all.h"
#import "NSString+Mask.h"
#import "DateUtil.h"
#import "ServicesConstants.h"
#import "GenericDataViewController.h"
#import "LayoutManager.h"

@implementation SISUBirthdateDataField

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
        _title = @"Falta pouco!\nQual é a sua data de nascimento?";
        _subTitle = @"Ah, tem que ser completinho! Ex: 10/02/1980";
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

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {

    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    [dataController.signFlowController.accountData setValue:[self serverFormattedData:data] forKey:BirthdateKey];
    
    [dataController.signFlowController viewControllerDidFinish:vc];
    
    
}


- (BOOL)isDataValid:(NSString *)data {
    return [DateUtil isValidBirthdateString:data] || [data isEqualToString:@""] || data == nil;
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

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"data de nascimento"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}

@end
