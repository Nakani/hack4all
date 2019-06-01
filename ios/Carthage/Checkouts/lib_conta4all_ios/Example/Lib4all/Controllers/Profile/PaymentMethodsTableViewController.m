//
//  PaymentMethodsTableViewController.m
//  Example
//
//  Created by Luciano Bohrer on 18/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PaymentMethodsTableViewController.h"
#import "BEMCheckBox.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"
#import "LoadingViewController.h"
#import "BaseNavigationController.h"
#import "Lib4allPreferences.h"
#import "Lib4all.h"
#import "PrePaidServices.h"
#import "CreditCardTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AnalyticsUtil.h"

@interface PaymentMethodsTableViewController () <BEMCheckBoxDelegate>
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSMutableArray *ownedCardList;
@property (strong, nonatomic) NSMutableArray *cardListArray;
@property (strong, nonatomic) NSString *strAmount;
@property (strong, nonatomic) NSArray* acceptedPaymentTypes;
@end

@implementation PaymentMethodsTableViewController

static NSString* const kNavigationTitle = @"Formas de pagamento";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
    self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];
    self.acceptedPaymentTypes = [Lib4all acceptedPaymentTypes];
    
    [self setupController];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationItem.title = kNavigationTitle;
    
    [self updateBalance];
    
    self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
    self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];
    
    [self filterCards];
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    self.navigationItem.title = @"";
}

-(void)viewWillAppear:(BOOL)animated {
    
    [((BaseNavigationController *) self.navigationController) configureLayout];
}

- (void) setupController{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeController:)];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.title = kNavigationTitle;
    [self refreshData];
    [self filterCards];
}

- (IBAction)closeController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) updateBalance{

    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        _strAmount = @"Não foi possível obter saldo";
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    services.successCase = ^(NSDictionary *response) {
        double balance = [[response objectForKey:@"balance"] doubleValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        _strAmount = [formatter stringFromNumber: [NSNumber numberWithFloat:balance/100]];
        _strAmount = [_strAmount stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    _strAmount = @"Buscando saldo...";
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [services balance];
}

- (void)deleteCard:(NSIndexPath *)indexPath {

    CreditCard *card = [self.cardListArray objectAtIndex:indexPath.row];
    
    Services *services = [[Services alloc] init];
    LoadingViewController *loadingView = [[LoadingViewController alloc] init];
    BOOL wasDefaultCard = card.isDefault;
    BOOL wasLastCard = [self.cardListArray count] == 1;
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [loadingView finishLoading:^{
            if ([cod isEqualToString:@"18.13"]) {
                NSString *message = @"Este cartão possui assinaturas associadas, para prosseguir você precisa associa-lás a outro cartão.\n\n Deseja prosseguir com a exclusão?";
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Sim"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self selectCardForSubscriptions:card.cardId andLastDigits:card.lastDigits];
                                            }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"Não"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               return;
                                           }];
                
                [alert addAction:noButton];
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"Fechar"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }
        }];
    };
    
    services.successCase = ^(NSDictionary *response) {
        [loadingView finishLoading:^{
            
            [AnalyticsUtil logEventWithName:@"excluir_cartao" andParameters:nil];
            
            if (wasDefaultCard && !wasLastCard) {
                [self updateDefaultCard];
            }
            [self.cardListArray removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self refreshData];
        }];
    };
    
    
    NSString *message = @"Este cartão será excluído.\n\n Deseja prosseguir com a exclusão?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sim"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [loadingView startLoading:self title:@"Aguarde..."];
                                    if (card.isShared && ![[card.sharedDetails[0] valueForKey:@"provider"] boolValue] ) {
                                        NSString *customerId = [card.sharedDetails[0] valueForKey:@"customerId"];
                                        [services deleteSharedCard:card.cardId custumerId:customerId];
                                    } else {
                                        [services deleteCardWithCardID:card.cardId];
                                    }

                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Não"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   return;
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) filterCards {
    if (self.filterCardID) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            CreditCard *card = (CreditCard *)evaluatedObject;
            if ([self.filterCardID containsObject:card.cardId]) {
                return NO;
            }
            return YES;
        }];
        [self.ownedCardList filterUsingPredicate:predicate];
        [self.cardListArray filterUsingPredicate:predicate];
    }
}

