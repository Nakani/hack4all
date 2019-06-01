//
//  FamilyProfileTableViewController.m
//  Example
//
//  Created by Adriano Soares on 14/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "FamilyProfileTableViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "FamilyDetailsViewController.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "UIImage+Color.h"
#import "UIImageView+WebCache.h"
#import "LoadingViewController.h"

@interface FamilyProfileTableViewController ()

@property (strong, nonatomic) NSArray *sharedCards;
@property (weak, nonatomic) IBOutlet UILabel *tableViewHeaderLabel;

@property (strong, nonatomic) NSMutableArray *sharedWithMeCards;
@property (strong, nonatomic) NSMutableArray *sharedByMeCards;

@end

@implementation FamilyProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.sharedCards = [[CreditCardsList sharedList] getSharedCards];
    self.sharedWithMeCards  = [[NSMutableArray alloc] init];
    self.sharedByMeCards    = [[NSMutableArray alloc] init];

    [self countSharedCards:self.sharedCards];
    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self refreshData];
    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Perfil Família";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        [self.refreshControl endRefreshing];
    };
    
    service.successCase = ^(NSDictionary *response){
        self.sharedCards = [[CreditCardsList sharedList] getSharedCards];
        
        NSArray *modifications = [[CreditCardsList sharedList] checkSharingModifications];
        if ([modifications count] > 0) {
            [self alertModifications:modifications];
        }
        
        [self countSharedCards:self.sharedCards];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };
    
    [service listCards];
}

- (void) countSharedCards:(NSArray *) sharedCards {
    [self.sharedWithMeCards removeAllObjects];
    [self.sharedByMeCards removeAllObjects];
    
    for (int i = 0; i < sharedCards.count; i++) {
        CreditCard *card = (CreditCard *)sharedCards[i];
        if ([[card.sharedDetails[0] valueForKey:@"provider"] boolValue]) {
            for (int j = 0; j < card.sharedDetails.count; j++) {
                NSDictionary *cardDictionary = @{@"card": card,
                                                 @"sharedDetails": card.sharedDetails[j] };
                [self.sharedByMeCards addObject:cardDictionary];
            }

        } else {
            if ([[card.sharedDetails[0] valueForKey:@"status"] integerValue] == 0) {
                [self showAlert: card];
            } else if ([[card.sharedDetails[0] valueForKey:@"status"] integerValue] == 1) {
                [self.sharedWithMeCards addObject:card];
            }
        }
    }


}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 1 && indexPath.row == [tableView numberOfRowsInSection:1]-1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"addFamilyCell" forIndexPath:indexPath];
    
    
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"familyCell" forIndexPath:indexPath];
        
        
        UIImageView *brandImageView = (UIImageView *)[cell viewWithTag:1];
        
        NSDictionary *sharedDetails;
        CreditCard *card;
        if (indexPath.section == 0) {
            card = self.sharedWithMeCards[indexPath.row];
            sharedDetails = card.sharedDetails[0];
        } else {
            card = [self.sharedByMeCards[indexPath.row] objectForKey:@"card"];
            sharedDetails = [self.sharedByMeCards[indexPath.row] objectForKey:@"sharedDetails"];
        }
        
        [brandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]] placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5];
        nameLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].midFontSize];
        nameLabel.text = [sharedDetails valueForKey:@"identifier"];
       
        UILabel *cardNumberLabel = (UILabel *)[cell viewWithTag:2];
        cardNumberLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
        cardNumberLabel.text = [card getMaskedPan];

        
        UIView *viewCard = (UIView *)[cell viewWithTag:4];
        viewCard.layer.cornerRadius        = 5;
        viewCard.layer.shadowOffset        = CGSizeMake(0, 1);
        viewCard.layer.shadowRadius        = 2;
        viewCard.layer.shadowColor         = [[LayoutManager sharedManager] darkGray].CGColor;
        viewCard.layer.shadowOpacity       = 0.5;
        
        UIImageView *disclosure = (UIImageView *)[cell viewWithTag:6];
        disclosure.image = [disclosure.image withColor:[LayoutManager sharedManager].primaryColor];
    }
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
    
    UILabel *headerLabel = (UILabel *)[cell viewWithTag:1];
    headerLabel.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] regularFontSize]];
    headerLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    if (section == 0) {
        headerLabel.text = @"Cartões compartilhados comigo";
    } else {
        headerLabel.text = @"Cartões que eu compartilhei";
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.sharedWithMeCards.count == 0) {
        return 0.0;
    }
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FamilyDetailsViewController* vc = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                          instantiateViewControllerWithIdentifier:@"FamilyDetailsViewController"];
    
    
    // Exibe o viewController se foi possível obte-lo da storyboard e se há navigationController
    if (vc && self.navigationController) {
        
        CreditCard *card;
        NSDictionary *sharedDetails;
        if (indexPath.section == 0) {
            card = self.sharedWithMeCards[indexPath.row];
            sharedDetails = card.sharedDetails[0];
        } else {
            card = [self.sharedByMeCards[indexPath.row] objectForKey:@"card"];
            sharedDetails = [self.sharedByMeCards[indexPath.row] objectForKey:@"sharedDetails"];
        }
        
        vc.cardID = card.cardId;
        vc.sharedDetails = [sharedDetails mutableCopy];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger familyMembers = ((section == 1) ? self.sharedByMeCards.count : self.sharedWithMeCards.count);
    
    return familyMembers + ((section == 1) ? 1 : 0);
}




- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Perfil Família";
    
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

    self.tableViewHeaderLabel.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    self.tableViewHeaderLabel.textColor = [[LayoutManager sharedManager] darkFontColor];

    // Configura botão de fechar se a view for apresentada modalmente
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}

- (void) alertModifications: (NSArray *) modifications {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    for (int i = 0; i < modifications.count; i++) {
        NSString *msg = @"";
        if ([[modifications[i] valueForKey:@"type"] isEqualToString:@"ownerDeletedCard"]) {
            msg = [NSString stringWithFormat:@"%@ deixou de compartilhar o cartão com você.", [modifications[i] valueForKey:@"identifier"]];
        }
        if ([[modifications[i] valueForKey:@"type"] isEqualToString:@"recipientRefusedCard"]) {
            NSString *balance = [formatter stringFromNumber: [NSNumber numberWithFloat:[[modifications[i] valueForKey:@"balance"] doubleValue]/100]];;
            msg = [NSString stringWithFormat:@"%@ recusou receber o limite mensal de %@.", [modifications[i] valueForKey:@"identifier"], balance];
        }
        if ([[modifications[i] valueForKey:@"type"] isEqualToString:@"recipientAcceptedCard"]) {
            NSString *balance = [formatter stringFromNumber: [NSNumber numberWithFloat:[[modifications[i] valueForKey:@"balance"] doubleValue]/100]];;
            msg = [NSString stringWithFormat:@"%@ aceitou receber o limite mensal de %@.", [modifications[i] valueForKey:@"identifier"], balance];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Perfil família"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    

}

- (void) showAlert:(CreditCard *) card {
    NSString *limit = [card.sharedDetails[0] valueForKey:@"recurringBalance"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    limit = [[formatter stringFromNumber: [NSNumber numberWithFloat:[limit doubleValue]/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    

    NSString *name  = [card.sharedDetails[0] valueForKey:@"identifier"];
    NSString *message = [NSString stringWithFormat: @"%@ quer compartilhar um limite mensal de %@. Você aceita?", name, limit];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Perfil família"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sim"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    Services *service = [[Services alloc] init];
                                    LoadingViewController *loader = [[LoadingViewController alloc] init];
                                    
                                    service.failureCase = ^(NSString *cod, NSString *msg) {
                                        [loader finishLoading:nil];
                                    };
                                    
                                    service.successCase = ^(NSDictionary *response) {
                                        [loader finishLoading:nil];
                                        [self refreshData];
                                    };
                                    
                                    [service acceptSharedCard:card.cardId];
                                    
                                    [loader startLoading:self title:@"Aguarde..."];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Não"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   Services *service = [[Services alloc] init];
                                   LoadingViewController *loader = [[LoadingViewController alloc] init];
                                   
                                   service.failureCase = ^(NSString *cod, NSString *msg) {
                                       [loader finishLoading:nil];
                                   };
                                   
                                   service.successCase = ^(NSDictionary *response) {
                                       [loader finishLoading:nil];
                                   };
                                   
                                   [service deleteSharedCard:card.cardId custumerId:[card.sharedDetails[0] valueForKey:CustomerIdKey]];
                                   
                                   [loader startLoading:self title:@"Aguarde..."];
                               }];
    
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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
