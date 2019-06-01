//
//  CompleteTransactionStatementViewController.m
//  Example
//
//  Created by Cristiano Matte on 28/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CompleteTransactionStatementViewController.h"
#import "TransactionDetailsViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "Transaction.h"
#import "Services.h"
#import "UIImage+Color.h"

// MARK: - CompleteTransactionTableViewCell

@interface CompleteTransactionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosure;

@end

@implementation CompleteTransactionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.dateLabel.font = [layoutManager fontWithSize:16.0];
    self.dateLabel.textColor = [layoutManager darkFontColor];
    
    self.placeLabel.font = [layoutManager fontWithSize:22.0];
    self.placeLabel.textColor = [layoutManager darkFontColor];
    
    self.categoryLabel.font = [layoutManager fontWithSize:18.0];
    self.categoryLabel.textColor = [layoutManager darkFontColor];
    self.categoryLabel.hidden = YES;
    
    self.currencyLabel.font = [layoutManager fontWithSize:14.0];
    self.currencyLabel.textColor = [layoutManager darkFontColor];
    
    self.amountLabel.font = [layoutManager fontWithSize:22.0];
    self.amountLabel.textColor = [layoutManager darkFontColor];
    
    self.disclosure.image = [self.disclosure.image withColor:layoutManager.primaryColor];
}

@end


// MARK: - CompleteTransactionStatementViewController

@interface CompleteTransactionStatementViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, atomic) NSArray *displayedTransactions;
@property (readonly, atomic) int batch;

@end

@implementation CompleteTransactionStatementViewController

@synthesize batch = _batch;

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 58;
    
    _batch = 30;
    self.displayedTransactions = [[NSMutableArray alloc] init];

    if (self.downloadedTransactions == nil) {
        self.downloadedTransactions = [[NSMutableArray alloc] init];
        self.currentDownloadedTransactionsPeriod = TransactionsPeriodNone;
        [self listTransactionsWithStartingIndex:0];
    } else {
        [self updateDisplayedTransactions];
    }
}

// MARK: - Actions

- (IBAction)segmentedControlValueChanged {
    [self updateDisplayedTransactions];
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Se não há transações para o período selecionado, exibe a emptyLabel
    if ([self selectedTransactionPeriod] <= self.currentDownloadedTransactionsPeriod && self.displayedTransactions.count == 0) {
        self.emptyLabel.hidden = NO;
    } else {
        self.emptyLabel.hidden = YES;
    }
    
    BOOL shouldDisplayLoadingCell = [self selectedTransactionPeriod] > self.currentDownloadedTransactionsPeriod;
    return shouldDisplayLoadingCell ? self.displayedTransactions.count + 1 : self.displayedTransactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Verifica se o indexPath é da célular de "Carregando..."
    if (indexPath.row == self.displayedTransactions.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        
        UILabel *loadingLabel = [cell viewWithTag:1];
        loadingLabel.font = [[LayoutManager sharedManager] fontWithSize:15.0];
        loadingLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
        
        return cell;
    }
    
    CompleteTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompleteTransactionCell" forIndexPath:indexPath];
    
    Transaction *transaction = self.displayedTransactions[indexPath.row];
    
    cell.placeLabel.text = transaction.merchant.name;
    cell.categoryLabel.text = @"TODO";
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-7];
    NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    /*
     * Se transação foi nos últimos 7 dias, exibe dia da semana.
     * Caso contrário, exibe data do pagamento
     */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([transaction.paidAt compare:sevenDaysAgo] == NSOrderedDescending) {
        [dateFormatter setDateFormat:@"EEEE"];
        cell.dateLabel.text = [[dateFormatter stringFromDate:[transaction paidAt]] capitalizedString];
    } else {
        dateFormatter.dateFormat = @"dd MMM";
        cell.dateLabel.text = [dateFormatter stringFromDate:[transaction paidAt]];
    }
    
    // Exibe o valor com o separador de decimais localizado
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = numberFormatter.minimumFractionDigits = 2;
    cell.amountLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[transaction.amount doubleValue] / 100.0]];
    
    return cell;
}

