//
//  FamilyAdvancedTableViewController.m
//  Example
//
//  Created by Adriano Soares on 17/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyAdvancedTableViewController.h"
#import "FamilyDataFieldViewController.h"
#import "FamilyWeekDayTableViewController.h"
#import "FamilyHourTableViewController.h"
#import "FamilyMonthDayViewController.h"

#import "CreditCard.h"
#import "CreditCardsList.h"
#import "CardsTableViewController.h"
#import "DateUtil.h"
#import "Services.h"
#import "ServicesConstants.h"

#import "FamilyDataFieldProtocol.h"
#import "FamilyBalanceDataField.h"
#import "FamilyPerTransactionDataField.h"
#import "FamilyMaxTransactionsDataField.h"
#import "FamilyExpirationDateDataField.h"


#import "LoadingViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "ErrorTextField.h"
#import "NSBundle+Lib4allBundle.h"
#import "NSString+Mask.h"
#import "UIImage+Color.h"
#import "UIImageView+WebCache.h"

@interface FamilyAdvancedTableViewController ()
@property (strong, nonatomic) LayoutManager *LM;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UIView *floatingView;

@property (weak, nonatomic) IBOutlet UITableViewCell *recurringBalanceCell;
@property (weak, nonatomic) IBOutlet UILabel *recurringBalanceLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *perTransactionCell;
@property (weak, nonatomic) IBOutlet UILabel *perTransactionLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *maxTransactionsCell;
@property (weak, nonatomic) IBOutlet UILabel *maxTransactionsLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *rechargeDayCell;
@property (weak, nonatomic) IBOutlet UILabel *rechargeDayLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *cardCell;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardBrandImage;

@property (weak, nonatomic) IBOutlet UITableViewCell *weekDayCell;
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *hourCell;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *validityCell;
@property (weak, nonatomic) IBOutlet UILabel *validityLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *askToBuyCell;
@property (weak, nonatomic) IBOutlet UILabel *askToBuyLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *merchantsHeaderCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *blockedMerchantsCell;
@property (weak, nonatomic) IBOutlet UILabel *blockedMerchantsLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *askToBuyBlockedCell;
@property (weak, nonatomic) IBOutlet UILabel *askToBuyBlockedLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *disclosures;


@end


@implementation FamilyAdvancedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.LM = [LayoutManager sharedManager];

    if (self.sharedDetails != nil) {
        [self loadData];
    }


    [self configureLayout];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Opçoes avançadas";

    [self relocateFloatingView];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Opçoes avançadas";

    if (self.sharedDetails != nil) {
        [self loadData];
    }

    [self relocateFloatingView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView endEditing:YES];

    self.navigationItem.title = @"";
    
    if (!self.isCreation) {
        if (self.completion) {
            self.completion(self.cardID, self.sharedDetails);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: - Actions



- (void) configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Opçoes avançadas";

    self.view.backgroundColor = self.LM.backgroundColor;
    self.floatingView.backgroundColor = self.LM.backgroundColor;
    self.titleLabel.font = [self.LM fontWithSize:self.LM.regularFontSize];
    self.titleLabel.textColor = self.LM.darkFontColor;

    self.subtitleLabel.font = [self.LM fontWithSize:self.LM.regularFontSize];
    self.subtitleLabel.textColor = self.LM.darkFontColor;


    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    for (UIImageView *disclosure in self.disclosures) {
        disclosure.image = [disclosure.image withColor:self.LM.primaryColor];
    }
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) relocateFloatingView {
    CGRect frame = self.floatingView.frame;
    frame.origin.y = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.floatingView.frame.size.height;
    self.floatingView.frame = frame;

    [self.view bringSubviewToFront:self.floatingView];
}


- (void) loadData {
    id recurringBalance = [self.sharedDetails valueForKey:@"recurringBalance"];
    if (recurringBalance && recurringBalance != [NSNull null]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        self.recurringBalanceLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:[recurringBalance doubleValue]/100]];
        self.recurringBalanceLabel.text = [self.recurringBalanceLabel.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    }


    id perTransactionLimit = [self.sharedDetails valueForKey:@"transactionPriceLimit"];
    if (perTransactionLimit && perTransactionLimit != [NSNull null]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.perTransactionLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:[perTransactionLimit doubleValue]/100]];
        self.perTransactionLabel.text = [self.perTransactionLabel.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    } else {
        self.perTransactionLabel.text = @"Definir";
    }

    id maxTransactionsLimit = [self.sharedDetails valueForKey:@"totalTransactionsLimit"];
    if (maxTransactionsLimit && maxTransactionsLimit  != [NSNull null]) {
        self.maxTransactionsLabel.text = [maxTransactionsLimit stringValue];
    } else {
        self.maxTransactionsLabel.text = @"Definir";
    }

    id validity = [self.sharedDetails valueForKey:@"expirationDate"];
    if (validity && validity  != [NSNull null]) {
        self.validityLabel.text = [DateUtil convertDateString:validity fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
    } else {
        self.validityLabel.text = @"Definir";
    }
    if (self.cardID) {
        CreditCard *card = [[CreditCardsList sharedList] getCardWithID:self.cardID];
        if (card) {
            self.cardNumberLabel.text = card.lastDigits;
            [self.cardBrandImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]] placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
        }
    }


    id recurringDay = [self.sharedDetails valueForKey:@"recurrenceDay"];
    if (recurringDay && recurringDay  != [NSNull null]) {
        self.rechargeDayLabel.text = [recurringDay stringValue];
    } else {
        self.rechargeDayLabel.text = @"Definir";
    }

    id weekDays = [self.sharedDetails valueForKey:@"weekdays"];
    if (weekDays && weekDays != [NSNull null]) {
        self.weekDayLabel.text = [DateUtil convertWeekDays:weekDays];
    } else {
        self.weekDayLabel.text = @"Definir";
    }

    [self.tableView reloadData];

    id schedules = [self.sharedDetails valueForKey:@"schedules"];
    if (schedules && schedules != [NSNull null]) {
        self.hourLabel.text = [FamilyHourTableViewController schedulesToLabel:schedules];
    } else {
        self.hourLabel.text = @"Definir";
    }

    [self.tableView reloadData];
}