- (void)updateDefaultCard {
    // Busca o novo cartão padrão caso o cartão default tenha sido excluído
    
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    service.successCase = ^(NSDictionary *response) {
        CreditCardsList *cardsList = [CreditCardsList sharedList];
        CreditCard *defaultCard = [cardsList getDefaultCard];
        NSUInteger row = [self.cardListArray indexOfObject:defaultCard];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            ((UIImageView *)[cell viewWithTag:3]).hidden = NO;
        }];
    };
    
    [service getCardDetailsWithCardID:nil];
}

- (void)setDefaultCard:(CreditCard *)card checkForSubsciptions:(BOOL)checkSubscriptions  {
    /*
     * Não permite que o usuário selecione um cartão de modalidade ou bandeira
     * não aceitas pelo aplicativo como cartão padrão
     */
    if (![self cardIsAccepted:card]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:@"Este cartão não é aceito neste aplicativo. Por favor, escolha outro cartão."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    Services *services = [[Services alloc] init];
    LoadingViewController *loadingView = [[LoadingViewController alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [[CreditCardsList sharedList] setDefaultCardWithCardID:card.cardId];
        [self.tableView reloadData];
        [loadingView finishLoading:nil];
    };
    
    services.successCase = ^(NSDictionary *response) {
        [loadingView finishLoading:^{
            BOOL hasSubscriptionsInOtherCard = [[response objectForKey:SubscriptionInOtherCardKey] boolValue];
            if (checkSubscriptions && hasSubscriptionsInOtherCard) {
                NSString *message = @"Você possuí assinatura(s) associadas a outros cartões. Deseja transferir todas as suas assinaturas para seu novo cartão padrão, final xxxx?";
                message = [message stringByReplacingOccurrencesOfString:@"xxxx" withString:card.lastDigits];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Sim"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self changeSubscriptionsToCard:card];
                                            }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"Não"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               
                                           }];
                
                [alert addAction:noButton];
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
    };
    
    [loadingView startLoading:self title:@"Aguarde..."];
    [services setDefaultCardWithCardID:card.cardId];
}

- (void) changeSubscriptionsToCard: (CreditCard *)card {
    Services *service = [[Services alloc] init];
    LoadingViewController *loadingView = [[LoadingViewController alloc] init];
    service.failureCase = ^(NSString *cod, NSString *msg) {
        [loadingView finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:self
                  title:@"Atenção!"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    service.successCase = ^(NSDictionary *response) {
        [loadingView finishLoading:^{
            NSString *message = @"Todas as suas assinaturas assinaturas foram transferidas com sucesso para o cartão final xxxx.";
            message = [message stringByReplacingOccurrencesOfString:@"xxxx" withString:card.lastDigits];
            
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:self
                  title:@"Atenção!"
            description:message
              imageMode:Success
           buttonAction:nil];
        }];
    };
    
    [loadingView startLoading:self title:@"Aguarde..."];
    [service setCardForSubscriptions:card.cardId oldCardId:nil];
    
}

- (bool) cardIsAccepted:(CreditCard *) card{
    
    BOOL isValid = NO;
    
    NSArray *acceptedBrands = [Lib4all acceptedBrands];
    
    //verifica os meios de pagamento do cartão
    
    //Verifica crédito
    if ((card.type == CardTypeCredit) && ([_acceptedPaymentTypes containsObject:@(Credit)])) isValid = YES;
    
    //Verifica débito
    if ((card.type == CardTypeDebit) && ([_acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    //Verifica ambos
    if ((card.type == CardTypeCreditAndDebit) && ([_acceptedPaymentTypes containsObject:@(Credit)] || [_acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    if ((card.type == CardTypePatRefeicao) && ([_acceptedPaymentTypes containsObject:@(PatRefeicao)])) isValid = YES;
    if ((card.type == CardTypePatAlimentacao) && ([_acceptedPaymentTypes containsObject:@(PatAlimentacao)])) isValid = YES;
    
    //Verifica brands
    if (![acceptedBrands containsObject:card.brandId]) isValid = NO;
    
    
    return isValid;
    
}

- (void)selectCardForSubscriptions:(NSString *)filterCardID andLastDigits:(NSString *)lastDigits {
    CardsTableViewController *cardPicker = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                            instantiateViewControllerWithIdentifier:@"CardsTableViewController"];
    cardPicker.onSelectCardAction = OnSelectCardChangeSubscriptions;
    cardPicker.filterCardID = @[filterCardID];
    __weak CardsTableViewController *weakCardPicker = cardPicker;
    cardPicker.didSelectCardBlock = ^(NSString *cardId){
        LoadingViewController *loadingView = [[LoadingViewController alloc] init];
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg) {
            [loadingView finishLoading:^{
                PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
                [modal show:self
                      title:@"Atenção!"
                description:msg
                  imageMode:Error
               buttonAction:nil];
            }];
        };
        
        service.successCase = ^(NSDictionary *response) {
            Services *deleteCardService = [[Services alloc] init];
            
            deleteCardService.failureCase = ^(NSString *cod, NSString *msg) {
                [loadingView finishLoading:^{
                    PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
                    [modal show:self
                          title:@"Atenção!"
                    description:msg
                      imageMode:Error
                   buttonAction:nil];
                }];
            };
            
            deleteCardService.successCase = ^(NSDictionary *response) {
                [loadingView finishLoading:^{
                    NSString *msg = @"Seu cartão de final xxxx foi excluído com sucesso.";
                    msg = [msg stringByReplacingOccurrencesOfString:@"xxxx" withString:lastDigits];
                    PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
                    [modal show:self
                          title:@"Atenção!"
                    description:msg
                      imageMode:Success
                   buttonAction:^{
                       [weakCardPicker.navigationController popViewControllerAnimated:YES];
                   }];
                }];
            };
            
            [deleteCardService deleteCardWithCardID:filterCardID];
        };
        
        [loadingView startLoading:self title:@"Aguarde..."];
        [service setCardForSubscriptions:cardId oldCardId:filterCardID];
    };
    
    [self.navigationController pushViewController:cardPicker animated:YES];
    
}

- (void)refreshData {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        
    };
    
    service.successCase = ^(NSDictionary *response){
        self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
        self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];
        
        [self filterCards];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    };
    
    [service listCards];
}

#pragma mark - actions

- (void)addCardButtonTouched {
    [AnalyticsUtil logEventWithName:@"adicionar_cartao" andParameters:nil];
    
    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:_acceptedPaymentTypes andAcceptedBrands:[Lib4all acceptedBrands]];
    flowController.isFromAddCardMenu = YES;
    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
    [flowController startFlowWithViewController:self];
}

- (void)addCashButtonTouched {
    [AnalyticsUtil logEventWithName:@"adicionar_dinheiro" andParameters:nil];
    
    NSBundle *bundle = [NSBundle getLibBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PrePaid" bundle: bundle];
    UIViewController *destination = [storyboard instantiateViewControllerWithIdentifier:@"PPCashInViewController"];
    [self.navigationController pushViewController:destination animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if((([_acceptedPaymentTypes containsObject:@(CheckingAccount)]) && ((indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 1 && indexPath.row == _cardListArray.count))) || (![_acceptedPaymentTypes containsObject:@(CheckingAccount)] && indexPath.row == _cardListArray.count)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellAdd" forIndexPath:indexPath];
        LayoutManager *layout = [LayoutManager sharedManager];
        UIButton *button = (UIButton *)[cell viewWithTag:1];
        UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
        
        icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        icon.contentMode = UIViewContentModeScaleAspectFill;
        icon.tintColor = layout.primaryColor;
        
        if (indexPath.section == 0 && [_acceptedPaymentTypes containsObject:@(CheckingAccount)]) {
            [button setTitle:@"Adicionar dinheiro" forState:UIControlStateNormal];
            [button removeTarget:self action:@selector(addCardButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(addCashButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setTitle:@"Adicionar outro cartão" forState:UIControlStateNormal];
            [button removeTarget:self action:@selector(addCashButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(addCardButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [button setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
        [button setTitleColor:[[LayoutManager sharedManager] darkGreen] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[layout fontWithSize:layout.regularFontSize]];
    }
    
    if ([_acceptedPaymentTypes containsObject:@(CheckingAccount)] && indexPath.section == 0) {
        if (indexPath.row == 1) {
            return cell;
        } else {
            //Conta pré paga
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellChecking" forIndexPath:indexPath];
            
            ((UILabel *) [cell viewWithTag:2]).font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
            ((UILabel *) [cell viewWithTag:1]).font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].midFontSize];
            [((UILabel *) [cell viewWithTag:1]) setText: [NSString stringWithFormat: @"Saldo da Carteira %@" , [Lib4allPreferences sharedInstance].balanceTypeFriendlyName]];
            ((UILabel *) [cell viewWithTag:2]).text = _strAmount;
            
            //Se o app hospedeiro setar a prepaidAccountImage, utilizamos ela
            //caso contrário, continuamos com a da 4all (que está sendo setada por storyboard)
            if ([Lib4allPreferences sharedInstance].prepaidAccountImage != nil) {
                ((UIImageView *) [cell viewWithTag:3]).image = [Lib4allPreferences sharedInstance].prepaidAccountImage;
            }
        }
    } else {
        //Cartão
        if (indexPath.row == _cardListArray.count) {
            return cell;
        }else{
            CreditCardTableViewCell *cellCard = (CreditCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellCard" forIndexPath:indexPath];
            CreditCard *card = [self.cardListArray objectAtIndex:indexPath.row];
            
            [cellCard.imageCardIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]] placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
            
            cellCard.labelMaskedPan.text = [card getMaskedPan];
            cellCard.labelMaskedPan.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
            cellCard.labelMaskedPan.textColor = [[LayoutManager sharedManager] darkFontColor];
            cellCard.checkBoxDefault.on = card.isDefault;
            
            cellCard.didClickDelete = ^{
                [self deleteCard:indexPath];
            };
            
            cellCard.didClickDefault = ^{
                [self setDefaultCard:card checkForSubsciptions:NO];
            };
            
            UIImage *image = [[UIImage lib4allImageNamed:@"close"] withColor:[UIColor darkGrayColor]];
            [cellCard.buttonDelete setImage:image forState:UIControlStateNormal];
            cellCard.buttonDelete.tintColor = [UIColor blackColor];
            
            
            cellCard.labelTypeCard.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].midFontSize];
            cellCard.labelTypeCard.textColor = [[LayoutManager sharedManager] darkFontColor];
            cellCard.labelTypeCard.text = card.cardDescription;
            
            //Se não for provider, mostra o nome do dono do cartão no lugar do tipo
            if (!card.isProvider) {
                cellCard.labelTypeCard.text = card.sharedDetails[0][@"identifier"];
            }
            
            //Verificar se tem saldo do cartão
            if(card.showBalance) {
                cellCard.labelCardAvailableAmount.hidden = NO;
                cellCard.heightLabelCardAvailableAmountConstraint.constant = 17;
                cellCard.labelCardAvailableAmount.text = card.balanceMessage;
            } else {
                cellCard.labelCardAvailableAmount.hidden = YES;
                cellCard.heightLabelCardAvailableAmountConstraint.constant = 0;
            }
            
            return cellCard;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [_cardListArray count]) {
        CreditCard *card = [self.cardListArray objectAtIndex:indexPath.row];
        if (card.showBalance) {
            return 90;
        }
    }
    return 70;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([_acceptedPaymentTypes containsObject:@(Credit)] && [_acceptedPaymentTypes containsObject:@(CheckingAccount)]) {
        return 2;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_acceptedPaymentTypes containsObject:@(CheckingAccount)] && section == 0) {
        return 2;
    }
    return _cardListArray.count + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        LayoutManager *layout = [LayoutManager sharedManager];
        header.textLabel.font = [layout boldFontWithSize:[layout regularFontSize]];
        header.textLabel.textColor = [layout darkFontColor];
        header.backgroundView.backgroundColor = layout.paymentMethodHeaderColor;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([_acceptedPaymentTypes containsObject:@(CheckingAccount)] && section == 0) {
        return [NSString stringWithFormat:@"Carteira %@", [Lib4allPreferences sharedInstance].balanceTypeFriendlyName];
    }
    return @"Cartões";
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

@end
