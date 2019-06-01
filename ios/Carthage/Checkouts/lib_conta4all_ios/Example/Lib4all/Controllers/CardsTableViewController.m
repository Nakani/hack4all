//
//  CardsTableViewController.m
//  Example
//
//  Created by Cristiano Matte on 10/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CardsTableViewController.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"
#import "LoadingViewController.h"
#import "BaseNavigationController.h"
#import "Lib4allPreferences.h"
#import "UIImage+Color.h"
#import "UIImageView+WebCache.h"
#import "CardAdditionFlowController.h"

@interface CardsTableViewController ()

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSMutableArray *ownedCardList;
@property (strong, nonatomic) NSMutableArray *cardListArray;
@end

@implementation CardsTableViewController

- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
            instantiateViewControllerWithIdentifier:@"CardsTableViewController"];

    return self;
}

#pragma mark - View controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancelar"
                                     destructiveButtonTitle:@"Excluir"
                                          otherButtonTitles:@"Tornar principal", nil];

    if (self.onSelectCardAction == OnSelectCardMakeDefault) {
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                    initWithTarget:self action:@selector(handleLongPress:)];
        [self.tableView addGestureRecognizer:longPressGestureRecognizer];
    }
    [self refreshData];

    if (self.acceptedBrands == nil) {
        self.acceptedBrands = [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects];
    }

    if (self.acceptedPaymentTypes == nil) {
        self.acceptedPaymentTypes = [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
    }

    self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
    self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];

    [self filterCards];

    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
    self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];

    [self filterCards];

    [[self tableView] reloadData];
    self.navigationItem.title = @"Escolha seu cartão";

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.onSelectCardAction == OnSelectCardShowNextVC) {
        self.navigationItem.title = @"";
    }

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

#pragma mark - Actions
- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Obtém o indexPath da célula da tabela onde ocorreu o toque
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];

        if (indexPath != nil && indexPath.row < [self.cardListArray count]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.actionSheet showInView:self.view];
        }
    }
}

- (void)addCardButtonTouched {
    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];
    flowController.isFromAddCardMenu = YES;
    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
    [flowController startFlowWithViewController:self];
}


- (void)setDefaultCard:(CreditCard *)card checkForSubsciptions:(BOOL)checkSubscriptions  {
    /*
     * Não permite que o usuário selecione um cartão de modalidade ou bandeira
     * não aceitas pelo aplicativo como cartão padrão
     */
    if (![self cardIsAccepted:card withAcceptedPaymentTypes:self.acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands]){
        
        NSString *message = @"Este cartão não é aceito neste aplicativo. Por favor, escolha outro cartão.";
        
        if (_isQrCodePayment) {
            message = @"Este cartão não é aceito neste estabelecimento. Por favor, escolha outro cartão.";
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:message
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
        [self.tableView reloadData];
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
                                               if (self.onSelectCardAction == OnSelectCardMakeDefault) {
                                                   [self dismissViewControllerAnimated:YES completion:^{
                                                       if (self.didSelectCardBlock != nil) {
                                                           self.didSelectCardBlock(card.cardId);
                                                       }
                                                   }];
                                               }
                                           }];

                [alert addAction:noButton];
                [alert addAction:yesButton];

                [self presentViewController:alert animated:YES completion:nil];
            } else if (self.onSelectCardAction == OnSelectCardMakeDefault) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.didSelectCardBlock != nil) {
                        self.didSelectCardBlock(card.cardId);
                    }
                }];
            }
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
           buttonAction:^{
               if (self.onSelectCardAction == OnSelectCardMakeDefault) {
                   [self dismissViewControllerAnimated:YES completion:^{
                       if (self.didSelectCardBlock != nil) {
                           self.didSelectCardBlock(card.cardId);
                       }
                   }];
               }
           }];
        }];
    };

    [loadingView startLoading:self title:@"Aguarde..."];
    [service setCardForSubscriptions:card.cardId oldCardId:nil];

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

        [loadingView startLoading:self title:@"Aguarde..."];
        [service setCardForSubscriptions:cardId oldCardId:filterCardID];
    };

    [self.navigationController pushViewController:cardPicker animated:YES];

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

