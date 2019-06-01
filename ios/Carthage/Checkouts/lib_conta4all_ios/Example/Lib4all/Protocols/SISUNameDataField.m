//
//  SISUNameDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUNameDataField.h"
#import "Lib4all.h"
#import "GenericDataViewController.h"
#import "LayoutManager.h"

@implementation SISUNameDataField

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
        _title = @"Vamos começar!\nQual é o seu nome completo?";
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

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {

    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    dataController.signFlowController.enteredFullName = data;
    
    [dataController.signFlowController viewControllerDidFinish:vc];
    
}

- (BOOL)isDataValid:(NSString *)data {
    return [data componentsSeparatedByString:@" "].count > 1;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"nome completo"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}

@end
