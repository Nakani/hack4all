//
//  NameDataField.m
//  Example
//
//  Created by Adriano Soares on 09/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "NameDataField.h"
#import "Lib4all.h"

@implementation NameDataField

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
        _title = @"Você vai curtir a conta 4all! \nPara começar nos diga o seu nome completo.";
        
        NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
        _title = [_title stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
        
        _textFieldPlaceHolder = @"Nome Completo";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypeDefault;
        NSDictionary *customerData = [Lib4all customerData];
        if (customerData[@"fullName"] != nil) {
            _preSettedField = customerData[@"fullName"];
        }
    }
    return self;
}

- (BOOL)isDataValid:(NSString *)data {
    return [data componentsSeparatedByString:@" "].count > 1;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}




@end
