//
//  SettingsTableViewController.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 12/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "LayoutManager.h"
#import "BaseNavigationController.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "Preferences.h"
#import "Lib4allPreferences.h"
#import "User.h"
#import "ForgotPasswordViewController.h"
#import "Lib4allInfo.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Lib4all.h"

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *receiveByEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushNotificationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *touchIdLabel;
@property (weak, nonatomic) IBOutlet UISwitch *receivePaymentEmailsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *touchIdSwitch;
@property (weak, nonatomic) IBOutlet UILabel *touchIdDescription;
@property (weak, nonatomic) IBOutlet UILabel *termsAndPrivacyLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UIImageView *termsDisclosureImageView;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *websiteDisclosureImageView;
@property (weak, nonatomic) IBOutlet UILabel *appContactLabel;
@property (weak, nonatomic) IBOutlet UIImageView *appContactDisclosureImageView;

@property BOOL showsNotificatioOption;
@property BOOL isNotificationEnabled;
@property BOOL showsTouchIdOption;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([Lib4allPreferences sharedInstance].isNotificationHabilitatedBlock && [Lib4allPreferences sharedInstance].didChangeNotificationSwitchBlock) {
            _showsNotificatioOption = YES;
            _isNotificationEnabled = [Lib4allPreferences sharedInstance].isNotificationHabilitatedBlock();
        } else {
            _showsNotificatioOption = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            _pushNotificationsSwitch.on = _isNotificationEnabled;
            [self.tableView reloadData];
        });
    });
    
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        _showsTouchIdOption = YES;
    }
    
    [_pushNotificationsSwitch addTarget:self action:@selector(didChangeNotificationSwitch) forControlEvents:UIControlEventTouchUpInside];
    
    _receivePaymentEmailsSwitch.on = [[Preferences sharedPreferences] receivePaymentEmails];
    
    _touchIdSwitch.on = [[User sharedUser] isTouchIdEnabled];
    [_touchIdSwitch addTarget:self action:@selector(didChangeTouchIdSwitch) forControlEvents:UIControlEventTouchUpInside];
    
    _versionLabel.text = [NSString stringWithFormat:@"Versão %@", Lib4allVersion];
    
    Services *service = [[Services alloc] init];
    
    service.successCase = ^(NSDictionary *response) {
        BOOL receivePaymentEmails = [[response objectForKey:ReceivePaymentEmailsKey] boolValue];
        [self.receivePaymentEmailsSwitch setOn:receivePaymentEmails animated:YES];
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg){ };
    
    [service getAccountPreferences:@[ReceivePaymentEmailsKey]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Configurações";
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    if (self.receivePaymentEmailsSwitch.on != [[Preferences sharedPreferences] receivePaymentEmails]) {
        NSDictionary *preferences;
        if (self.receivePaymentEmailsSwitch.on) {
            preferences = @{ReceivePaymentEmailsKey: @YES};
        } else {
            preferences = @{ReceivePaymentEmailsKey: @NO};
        }
        
        Services *service = [[Services alloc] init];
        service.successCase = ^(NSDictionary *response) { };
        service.failureCase = ^(NSString *cod, NSString *msg) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Fechar"
                                                  otherButtonTitles:nil];
            [alert show];
        };
        
        [service setAccountPreferences:preferences];
    }
    [[User sharedUser] setIsTouchIdEnabled:self.touchIdSwitch.on];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.tableView setScrollEnabled:(self.tableView.contentSize.height >= self.tableView.frame.size.height)];
}

- (void) didChangeTouchIdSwitch {
    if(_touchIdSwitch.on) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Insira a sua senha para ativar o Touch ID"
                                                                                  message: @""
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Senha";
            textField.secureTextEntry = YES;
        }];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField *passwordTxtField = textfields[0];
            
            Services *service = [[Services alloc] init];
            service.successCase = ^(NSDictionary *response) {
                if(![response[@"isPasswordCorrect"] boolValue]){
                    [self passwordIsIncorrect:alertController];
                }
            };
            service.failureCase = ^(NSString *cod, NSString *msg) {
               [self passwordIsIncorrect:alertController];
            };
            [service checkPassword:passwordTxtField.text];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Esqueci minha senha" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_touchIdSwitch setOn:false];
            ForgotPasswordViewController *forgotPasswordViewController = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
            [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_touchIdSwitch setOn:false];
        }]];
        
        [self presentViewController:alertController animated:YES completion: nil];
    }
}

- (void) passwordIsIncorrect:(UIAlertController *)alertController {
    
    alertController.message = @"Senha inválida!";
    
    
    UITextField *textField = alertController.textFields[0];
    textField.text = @"";
    UIView *container = textField.superview;
    UIView *effectView = container.superview.subviews[0];
    
    if (effectView && [effectView class] == [UIVisualEffectView class]){
        container.layer.borderWidth = 0.7;
        container.layer.borderColor = [[UIColor redColor]CGColor];
        [effectView removeFromSuperview];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) didChangeNotificationSwitch {
    [Lib4allPreferences sharedInstance].didChangeNotificationSwitchBlock(_pushNotificationsSwitch.isOn);
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Layout
- (void)configureLayout {
    
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(60, 0, 0, 0)];
    
    _receiveByEmailLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _receiveByEmailLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _pushNotificationsLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _pushNotificationsLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _touchIdLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _touchIdLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _touchIdDescription.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].midFontSize];
    _touchIdDescription.textColor = [[LayoutManager sharedManager] darkFontColor];
    _termsAndPrivacyLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _termsAndPrivacyLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _versionLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _versionLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _logoutLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _logoutLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _appContactLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _appContactLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _websiteLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    _websiteLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    _receivePaymentEmailsSwitch.onTintColor = [LayoutManager sharedManager].primaryColor;
    _touchIdSwitch.onTintColor = [LayoutManager sharedManager].primaryColor;
    _pushNotificationsSwitch.onTintColor = [LayoutManager sharedManager].primaryColor;
    
    
    
    _termsDisclosureImageView.image = [_termsDisclosureImageView.image withColor:[LayoutManager sharedManager].primaryColor];
    
    _appContactDisclosureImageView.image = [_appContactDisclosureImageView.image withColor:[LayoutManager sharedManager].primaryColor];
    
    _websiteDisclosureImageView.image = [_websiteDisclosureImageView.image withColor:[LayoutManager sharedManager].primaryColor];
    
    // Configura botão de fechar se a view for apresentada modalmente
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1 && !self.hideCloseButton) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 3 || (indexPath.row == 4 && [Lib4allPreferences sharedInstance].appWebsiteURL) || (indexPath.row == 5 && [Lib4allPreferences sharedInstance].appContactURL) || (indexPath.row == 7 && _isLogoutEnabled)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 3) {
        [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] termsOfServiceURL]];
    }
    if(indexPath.row == 4) {
        [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] appWebsiteURL]];
    }
    if(indexPath.row == 5) {
        [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] appContactURL]];
    }
    if(indexPath.row == 7 && _isLogoutEnabled) {
        [[Lib4all sharedInstance] callLogout:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!_showsNotificatioOption && indexPath.row == 0) {
        return 0;
    }
    if(indexPath.row == 2) {
        if(!_showsTouchIdOption) {
            return 0;
        }
        return 100;
    }
    if (indexPath.row == 4 && ![Lib4allPreferences sharedInstance].appWebsiteURL) {
        return 0;
    }
    if (indexPath.row == 5 && ![Lib4allPreferences sharedInstance].appContactURL) {
        return 0;
    }
    if(indexPath.row == 7 && !_isLogoutEnabled) {
        return 0;
    }
    return 60;
}

@end