- (IBAction)saveButton:(id)sender {
    if (self.completion) {
        self.completion(self.cardID, self.sharedDetails);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = cell.reuseIdentifier;
    if ([identifier isEqualToString:@"headerCell"]) {
        UILabel *label = [cell viewWithTag:1];
        label.font = [self.LM fontWithSize:self.LM.titleFontSize];
        label.numberOfLines = 0;
        label.textColor = self.LM.primaryColor;
        label.text = [label.text uppercaseString];

    }
    if ([identifier isEqualToString:@"detailCell"] || [identifier isEqualToString:@"cardDetailCell"] ) {
        UILabel *label = [cell viewWithTag:1];
        label.font = [self.LM fontWithSize:self.LM.subTitleFontSize];
        label.textColor = self.LM.darkFontColor;

        UILabel *valueLabel = [cell viewWithTag:2];
        valueLabel.font = [self.LM fontWithSize:self.LM.subTitleFontSize];
        valueLabel.textColor = self.LM.darkFontColor;
        if ([valueLabel.text isEqualToString:@"Definir"]) {
            valueLabel.textColor = self.LM.primaryColor;
        }

    }

    if ([identifier isEqualToString:@"cardDetailCell"]) {
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"headerCell"]) {
        return;
    }

    if (cell == _rechargeDayCell) {
        FamilyMonthDayViewController *dayPicker = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                       instantiateViewControllerWithIdentifier:@"FamilyMonthDayViewController"];

        dayPicker.isCreation = self.isCreation;

        if ([self.sharedDetails objectForKey:@"recurrenceDay"]) {
            NSNumber *day = [self.sharedDetails objectForKey:@"recurrenceDay"];
            dayPicker.data = day.description;
        }

        NSString *customerId = [self.sharedDetails valueForKey:CustomerIdKey];
        if (customerId) {
            [dayPicker setCustomerId:customerId];
            [dayPicker setCardId:self.cardID];
        }


        dayPicker.completion = ^(NSString *data) {
            [self.sharedDetails setObject:[NSNumber numberWithInteger:[data integerValue]] forKey:@"recurrenceDay"];
            [self loadData];
        };

        [self.navigationController pushViewController:dayPicker animated:YES];
        return;
    }

    if (cell == _cardCell) {
        CardsTableViewController *cardPickerViewController = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                              instantiateViewControllerWithIdentifier:@"CardsTableViewController"];
        if (cardPickerViewController && self.navigationController) {
            cardPickerViewController.onSelectCardAction = OnSelectCardShowNextVC;
            cardPickerViewController.didSelectCardBlock = ^(NSString *cardID) {
                BOOL isCreation = self.isCreation;
                if (isCreation) {
                    self.cardID = cardID;
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    LoadingViewController *loader = [[LoadingViewController alloc] init];

                    Services *service = [[Services alloc] init];

                    service.failureCase = ^(NSString *cod, NSString *msg){

                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                                       message:msg
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:nil]];

                        [loader finishLoading:^{
                            [self presentViewController:alert animated:YES completion:nil];
                        }];

                    };

                    service.successCase = ^(NSDictionary *response) {
                        [loader finishLoading:^{
                            self.cardID = cardID;
                            [self.navigationController popViewControllerAnimated:YES];
                        }];

                    };

                    NSString *customerId = [self.sharedDetails valueForKey:CustomerIdKey];
                    if (customerId) {
                        [service updateSharedCard:self.cardID
                                       customerId:customerId
                                         withData:@{ @"newCardId": cardID }];

                        [loader startLoading:self title:@"Aguarde..."];
                    }

                }

            };
            [self.navigationController pushViewController:cardPickerViewController animated:YES];
            return;
        }
    }

    if (cell == _weekDayCell) {
        FamilyWeekDayTableViewController *dayPicker = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                       instantiateViewControllerWithIdentifier:@"FamilyWeekDayTableViewController"];

        dayPicker.isCreation = self.isCreation;
        if ([self.sharedDetails objectForKey:@"weekdays"]) {
            dayPicker.data = [self.sharedDetails objectForKey:@"weekdays"];
        }

        NSString *customerId = [self.sharedDetails valueForKey:CustomerIdKey];
        if (customerId) {
            [dayPicker setCustomerId:customerId];
            [dayPicker setCardId:self.cardID];
        }


        dayPicker.completion = ^(NSArray *data) {
            [self.sharedDetails setObject:data forKey:@"weekdays"];
            [self loadData];
        };

        [self.navigationController pushViewController:dayPicker animated:YES];
        return;
    }

    if (cell == _hourCell) {
        FamilyHourTableViewController *hourPicker = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                       instantiateViewControllerWithIdentifier:@"FamilyHourTableViewController"];

        hourPicker.isCreation = self.isCreation;
        if ([self.sharedDetails objectForKey:@"schedules"]) {
            hourPicker.data = [self.sharedDetails objectForKey:@"schedules"];
        }

        NSString *customerId = [self.sharedDetails valueForKey:CustomerIdKey];
        if (customerId) {
            [hourPicker setCustomerId:customerId];
            [hourPicker setCardId:self.cardID];
        }


        hourPicker.completion = ^(NSArray *data) {
            [self.sharedDetails setObject:data forKey:@"schedules"];
            [self loadData];
        };

        [self.navigationController pushViewController:hourPicker animated:YES];
        return;
    }

    FamilyDataFieldViewController *vc = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                 instantiateViewControllerWithIdentifier:@"FamilyDataFieldViewController"];

    vc.isCreation = self.isCreation;


    if (cell == _recurringBalanceCell) {
        FamilyBalanceDataField *protocol = [[FamilyBalanceDataField alloc] init];
        vc.dataFieldProtocol = protocol;
        if ([self.sharedDetails valueForKey:protocol.serverKey] != [NSNull null]) {
            vc.data = [self.sharedDetails valueForKey:protocol.serverKey];
        }
        vc.completion = ^(NSString *data){
            [self.sharedDetails setValue:[NSNumber numberWithDouble:[data doubleValue]] forKey:protocol.serverKey];
            [self loadData];
        };
    }

    if (cell == _perTransactionCell) {
        FamilyPerTransactionDataField *protocol = [[FamilyPerTransactionDataField alloc] init];
        vc.dataFieldProtocol = protocol;
        if ([self.sharedDetails valueForKey:protocol.serverKey] != [NSNull null]) {
            vc.data = [self.sharedDetails valueForKey:protocol.serverKey];
        }
        vc.completion = ^(NSString *data){
            if (data) {
                [self.sharedDetails setValue:[NSNumber numberWithDouble:[data doubleValue]] forKey:protocol.serverKey];
            } else {
                [self.sharedDetails setValue:[NSNull null] forKey:protocol.serverKey];
            }

            [self loadData];
        };

    }

    if (cell == _maxTransactionsCell) {
        FamilyMaxTransactionsDataField *protocol = [[FamilyMaxTransactionsDataField alloc] init];
        vc.dataFieldProtocol = protocol;
        id maxTransactions = [self.sharedDetails valueForKey:protocol.serverKey];
        if (maxTransactions  != [NSNull null]) {
            vc.data = [maxTransactions stringValue];
        }
        vc.completion = ^(NSString *data){
            if (data) {
                [self.sharedDetails setValue:[NSNumber numberWithDouble:[data doubleValue]] forKey:protocol.serverKey];
            } else {
                [self.sharedDetails setValue:[NSNull null] forKey:protocol.serverKey];
            }
            [self loadData];
        };
    }

    if (cell == _validityCell) {
        FamilyExpirationDateDataField *protocol = [[FamilyExpirationDateDataField alloc] init];
        vc.dataFieldProtocol = protocol;
        if ([self.sharedDetails valueForKey:protocol.serverKey] != [NSNull null]) {
            vc.data = [self.sharedDetails valueForKey:protocol.serverKey];
        }

        vc.completion = ^(NSString *data){
            if (data) {
                [self.sharedDetails setValue:data forKey:protocol.serverKey];
            } else {
                [self.sharedDetails setValue:[NSNull null] forKey:protocol.serverKey];
            }

            [self loadData];
        };
    }

    NSString *customerId = [self.sharedDetails valueForKey:CustomerIdKey];
    if (customerId) {
        [vc.dataFieldProtocol setCustomerId:customerId];
        [vc.dataFieldProtocol setCardId:self.cardID];
    }


    [self.navigationController pushViewController:vc animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    //Desabilitar Campos
    if (cell == _askToBuyCell) {
        return 0;
    }
    if (cell == _merchantsHeaderCell) {
        return 0;
    }
    if (cell == _blockedMerchantsCell) {
        return 0;
    }
    if (cell == _askToBuyBlockedCell) {
        return 0;
    }
    return cell.frame.size.height;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self relocateFloatingView];
}

@end
