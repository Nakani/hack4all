//
//  SISUCPFDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUCPFDataField.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "CpfCnpjUtil.h"
#import "Lib4all.h"
#import "GenericDataViewController.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"

@implementation SISUCPFDataField


@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize attrTitle = _attrTitle;
@synthesize textFieldPlaceHolder = _textFieldPlaceHolder;
@synthesize textFieldImageName = _textFieldImageName;
@synthesize textFieldWithErrorImageName = _textFieldWithErrorImageName;
@synthesize serverKey = _serverKey;
@synthesize keyboardType = _keyboardType;
@synthesize preSettedField = _preSettedField;

- (instancetype)init {
    self  = [super init];
    
    if (self) {
        _title = @"Por favor, pode nos informar o seu CPF?";
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

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    //Chamada pra validar CPF;
    Services *client = [[Services alloc] init];
    
    client.successCase = ^(id response) {
        [dataController.loadingView finishLoading:^{
            //Se cpf já existe, exibe mensagem e permanece na tela, do contrário segue o flow
            NSString *cpfOrCnpj = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:data];
            dataController.signFlowController.validatedCpf = cpfOrCnpj;
            [dataController.signFlowController.accountData setValue:cpfOrCnpj forKey:CPFKey];
            
            [dataController.signFlowController viewControllerDidFinish:vc];
        }];
    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [dataController.loadingView finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            
            [modal show:vc title:@"Atenção" description:errorMessage imageMode:Error buttonAction:nil];
        }];
    };
    
    
    //Se já foi validado evita a chamada novamente
    if (dataController.signFlowController.validatedCpf != nil &&
        [dataController.signFlowController.validatedCpf isEqualToString:[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:data]]) {
        [dataController.signFlowController viewControllerDidFinish:vc];

    }else{
        [[dataController loadingView] startLoading:dataController title:@"Aguarde..."];
        [client validateCpf:[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:data]];
    }
    
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

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"CPF"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}
@end