// MARK: - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView setUserInteractionEnabled:NO];
    
    TransactionDetailsViewController *vc = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"TransactionDetailsViewController"];
    vc.transaction = self.displayedTransactions[indexPath.row];
    
    __weak CompleteTransactionStatementViewController *weakSelf = self;
    __weak TransactionDetailsViewController *weakVC = vc;
        
    vc.closeViewControllerBlock = ^{
        [weakSelf.tableView setUserInteractionEnabled:YES];
        [weakVC willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect newFrame = CGRectMake(weakSelf.view.frame.size.width,
                                                          weakVC.view.frame.origin.y,
                                                          weakVC.view.frame.size.width,
                                                          weakVC.view.frame.size.height);
                             weakVC.view.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             [weakVC.view removeFromSuperview];
                             [weakVC removeFromParentViewController];
                         }];
    };
    
    vc.view.frame = CGRectMake(self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect newFrame = CGRectMake(0.0,
                                                      vc.view.frame.origin.y,
                                                      vc.view.frame.size.width,
                                                      vc.view.frame.size.height);
                         vc.view.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         [vc didMoveToParentViewController:weakSelf];
                     }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
    // Obtém o atual "último/mais abaixo" ponto visível da scrollView
    double currentPoint = aScrollView.contentOffset.y + aScrollView.bounds.size.height - aScrollView.contentInset.bottom;
    
    // Carrega mais transações se estiver a "3 scrollViews" do fim da scrollView
    double reloadDistance = 3 * (aScrollView.bounds.size.height);
    
    /*
     * Se ainda houverem transações para o período a serem baixadas e estiver próximo
     * do fim da tabela, baixa mais transações.
     */
    if ([self selectedTransactionPeriod] > self.currentDownloadedTransactionsPeriod &&
        currentPoint > aScrollView.contentSize.height - reloadDistance) {
        [self listTransactionsWithStartingIndex:(int)self.downloadedTransactions.count];
    }
}

// MARK: - Services

- (void)listTransactionsWithStartingIndex:(int)index {
    static BOOL isDownloading = NO;
    
    if (isDownloading) {
        return;
    }
    
    Services *service = [[Services alloc] init];
    __block int i = index;
    
    service.successCase = ^(NSArray *transactions) {
        [self.downloadedTransactions addObjectsFromArray:transactions];
        
        // Atualiza o período de transações já baixadas.
        for (TransactionsPeriod i = self.currentDownloadedTransactionsPeriod+1; i < TransactionsPeriodAll; i++) {
            /*
             * Se há mais transações baixadas do que para o período i, então baixou todas as transações
             * para o período i.
             * Caso contrário, ainda não baixou todas para o período i e, como consequência, para os
             * períodos subsequentes também.
             */
            if ([self downloadedTransactionsForPeriod:i].count < self.downloadedTransactions.count) {
                self.currentDownloadedTransactionsPeriod = i;
            } else {
                break;
            }
        }
        
        // Se baixou menos transações que o solicitado, então baixou todas as transações do usuário
        if (transactions.count < _batch) {
            self.currentDownloadedTransactionsPeriod = TransactionsPeriodAll;
        }
                
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDisplayedTransactions];
        });
        
        isDownloading = NO;
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        /*
         * Se o erro não for "Transações inexistentes", tenta baixar novamente
         * Se for, informa que já baixou todas as transações
         */
        if (![cod isEqualToString:@"33.7"]) {
            [self listTransactionsWithStartingIndex:i];
        } else {
            self.currentDownloadedTransactionsPeriod = TransactionsPeriodAll;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateDisplayedTransactions];
            });
        }
        
        isDownloading = NO;
    };
    
    isDownloading = YES;
    [service listTransactionsWithStartingItemIndex:[NSNumber numberWithInt:index] itemCount:[NSNumber numberWithInt:self.batch]];
}

