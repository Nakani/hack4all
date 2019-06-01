//
//  SimpleTransactionStatementViewController.m
//  Example
//
//  Created by Cristiano Matte on 28/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SimpleTransactionStatementViewController.h"
#import "CompleteTransactionStatementViewController.h"
#import "BaseNavigationController.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "Transaction.h"

// MARK: - SimpleTransactionTableViewCell

@interface SimpleTransactionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation SimpleTransactionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.dateLabel.font = [layoutManager fontWithSize:16.0];
    self.dateLabel.textColor = [layoutManager darkFontColor];
    
    self.placeLabel.font = [layoutManager fontWithSize:22.0];
    self.placeLabel.textColor = [layoutManager darkFontColor];
    
    self.categoryLabel.font = [layoutManager fontWithSize:18.0];
    self.categoryLabel.textColor = [layoutManager darkFontColor];
    
    self.currencyLabel.font = [layoutManager fontWithSize:14.0];
    self.currencyLabel.textColor = [layoutManager darkFontColor];
    
    self.amountLabel.font = [layoutManager fontWithSize:22.0];
    self.amountLabel.textColor = [layoutManager darkFontColor];
}

@end


// MARK: - SimpleTransactionStatementViewController

@interface SimpleTransactionStatementViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lastTransactionsLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *completeTransactionsButton;

@property (atomic) BOOL didFinishListingLastThreeTransactions;
@property (strong, atomic) NSMutableArray *lastThreeTransactions;
@property (strong, atomic) NSMutableArray *lastThirdyDaysTransactions;

@end

@implementation SimpleTransactionStatementViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    self.didFinishListingLastThreeTransactions = NO;
    self.lastThreeTransactions = [[NSMutableArray alloc] initWithCapacity:3];
    self.lastThirdyDaysTransactions = [[NSMutableArray alloc] initWithCapacity:30];
    [self listTransactionsWithStartingIndex:0];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 58;
    self.tableView.scrollEnabled = NO;
}

// MARK: - Actions

- (void)buttonHighlight:(UIButton*)sender {
    self.completeTransactionsButton.layer.borderColor = [[[LayoutManager sharedManager] gradientColor] CGColor];
}

- (void)buttonNormal:(UIButton*)sender {
    self.completeTransactionsButton.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Exibe no máximo 3 transações
    return MIN(3, self.lastThreeTransactions.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleTransactionCell" forIndexPath:indexPath];
    
    Transaction *transaction = self.lastThreeTransactions[indexPath.row];
    
    cell.placeLabel.text = transaction.merchant.name;
    cell.categoryLabel.text = @"TODO";
    
    NSCalendar *calendar      = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    NSInteger currentWeek     = [[calendar components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]] weekOfYear];
    NSInteger transacitonWeek = [[calendar components:NSCalendarUnitWeekOfYear fromDate:[transaction paidAt]] weekOfYear];
    
    /*
     * Se transação foi na semana corrente, exibe dia da semana.
     * Caso contrário, exibe data do pagamento
     */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (transacitonWeek == currentWeek) {
        [dateFormatter setDateFormat:@"EEEE"];
        cell.dateLabel.text = [[dateFormatter stringFromDate:[transaction paidAt]] capitalizedString];
    } else {
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        cell.dateLabel.text = [dateFormatter stringFromDate:[transaction paidAt]];
    }
    
    // Exibe o valor com o separador de decimais localizado
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = numberFormatter.minimumFractionDigits = 2;
    cell.amountLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[transaction.amount doubleValue] / 100.0]];

    return cell;
}

// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCompleteTransactionStatement"]) {
        CompleteTransactionStatementViewController *viewController = segue.destinationViewController;
        
        viewController.downloadedTransactions = self.lastThirdyDaysTransactions;
        viewController.currentDownloadedTransactionsPeriod = TransactionsPeriod30Days;
    }
}

// MARK: - Services

- (void)listTransactionsWithStartingIndex:(int)index {
    Services *service = [[Services alloc] init];
    __block int i = index;
    __block int batch = 30;
    
    service.successCase = ^(NSArray *transactions) {
        // Exibe as 3 últimas transações no extrato
        if (i == 0) {
            self.lastThreeTransactions = (NSMutableArray *)[transactions subarrayWithRange:NSMakeRange(0, MIN(3, transactions.count))];
            self.didFinishListingLastThreeTransactions = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        // Cria um predicado que filtra transações dos últimos 30 dias
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            // Desconta 30 dias da data atual
            NSDate *thirdyDaysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                             value:-30
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
        NSArray *lastThirdyDaysTransactions = [transactions filteredArrayUsingPredicate:predicate];
        [self.lastThirdyDaysTransactions addObjectsFromArray:lastThirdyDaysTransactions];
        
        /*
         * Se todas as datas recebidas estão dentro da margem dos últimos dias,
         * faz uma requisição das próximas transações ao servidor.
         * Caso contrário, informa o gráfico que deve ser carregado.
         */
        if (lastThirdyDaysTransactions.count == batch) {
            [self listTransactionsWithStartingIndex:(i + batch)];
        } else {
            // TODO: Informar que gráfico deve ser carregado
        }
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        // Se o erro não for "Transações inexistentes", tenta baixar novamente
        if (![cod isEqualToString:@"33.7"]) {
            [self listTransactionsWithStartingIndex:i];
        }
    };
    
    [service listTransactionsWithStartingItemIndex:[NSNumber numberWithInt:index] itemCount:[NSNumber numberWithInt:batch]];
}

// MARK: - Layout

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Extrato";
    
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura a label "Últimas transações"
    self.lastTransactionsLabel.font = [[LayoutManager sharedManager] boldFontWithSize:18.0];
    self.lastTransactionsLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    // Configura o botão "Extrato completo"
    self.completeTransactionsButton.layer.borderWidth = 1.0;
    self.completeTransactionsButton.layer.cornerRadius = 5.0;
    self.completeTransactionsButton.layer.borderColor = [[[LayoutManager sharedManager] primaryColor] CGColor];
    [self.completeTransactionsButton setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
    [self.completeTransactionsButton setTitleColor:[[LayoutManager sharedManager] gradientColor] forState:UIControlStateHighlighted];
    self.completeTransactionsButton.titleLabel.font = [[LayoutManager sharedManager] fontWithSize:15.0];
    [self.completeTransactionsButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.completeTransactionsButton addTarget:self action:@selector(buttonNormal:) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
}

@end
