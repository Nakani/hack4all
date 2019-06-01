//
//  ProfileViewController.m
//  Example
//
//  Created by Cristiano Matte on 30/05/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ProfileViewController.h"
#import "Lib4all.h"
#import "LayoutManager.h"
#import "Services.h"
#import "CardsTableViewController.h"
#import <ZDCChat/ZDCChat.h>
#import "UIImage+Color.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *topRoundView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation ProfileViewController

- (instancetype)init {
    return [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ProfileVC"];
}

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Configura navigation bar para deixá-la transparente
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

// MARK: - Actions

- (IBAction)logoutButtonTouched {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sair"
                                                                   message:@"Quer mesmo sair?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sair" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Services *service = [[Services alloc] init];
        
        service.successCase = ^(NSDictionary *response){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Lib4all.sharedInstance.userStateDelegate userDidLogout];
                [self closeViewController];
            });
        };
        
        service.failureCase = ^(NSString *cod, NSString*msg){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Lib4all.sharedInstance.userStateDelegate userDidLogout];
                [self closeViewController];
            });
        };

        [[[ZDCChat instance] api] endChat];
        [service logout];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonHighlight:(UIButton*)sender {
    self.logoutButton.layer.borderColor = [[[LayoutManager sharedManager] gradientColor] CGColor];
}

- (void)buttonNormal:(UIButton*)sender {
    self.logoutButton.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
}

// MARK: - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 47.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileOptionCell" forIndexPath:indexPath];
    UIImageView *icon     = [cell.contentView viewWithTag:1];
    UILabel* label        = [cell.contentView viewWithTag:2];
    UIImageView* arrow    = [cell.contentView viewWithTag:3];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    label.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    label.textColor = [[LayoutManager sharedManager] darkFontColor];
    arrow.image = [arrow.image withColor:[LayoutManager sharedManager].primaryColor];
    
    switch (indexPath.row) {
        case 0:
            label.text = @"Extrato";
            icon.image = [UIImage lib4allImageNamed:@"iconChartProfile"];
            break;
        case 1:
            label.text = @"Assinaturas";
            icon.image = [UIImage lib4allImageNamed:@"iconSubscription"];
            break;
        case 2:
            label.text = @"Dados pessoais";
            icon.image = [UIImage lib4allImageNamed:@"iconUserProfile"];
            break;
//        case 3:
//            label.text = @"Endereços";
//            icon.image = [UIImage lib4allImageNamed:@"iconAddressProfile"];
//            break;
        case 3://4:
            label.text = @"Meus cartões";
            icon.image = [UIImage lib4allImageNamed:@"iconCardProfile"];
            break;
        case 4:
            label.text = @"Perfil família";
            icon.image = [UIImage lib4allImageNamed:@"iconFamilyProfile"];
            break;
        case 5:
            label.text = @"Configurações";
            icon.image = [UIImage lib4allImageNamed:@"iconSettingsProfile"];
            break;
        case 6:
            label.text = @"Ajuda";
            icon.image = [UIImage lib4allImageNamed:@"iconHelp"];
            break;
        case 7:
            label.text = @"Sobre";
            icon.image = [UIImage lib4allImageNamed:@"iconInfoProfile"];
            break;
        default:
            break;
    }
    
    icon.image = [icon.image withColor:[LayoutManager sharedManager].primaryColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *viewControllerIdentifier;
    
    switch (indexPath.row) {
        case 0:
            viewControllerIdentifier = @"CompleteTransactionStatementViewController";
            break;
        case 1:
            viewControllerIdentifier = @"SubscriptionsViewController";
            break;
        case 2:
            viewControllerIdentifier = @"MyDataViewController";
            break;
        case 3://4:
            viewControllerIdentifier = @"CardsTableViewController";
            break;
        case 4:
            viewControllerIdentifier = @"FamilyProfileTableViewController";
            break;
        case 5:
            viewControllerIdentifier = @"SettingsTableViewController";
            break;
        case 6:
//            viewControllerIdentifier = @"HelpViewController";
            [Lib4all sharedInstance].showChat;
            break;
        case 7:
            viewControllerIdentifier = @"AboutViewController";
            break;
        default:
            break;
    }
    
    // Instancia viewController se o identificador foi setado
    UIViewController* viewController;
    if (viewControllerIdentifier) {
        viewController = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                          instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    }

    // Exibe o viewController se foi possível obte-lo da storyboard e se há navigationController
    if (viewController && self.navigationController) {
        // Caso vá exibir a lista de cartões, seta a ação a ser performada na seleção de cartões
        if ([viewController class] == [CardsTableViewController class]) {
            ((CardsTableViewController *)viewController).onSelectCardAction = OnSelectCardShowActionSheet;
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// MARK: - Layout

- (void)configureLayout {
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
        
    // Configura bar button para fechar a view
    UIBarButtonItem *closeButton =[[UIBarButtonItem alloc] init];
    closeButton.target  = self;
    closeButton.title   = @"Fechar";
    closeButton.action  = @selector(closeViewController);
    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationController.title = @"";
    self.navigationItem.title = @"";
    
    // Configura layout da table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [[LayoutManager sharedManager] primaryColor];
    
    // Configura layout da view redonda com foto/logo da 4all
    [self.topRoundView layoutIfNeeded];
    self.topRoundView.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    self.topRoundView.layer.cornerRadius = self.topRoundView.frame.size.height / 2;
    
    // Configura o botão SAIR
    self.logoutButton.layer.borderWidth = 1.0;
    self.logoutButton.layer.cornerRadius = 5.0;
    self.logoutButton.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
    [self.logoutButton setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[[LayoutManager sharedManager] gradientColor] forState:UIControlStateHighlighted];
    self.logoutButton.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    [self.logoutButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.logoutButton addTarget:self action:@selector(buttonNormal:) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
}

@end