// MARK: - Auxiliar methods

- (void)updateDisplayedTransactions {
    self.displayedTransactions = [self downloadedTransactionsForPeriod:[self selectedTransactionPeriod]];
    [self.tableView reloadData];
    
    /*
     * O código comentado abaixo anima a inserção e remoção de células da tabela, sem precisar
     * dar um reloadData, mas requer modificação para atender o caso de inserção/remoção/manutenção
     * da linha que indica que mais transações estão sendo carregadas.
     */
//    unsigned long previousDisplayedTransactionsCount = self.displayedTransactions.count;
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    if (self.displayedTransactions.count > previousDisplayedTransactionsCount) {
//        for (unsigned long i = previousDisplayedTransactionsCount; i < self.displayedTransactions.count; i++) {
//            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//        
//        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
//    } else {
//        for (unsigned long i = self.displayedTransactions.count; i < previousDisplayedTransactionsCount; i++) {
//            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//        
//        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
//    }
}

- (NSArray *)downloadedTransactionsForPeriod:(TransactionsPeriod)period {
    int numberOfDays = 0;
    
    switch (period) {
        case TransactionsPeriod3Days:
            numberOfDays = -3;
            break;
        case TransactionsPeriod30Days:
            numberOfDays = -30;
            break;
        case TransactionsPeriod90Days:
            numberOfDays = -90;
            break;
        case TransactionsPeriod365Days:
            numberOfDays = -365;
            break;
        default:
            numberOfDays = 0;
            break;
    }
    
    // Cria um predicado que filtra transações dos últimos numberOfDays dias
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        // Desconta 30 dias da data atual
        NSDate *thirdyDaysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                         value:numberOfDays
                                                                        toDate:[NSDate date]
                                                                       options:0];
        
        // Cria um DateComponents com a data de 30 dias atrás e configura o horário para 00:00:00
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                       fromDate:thirdyDaysAgo];
        components.hour = 0; components.minute = 0; components.second = 0;
        components.calendar = [NSCalendar currentCalendar];
        
        // Caso a data da transação recebida seja posterior a 30 dias, inclui ela
        if ([((Transaction *)evaluatedObject).paidAt compare:[components date]] == NSOrderedDescending) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    // Filtra as transações recebidas dos últimos 30 dias
    return [self.downloadedTransactions filteredArrayUsingPredicate:predicate];
}

- (TransactionsPeriod)selectedTransactionPeriod {
    return self.segmentedControl.selectedSegmentIndex + 1;
}

// MARK: - Layout

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Extrato Completo";
    
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    self.segmentedControl.tintColor = [[LayoutManager sharedManager] primaryColor];
    NSDictionary *onAttributes = [NSDictionary dictionaryWithObject:[LayoutManager sharedManager].lightFontColor
                                                           forKey: NSForegroundColorAttributeName];
    NSDictionary *offAttributes = [NSDictionary dictionaryWithObject:[LayoutManager sharedManager].darkFontColor
                                                           forKey: NSForegroundColorAttributeName];
    [self.segmentedControl setTitleTextAttributes:onAttributes
                                         forState:UIControlStateSelected];
    [self.segmentedControl setTitleTextAttributes:offAttributes
                                         forState:UIControlStateNormal];
    
    
    // Configura a label que informa quando não há transações a serem exibidas
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.font = [[LayoutManager sharedManager] fontWithSize:16.0];
    self.emptyLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.text = @"Não existem transações no período selecionado.";
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.emptyLabel];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[emptyLabel]-20-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"emptyLabel":self.emptyLabel}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[emptyLabel]-10-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"emptyLabel":self.emptyLabel}]];
    
    self.emptyLabel.hidden = YES;
    
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

@end
