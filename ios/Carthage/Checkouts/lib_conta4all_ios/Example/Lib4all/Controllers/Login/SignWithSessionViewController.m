//
//  SignWithSessionViewController.m
//  Example
//
//  Created by Adriano Soares on 08/02/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SignWithSessionViewController.h"
#import "UIImage+Color.h"
#import "LayoutManager.h"
#import "MainActionButton.h"
#import "LoadingViewController.h"
#import "Lib4all.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "UIImage+Lib4all.h"
#import "AnalyticsUtil.h"
#import "Lib4allPreferences.h"

@interface SignWithSessionViewController ()
@property (weak, nonatomic) IBOutlet MainActionButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *otherLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;

@end

@implementation SignWithSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AnalyticsUtil createScreenViewWithName:@"compartilhamento_sessao"];
    
    if (self.fullName) {
        NSArray *nameParts = [self.fullName componentsSeparatedByString:@" "];
        if (nameParts.count > 0) {
            self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"@nome" withString:nameParts[0]];
        } else {
            self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"@nome" withString:@""];
        }
    }
    
    self.subtitleLabel.text = @"Notamos que você já possui uma Conta 4all.\n @email\n @phone\n\n Deseja continuar com essa conta?";
    if (self.email) {
        self.subtitleLabel.text = [self.subtitleLabel.text stringByReplacingOccurrencesOfString:@"@email" withString:self.email];
    } else {
        self.subtitleLabel.text = [self.subtitleLabel.text stringByReplacingOccurrencesOfString:@"@email" withString:@""];

    }
    
    if (self.phone) {
        self.subtitleLabel.text = [self.subtitleLabel.text stringByReplacingOccurrencesOfString:@"@phone" withString:self.phone];
    } else {
        self.subtitleLabel.text = [self.subtitleLabel.text stringByReplacingOccurrencesOfString:@"@phone" withString:@""];
    }

    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    self.subtitleLabel.text = [self.subtitleLabel.text stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
    
    [self.loginButton setTitle:@"Continuar com a mesma conta" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
    
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    if([Lib4allPreferences sharedInstance].appIcon) {
        _logoImageView.image = [Lib4allPreferences sharedInstance].appIcon;
    }
    
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureLayout {
    // Configura view
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    
    
    self.titleLabel.textColor = [layoutManager primaryColor];
    self.titleLabel.font = [layoutManager fontWithSize:layoutManager.titleFontSize];
    

    self.subtitleLabel.textColor = [layoutManager darkFontColor];
    self.subtitleLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    NSMutableAttributedString *attributedString = [self.subtitleLabel.attributedText mutableCopy];
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    
    [attributedString addAttribute:NSFontAttributeName
                             value:[layoutManager boldFontWithSize:layoutManager.subTitleFontSize]
                             range:[self.subtitleLabel.text rangeOfString:[NSString stringWithFormat:@"Conta %@", balanceTypeFriendlyName]]];
    
    self.subtitleLabel.attributedText = attributedString;
    
    
    self.otherLoginButton.tintColor = [layoutManager darkFontColor];
    self.otherLoginButton.titleLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    
    self.statusBarView.backgroundColor = [layoutManager primaryColor];
    
}

- (IBAction)loginWithSessionButton:(id)sender {
    Services *service = [[Services alloc] init];
    
    LoadingViewController *loader = [[LoadingViewController alloc] init];
    
    [AnalyticsUtil createEventWithCategory:@"account" action:@"login" label:@"login with same account" andValue:nil];

    
    // Completion comum para os casos em que há algum erro nas requisições de dados do usuário
    void (^failureCase)(NSString *, NSString *) = ^(NSString *cod, NSString *msg) {
        // Informa o usuário sobre uma falha no login
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:@"Falha na conexão. Tente novamente mais tarde."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // Faz logout para remover todos os dados do usuários já baixados e fecha a tela de challenge
            [[Lib4all sharedInstance] callLogoutWithoutAction:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:ok];
        [loader finishLoading:^{
            [self presentViewController:alert animated:YES completion:nil];
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
            
            [loader finishLoading:^{
                self.signFlowController.isLogin = YES;
                [_signFlowController viewControllerDidFinish:self];
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
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        failureCase(cod, msg);
        
    };
    
    service.successCase = ^(NSDictionary *response) {
        getAccountData();
    };
    
    [service refreshSessionWithSessionToken:self.sessionToken];
    
    [loader startLoading:self title:@"Aguarde..."];

}

- (IBAction)loginWithOtherAccountButton:(id)sender {
    [AnalyticsUtil createEventWithCategory:@"account" action:@"login" label:@"login with another account" andValue:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