- (void)refreshData {
    Services *service = [[Services alloc] init];

    service.failureCase = ^(NSString *cod, NSString *msg){
        [self.refreshControl endRefreshing];
    };

    service.successCase = ^(NSDictionary *response){
        self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
        self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];

        [self filterCards];

        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };

    [service listCards];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    CreditCard *card = [self.cardListArray objectAtIndex:selectedIndexPath.row];

    if (buttonIndex == actionSheet.destructiveButtonIndex) {
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
                if (wasDefaultCard && !wasLastCard) {
                    [self updateDefaultCard];
                }

                [self.cardListArray removeObjectAtIndex:selectedIndexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self refreshData];
            }];
        };

        [loadingView startLoading:self title:@"Aguarde..."];
        if (card.isShared && ![[card.sharedDetails[0] valueForKey:@"provider"] boolValue] ) {
            NSString *customerId = [card.sharedDetails[0] valueForKey:@"customerId"];
            [services deleteSharedCard:card.cardId custumerId:customerId];
        } else {
            [services deleteCardWithCardID:card.cardId];
        }

    } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self setDefaultCard:card checkForSubsciptions:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.onSelectCardAction == OnSelectCardShowNextVC) {
        return [self.ownedCardList count] + 1;

    }
    return [self.cardListArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSInteger numberOfRows = [self.cardListArray count];
    if (self.onSelectCardAction == OnSelectCardShowNextVC) {
        numberOfRows = [self.ownedCardList count];

    }
    if (indexPath.row < numberOfRows) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
        CreditCard *card = [self.cardListArray objectAtIndex:indexPath.row];
        if (self.onSelectCardAction == OnSelectCardShowNextVC) {
            card = self.ownedCardList[indexPath.row];

        }

        [((UIImageView *)[cell viewWithTag:1]) sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]]
                               placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
        
        ((UILabel *)[cell viewWithTag:2]).text = [card getMaskedPan];
        ((UILabel *)[cell viewWithTag:2]).font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] regularFontSize]];

        UIImageView *iconCard = (UIImageView *)[cell viewWithTag:6];
        UIImageView *iconCheck = (UIImageView *)[cell viewWithTag:3];
        
        iconCard.image = [iconCard.image withColor:[LayoutManager sharedManager].primaryColor];
        iconCheck.image = [iconCheck.image withColor:[LayoutManager sharedManager].primaryColor];
        
        
        UILabel *cardTypeLabel = (UILabel *)[cell viewWithTag:5];
        cardTypeLabel.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        cardTypeLabel.text = card.cardDescription;
        
        //Se não for provider, mostra o nome do dono do cartão no lugar do tipo
        if (!card.isProvider) {
            cardTypeLabel.text = card.sharedDetails[0][@"identifier"];
        }

        if (self.onSelectCardAction != OnSelectCardReturnCardId) {
            ((UIImageView *)[cell viewWithTag:3]).hidden = !card.isDefault;
        }

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"addCardCell"];
        UIButton* addCardButton = [cell viewWithTag:10];
        
        [addCardButton setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
        [addCardButton setTitleColor:[[LayoutManager sharedManager] darkGreen] forState:UIControlStateHighlighted];
        

        [addCardButton addTarget:self action:@selector(addCardButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Se selecionou botão de adicionar cartão, ação está definida no storyboard
    if (indexPath.row == [self.cardListArray count]) {
        return;
    }

    CreditCard *card = [self.cardListArray objectAtIndex:indexPath.row];
    
    //Action usada para quando esta tela é chamada a partir do perfil familia
    if (self.onSelectCardAction == OnSelectCardShowNextVC) {
        card = self.ownedCardList[indexPath.row];
        if(card.type == CardTypePatRefeicao || card.type == CardTypePatAlimentacao){
            //Se o cartão é pat, não pode ser compartilhado
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                           message:@"Este cartão não pode ser compartilhado."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }

    switch (self.onSelectCardAction) {
        case OnSelectCardMakeDefault:
            [self setDefaultCard:card checkForSubsciptions:NO];
            break;
        case OnSelectCardShowActionSheet:
            [self.actionSheet showInView:self.view];
            break;
        case OnSelectCardReturnCardId: {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.didSelectCardBlock != nil) {
                    self.didSelectCardBlock(card.cardId);
                }
            }];
            break;
        }
        case OnSelectCardShowNextVC:
            if (self.didSelectCardBlock != nil) {
                self.didSelectCardBlock(card.cardId);
            }
            break;
        case OnSelectCardChangeSubscriptions:
            if (self.didSelectCardBlock != nil) {
                self.didSelectCardBlock(card.cardId);
            }
            break;


    }

}

#pragma mark - Navigation
- (IBAction)unwindToCardsTableviewController:(UIStoryboardSegue*)sender {
    Services *service = [[Services alloc] init];

    service.failureCase = ^(NSString *cod, NSString *msg){ };
    service.successCase = ^(NSDictionary *response){
        self.ownedCardList = [[[CreditCardsList sharedList] getOwnedCards] mutableCopy];
        self.cardListArray = [[[CreditCardsList sharedList] getValidCards] mutableCopy];

        int row = (int)[self.cardListArray count] - 1;
        if (self.onSelectCardAction == OnSelectCardShowNextVC) {
            row = (int)[self.ownedCardList count] - 1;
        }
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];

    };

    [service listCards];
}

#pragma mark - Layout
- (void) configureLayout {
    // Configura view
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];

    // Configura navigation bar
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Escolha seu cartão";

    // Configura refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

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


//Alteração Bruno Fernandes 3/2/2017
//isso aqui é errado, fiz um copy and paste de LoginPaymentAction.m, o correto seria colocar isto em um lugar só
//TODO: ver com o Adriano

- (bool) cardIsAccepted:(CreditCard *) card withAcceptedPaymentTypes: (NSArray*) acceptedPaymentTypes andAcceptedBrands: (NSArray *) acceptedBrands {

    BOOL isValid = NO;

    //verifica os meios de pagamento do cartão

    //Verifica crédito
    if ((card.type == CardTypeCredit) && ([acceptedPaymentTypes containsObject:@(Credit)])) isValid = YES;

    //Verifica débito
    if ((card.type == CardTypeDebit) && ([acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;

    //Verifica ambos
    if ((card.type == CardTypeCreditAndDebit) && ([acceptedPaymentTypes containsObject:@(Credit)] || [acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    if ((card.type == CardTypePatRefeicao) && ([acceptedPaymentTypes containsObject:@(PatRefeicao)])) isValid = YES;
    
    if ((card.type == CardTypePatAlimentacao) && ([acceptedPaymentTypes containsObject:@(PatAlimentacao)])) isValid = YES;

    //Verifica brands
    if (![acceptedBrands containsObject:card.brandId]) isValid = NO;


    return isValid;

}


@end
