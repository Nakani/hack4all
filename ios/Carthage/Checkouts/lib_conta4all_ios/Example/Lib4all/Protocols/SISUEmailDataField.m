//
//  SISUEmailDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUEmailDataField.h"
#import "Lib4all.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "GenericDataViewController.h"
#import "LayoutManager.h"

@implementation SISUEmailDataField

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
        _title = @"Ótimo, qual é o seu email?";
        _subTitle = @"Relaxa, não mandamos spam :)";
        _textFieldPlaceHolder = @"E-mail";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypeEmailAddress;
        NSDictionary *customerData = [Lib4all customerData];
        if (customerData[@"emailAddress"] != nil) {
            _preSettedField = customerData[@"emailAddress"];
        }
    }
    return self;
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {

    GenericDataViewController *dataController = ((GenericDataViewController *)vc);
    Services *service = [[Services alloc] init];
    
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        /*
         * Caso o erro seja "Não há usuário com o telefone/email informado",
         * redireciona para a tela de cadastro de cpf(proxima controller do fluxo nesse caso).
         * Para qualquer outro erro, exibe um alerta.
         */
        dataController.signFlowController.isLogin = NO;

        if ([cod isEqualToString:@"3.25"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataController.loadingView finishLoading:^{
                    [dataController.signFlowController.accountData setValue:data forKey:EmailAddressKey];
                    [dataController.signFlowController setValidatedEmail:data];
                    [dataController.signFlowController viewControllerDidFinish:vc];
                }];
            });
        } else {
            [dataController.loadingView finishLoading:^{

                [[[PopUpBoxViewController alloc] init] show:vc
                                                      title:@"Atenção"
                                                description:msg
                                                  imageMode:Error
                                               buttonAction:nil];
            }];

        }
    };
    
    service.successCase = ^(NSDictionary *response){

        dataController.signFlowController.isLogin = YES;
        
        [dataController.signFlowController.accountData setValue:response[PhoneNumberKey] forKey:PhoneNumberKey];
        [dataController.signFlowController.accountData setValue:response[EmailAddressKey] forKey:EmailAddressKey];


        [dataController.loadingView finishLoading:^{
            [[[PopUpBoxViewController alloc] init] show:vc
                                                  title:@"Atenção"
                                            description:@"E-mail já cadastrado."
                                              imageMode:Error buttonAction:^{
                                                  dataController.signFlowController.isLogin = YES;
                                                  [dataController.signFlowController viewControllerDidFinish:vc];
                                              }];
        }];
    };
    
    
    //Se já validado, não faz chamadas e segue para inserção de CPF
    if (dataController.signFlowController.validatedEmail != nil &&
        [dataController.signFlowController.validatedEmail isEqualToString:data]) {
        dataController.signFlowController.isEmailValidated = YES;
        dataController.signFlowController.isLogin = NO;
        [dataController.signFlowController viewControllerDidFinish:vc];
    }else{
        dataController.signFlowController.isEmailValidated = NO;
        dataController.signFlowController.isLogin = NO;
        [dataController.loadingView startLoading:vc title:@"Aguarde..."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[User sharedUser] setCurrentState:UserStateOnCreation];
        });
        
        [service startLoginWithIdentifier:data requiredData:nil isCreation:YES];
    }
}


- (BOOL)isDataValid:(NSString *)data {
    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$"
                                                                                options:0
                                                                                  error:nil];
    
    if ([emailRegex numberOfMatchesInString:data options:0 range:NSMakeRange(0, data.length)] > 0) {
        return YES;
    }
    
    return NO;
}

- (NSString *)serverFormattedData:(NSString *)data {
    return [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [value rangeOfString:@"email?"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}

@end
