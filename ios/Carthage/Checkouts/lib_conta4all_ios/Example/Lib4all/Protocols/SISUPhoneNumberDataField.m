//
//  EmailOrPhoneDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUPhoneNumberDataField.h"
#import "Lib4all.h"
#import "NSStringMask.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "GenericDataViewController.h"
#import "LayoutManager.h"

@implementation SISUPhoneNumberDataField

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
        _title = @"Oi, @name! Diz pra gente qual o seu número de telefone";
        _textFieldPlaceHolder = @"DDD + Telefone";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypePhonePad;
        
        NSDictionary *customerData = [Lib4all customerData];
        if (customerData[@"phoneNumber"] != nil) {
            _preSettedField = customerData[@"phoneNumber"];
        }
    }
    return self;
}

-(void)saveData:(UIViewController *)vc data:(NSString *)data withCompletion:(void (^)(NSString *))completion{
    Services *creation = [[Services alloc] init];
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);

    NSString *cleanNumber = [data stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                                            withString:@""
                                                               options:NSRegularExpressionSearch
                                                                 range:NSMakeRange(0, data.length)];
    cleanNumber = [cleanNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleanNumber = [NSString stringWithFormat:@"55%@", cleanNumber];

    dataController.signFlowController.enteredPhoneNumber = cleanNumber;
    
    /*
     * Se o número já foi validado, pula para tela de e-mail
     * Se já existe conta para este número, chama fluxo de login
     */
    
    if (dataController.signFlowController.validatedNumber != nil &&
        [dataController.signFlowController.validatedNumber isEqualToString:cleanNumber]) {
        //Chama insert de e-mail
        dataController.signFlowController.isPhoneValidated = YES;
        [dataController.signFlowController viewControllerDidFinish:vc];

        
    }else{
        dataController.signFlowController.isPhoneValidated = NO;

        creation.failureCase = ^(NSString *cod, NSString *msg){
            /*
             * Se o código de erro é igual a 1.13, significa que já existe conta para esse número;
             * Dessa forma, é chamado o fluxo de login;
             */
            [dataController.loadingView finishLoading:^{
                if ([cod isEqualToString:@"1.13"]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                                   message:@"Identificamos que você já possui uma conta, deseja fazer login?"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"Sim"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    dataController.signFlowController.isLogin = YES;
                                                    
                                                    
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        Services *services = [[Services alloc] init];
                                                        
                                                        services.failureCase = ^(NSString *cod, NSString *msg){
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [dataController.loadingView finishLoading:^{
                                                                    [[[PopUpBoxViewController alloc] init] show:vc
                                                                                                          title:@"Atenção"
                                                                                                    description:msg
                                                                                                      imageMode:Error buttonAction:nil];
                                                                    
                                                                }];
                                                            });
                                                            
                                                            
                                                        };
                                                        
                                                        services.successCase = ^(NSDictionary *response){
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [dataController.loadingView finishLoading:^{
                                                                    [dataController.signFlowController viewControllerDidFinish:vc];
                                                                }];
                                                            });
                                                        };
                                                        
                                                        
                                                        NSMutableArray *requiredData = [[NSMutableArray alloc] init];
                                                        if (dataController.signFlowController.requireFullName) [requiredData addObject:FullNameKey];
                                                        if (dataController.signFlowController.requireCpfOrCnpj) [requiredData addObject:CPFKey];
                                                        if (dataController.signFlowController.requireBirthdate) [requiredData addObject:BirthdateKey];
                                                        
                                                        
                                                        [services startLoginWithIdentifier:cleanNumber
                                                                              requiredData:requiredData
                                                                                isCreation:NO];
                                                        
                                                        [dataController.loadingView startLoading:vc title:@"Aguarde..."];
                                                        
                                                        
                                                        
                                                    });
                                                }];
                    
                    UIAlertAction* noButton = [UIAlertAction
                                               actionWithTitle:@"Não"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                               }];
                    
                    [alert addAction:noButton];
                    [alert addAction:yesButton];
                    
                    [vc presentViewController:alert animated:YES completion:nil];
                    
                    
                } else {
                    [[[PopUpBoxViewController alloc] init] show:vc
                                                          title:@"Atenção"
                                                    description:msg
                                                      imageMode:Error buttonAction:nil];
                    
                }
            
            }];
            

        };
        
        creation.successCase = ^(NSDictionary *response){
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataController.loadingView finishLoading:^{
                    
                    NSMutableDictionary *accountData = [[NSMutableDictionary alloc] init];
                    [accountData setObject:dataController.signFlowController.enteredFullName forKey:FullNameKey];
                    [accountData setObject:dataController.signFlowController.enteredPhoneNumber forKey:PhoneNumberKey];
                    [[User sharedUser] setToken:response[CreationTokenKey]];
                    
                    dataController.signFlowController.accountData = accountData;
                    [dataController.signFlowController viewControllerDidFinish:vc];
                }];
            });
        };
        
        [dataController.loadingView startLoading:vc title:@"Aguarde..."];
        
        [creation startCustomerCreationWithPhoneNumber:cleanNumber emailAddress:nil];

    }
}

- (BOOL)isDataValid:(NSString *)data {
    return [data componentsSeparatedByString:@" "].count > 1;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [self cleanPhoneString:newString];
    textField.text = (NSString *)[NSStringMask maskString:newString withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    
    return NO;
}

- (NSString *) cleanPhoneString: (NSString *)phone {
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                             withString:@""
                                                options:NSRegularExpressionSearch
                                                  range:NSMakeRange(0, phone.length)];
    
    
    phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    
    return phone;
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"número de telefone"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}

@end
