//
//  SISUPasswordDataField.m
//  Example
//
//  Created by 4all on 18/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUPasswordConfirmationDataField.h"
#import "GenericDataViewController.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"

@implementation SISUPasswordConfirmationDataField

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
        _title = @"Por favor, confirme a sua senha.";
        _textFieldPlaceHolder = @"Repetir senha";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    NSString *password = dataController.signFlowController.enteredPassword;
    
    if ([password isEqualToString:data]){
        [dataController.signFlowController viewControllerDidFinish:vc];
    }else{
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        
        [modal show:vc title:@"Atenção!" description:@"As senhas não correspondem." imageMode:Error buttonAction:nil];
    }
    
}

- (BOOL)isDataValid:(NSString *)data {
    return data.length >= 6;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"confirme a sua senha"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}
@end
