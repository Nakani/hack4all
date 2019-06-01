//
//  SISUTokenSmsDataField.m
//  Example
//
//  Created by 4all on 17/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SISUTokenSmsDataField.h"
#import "GenericDataViewController.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "Lib4all.h"
#import "LayoutManager.h"

@implementation SISUTokenSmsDataField

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
        _title = @"Insira o código que enviamos por SMS para \nconfirmar as informações";
        _textFieldPlaceHolder = @"Código SMS";
        _textFieldImageName = @"iconFullName";
        _textFieldWithErrorImageName = @"iconFullName";
        _serverKey = @"fullName";
        _keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (void)completeLogin:(UIViewController*)vc code:(NSString *)code {
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);
    SignFlowController *flowController = dataController.signFlowController;
    
    Services *service = [[Services alloc] init];
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    // Completion comum para os casos em que há algum erro nas requisições de dados do usuário
    void (^failureCase)(NSString *, NSString *) = ^(NSString *cod, NSString *msg) {
        // Informa o usuário sobre uma falha no login
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg//@"Falha na conexão. Tente novamente mais tarde."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // Faz logout para remover todos os dados do usuários já baixados e fecha a tela de challenge
            //[[Lib4all sharedInstance] callLogout:nil];
            //[self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:ok];
        [loading finishLoading:^{
            [vc presentViewController:alert animated:YES completion:nil];
        }];
    };
    
    // O último passo para finalizar o login é obter a foto de usuário
    void (^getAccountPhoto)(void) = ^{
        Services *getAccountPhotoService = [[Services alloc] init];
        
        getAccountPhotoService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountPhotoService.successCase = ^(NSDictionary *response) {
            if ([[Lib4all sharedInstance].userStateDelegate respondsToSelector:@selector(userDidLogin)]) {
                [[Lib4all sharedInstance].userStateDelegate userDidLogin];
            }
            
            [loading finishLoading:^{
                [flowController viewControllerDidFinish:vc];
            }];
            return;
        };
        
        [getAccountPhotoService getAccountPhoto];
    };
    
    
    // O quarto passo para finalizar o login é obter as preferências de usuário
    void (^getAccountPreferences)(void) = ^{
        Services *getAccountPreferenceService = [[Services alloc] init];
        
        getAccountPreferenceService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountPreferenceService.successCase = ^(NSDictionary *response) {
            getAccountPhoto();
            return;
        };
        
        [getAccountPreferenceService getAccountPreferences:@[ReceivePaymentEmailsKey]];
    };
    
    // O terceiro passo da finalização de login é obter os cartões do usuário
    void (^getAccountCards)(void) = ^{
        Services *getAccountCardsService = [[Services alloc] init];
        
        getAccountCardsService.successCase = ^(NSDictionary *response){
            // Em caso de sucesso, chama o último passo da finalização de login
            getAccountPreferences();
        };
        
        getAccountCardsService.failureCase = ^(NSString *cod, NSString *msg){
            failureCase(cod, msg);
        };
        
        [getAccountCardsService listCards];
    };
    
    // O segundo passo da finalização de login é obter os dados do usuário
    void (^getAccountData)(void) = ^{
        Services *getAccountDataService = [[Services alloc] init];
        
        getAccountDataService.failureCase = ^(NSString *cod, NSString *msg) {
            failureCase(cod, msg);
        };
        
        getAccountDataService.successCase = ^(NSDictionary *response) {
            // Em caso de sucesso, chama o terceiro passo da finalização de login
            getAccountCards();
        };
        
        [getAccountDataService getAccountData:@[CustomerIdKey, PhoneNumberKey, EmailAddressKey, CpfKey, FullNameKey, BirthdateKey, EmployerKey, JobPositionKey, TotpKey]];
    };
    
    // O primeiro passo da finalização de login é verificar o challenge
    [loading startLoading:vc title:@"Aguarde..."];
    
    service.successCase = ^(NSDictionary *data) {
        getAccountData();
    };
    
    service.failureCase = ^(NSString *code, NSString *msg) {
        failureCase(code, msg);
    };
    
    
    [service completeLoginWithChallenge:code accountData:flowController.accountData socialData:flowController.socialSignInData];

}

- (void) validateChallenge:(NSString *)challenge usingController:(GenericDataViewController *)dataController{
    Services *client = [[Services alloc] init];
    
    client.successCase = ^(id data) {
        //TODO: Aguardar chamada pra confirmar, por enquanto só segue o baile
        
        [dataController.loadingView finishLoading:^{
            [dataController.signFlowController setEnteredChallenge:challenge];
            
            //Para testar fluxo com telefone já validado descomentar linha abaixo
            [dataController.signFlowController setValidatedNumber:dataController.signFlowController.enteredPhoneNumber];
            
            [dataController.signFlowController viewControllerDidFinish:dataController];
        }];
        
        

    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        
        [dataController.loadingView finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            
            [modal show:dataController title:@"Atenção" description:errorMessage imageMode:Error buttonAction:nil];
        }];
        
    };
    
    [dataController.loadingView startLoading:dataController title:@"Atenção"];
    [client validateSmsOrEmailWithChallenge:challenge];
}

- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    
    GenericDataViewController *dataController = ((GenericDataViewController *)vc);
    if (dataController.signFlowController.isLogin) {
        [self completeLogin:vc code:data];
    } else {
        [self validateChallenge:data usingController:dataController];
    }

}

- (BOOL)isDataValid:(NSString *)data {
    return data.length == 6;
}

-(void)setAttrTitleForString:(NSString *)value{
    _attrTitle = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange range = [_title rangeOfString:@"SMS"];
    LayoutManager *layout = [LayoutManager sharedManager];
    [_attrTitle addAttribute: NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:range];
}

@end
