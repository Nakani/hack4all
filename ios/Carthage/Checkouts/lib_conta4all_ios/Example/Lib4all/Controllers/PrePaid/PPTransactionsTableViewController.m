//
//  PPTransactionsTableViewController.m
//  Example
//
//  Created by Adriano Soares on 08/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPTransactionsTableViewController.h"
#import "MyReachability.h"
#import "UIImage+Color.h"
#import "LayoutManager.h"
#import "PrePaidServices.h"
#import "DateUtil.h"
#import "Lib4allPreferences.h"
#import "AnalyticsUtil.h"

@interface PPTransactionsTableViewController ()

@property UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addCreditLabel;

@property (strong, nonatomic) NSArray *statements;
@property (strong, nonatomic) NSDictionary *months;
@property (strong, nonatomic) NSArray *sortedKeys;
@property BOOL isLoading;
@property double lastCreatedAt;
@property double lastContentOffset;

@property (strong, nonatomic) NSString *balanceTypeFriendlyName;

@end

@implementation PPTransactionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
    if (self.statements == nil || self.statements.count == 0) {
        [self.refreshControl beginRefreshing];
        [self loadData];
    }
    
    self.balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    
    [self configureLayout];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];

}

- (void) loadData {
    
    MyReachability *networkReachability = [MyReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
        [self.tableView setHidden:YES];
        self.descriptionLabel.text = @"Você está offline, por isso não foi possível carregar os dados.";
        self.addCreditLabel.hidden = YES;
        
    } else {
        PrePaidServices *services = [[PrePaidServices alloc] init];
        
        services.failureCase = ^(NSString *cod, NSString *msg) {
            self.statements = @[];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
            
        };
        
        services.successCase = ^(NSDictionary *response) {
            [self configureLayout];
            self.addCreditLabel.hidden = NO;
            
            self.statements = (NSArray *)response;
            if (self.statements.count == 0) {
                [self.tableView setHidden:YES];
                
            } else {
                [self.tableView setHidden:NO];
                [self filterByMonth];
                [self.tableView reloadData];
                _isLoading = NO;
                [self.refreshControl endRefreshing];
            }
            
        };
        
        _isLoading = YES;
        
        [services listStatements:(StatementSource) self.transactionFilter];
    }
}

- (void) loadMoreData {
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        _isLoading = NO;
    };
    
    services.successCase = ^(NSDictionary *response) {
        self.statements = [self.statements arrayByAddingObjectsFromArray:(NSArray *)response];
        if ([(NSArray *)response count] > 0) {
            [self filterByMonth];
            [self.tableView reloadData];
            _isLoading = NO;
        
        }

    };
    
    _isLoading = YES;
    
    [services listStatements:(StatementSource) self.transactionFilter before:self.lastCreatedAt];
}

- (void) filterByMonth {
    NSMutableDictionary *months = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.statements.count; i++) {
        NSString *type        = [self.statements[i] objectForKey:@"type"];
        NSDictionary *payload = [self.statements[i] objectForKey:type];
        
        double lastCreatedAt = [[payload objectForKey:@"createdAt"] doubleValue];
        NSDate *createdAt     = [NSDate dateWithTimeIntervalSince1970:[[payload objectForKey:@"createdAt"] doubleValue]/1000];
        /*
        if ([type isEqualToString:@"paymentCashIn"]) {
            NSDictionary *paymentPayload = [payload objectForKey:@"payment"];
            lastCreatedAt = [[paymentPayload objectForKey:@"createdAt"] doubleValue];
            createdAt = [NSDate dateWithTimeIntervalSince1970:[[paymentPayload objectForKey:@"createdAt"] doubleValue]/1000];
        }
        */
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM"];
        NSString *date = [format stringFromDate:createdAt];
        
        NSDictionary *dict = @{
           @"payload" : payload,
           @"type"    : type
        };
        if ([months objectForKey:date] == nil) {
            [months setObject:@[dict] forKey:date];
        } else {
            NSMutableArray *statements = [[months objectForKey:date] mutableCopy];
            [statements addObject:dict];
            [months setObject:statements forKey:date];
        }
        
        self.lastCreatedAt = lastCreatedAt;
    }
    
    self.sortedKeys = [months.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
    self.months = months;

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell" forIndexPath:indexPath];
    NSString *key         = self.sortedKeys[indexPath.section];
    NSDictionary *payload = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"payload"];
    NSString *type        = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    LayoutManager *layout = [LayoutManager sharedManager];

    BOOL isIncoming = NO;
    if ([type isEqualToString:@"deposit"] || [type isEqualToString:@"cashback"] || [type isEqualToString:@"paymentCashIn"]) {
        isIncoming = YES;
    }
    if ([type isEqualToString:@"p2pTransfer"]) {
        if ([[payload objectForKey:@"amount"] doubleValue] > 0) {
            isIncoming = YES;
        }
    }

    UIImageView *icon = [cell viewWithTag:1];
    
    UILabel *name  = [cell viewWithTag:2];
    
    UIView *separator  = [cell viewWithTag:5];
    
    icon.image = nil;
    name.text  = nil;
    
    id status = [payload objectForKey:@"status"];
    
    if ([type isEqualToString:@"deposit"]) {
        
        if (status )
        
        if ([payload objectForKey:@"change"] != nil && [[payload objectForKey:@"change"] boolValue]) {
            name.text  = @"Troco";
            icon.image = [UIImage lib4allImageNamed:@"icone_dinheiro"];
        } else {
            name.text  = @"Depósito";
            icon.image = [UIImage lib4allImageNamed:@"deposito"];
        }
    }
    
    if ([type isEqualToString:@"withdrawal"]) {
        name.text = @"Saque";
        icon.image = [UIImage lib4allImageNamed:@"saque"];
    }
    
    if ([type isEqualToString:@"cashback"]) {
        name.text = @"Cashback";
        icon.image = [UIImage lib4allImageNamed:@"fidelidade"];
    }
    
    if ([type isEqualToString:@"p2pTransfer"]) {
        name.text = [payload objectForKey:@"peerName"];
        if (isIncoming) {
            icon.image = [UIImage lib4allImageNamed:@"transferencia-para-conta-do-usuario"];
        } else {
            icon.image = [UIImage lib4allImageNamed:@"transferencia-para-outro-usuario"];
        }
    }
    
    if ([type isEqualToString:@"payment"]) {
        name.text = [[payload objectForKey:@"merchantInfo"] objectForKey:@"name"];
        NSInteger method = [[payload objectForKey:@"paymentMode"] integerValue];
        switch (method) {
            case 1:
                icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
                
                break;
            case 2:
                icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
                
                break;
            case 3:
                icon.image = [UIImage lib4allImageNamed:@"boleto"];
                icon.image = [icon.image withColor:[layout transactionsPaymentSlipColor]];

                break;
            case 5:
                icon.image = [UIImage lib4allImageNamed:@"pagamento-saldo-conta"];
                break;
        }
        id familyProfileInfo = [payload objectForKey:@"familyProfileInfo"];
        if (familyProfileInfo && familyProfileInfo != [NSNull null]) {
            icon.image = [UIImage lib4allImageNamed:@"icone_cartao_compartilhado"];
            
        }
    }
    
    if ([type isEqualToString:@"paymentCashIn"]) {
        NSInteger method = [[[payload objectForKey:@"payment"] objectForKey:@"paymentMode"] integerValue];
        switch (method) {
            case 1:
                icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
                icon.image = [icon.image withColor:layout.creditStatementColor];
                name.text = @"Cartão de crédito";
                
                break;
            case 2:
                icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
                icon.image = [icon.image withColor:layout.creditStatementColor];
                name.text = @"Cartão de débito";
                
                break;
            case 3:
                icon.image = [UIImage lib4allImageNamed:@"boleto"];
                name.text = @"Boleto";
                
                break;
        }
    }
    

    
    name.font = [layout boldFontWithSize:layout.regularFontSize];

    
    NSDate *createdAt     = [NSDate dateWithTimeIntervalSince1970:[[payload objectForKey:@"createdAt"] doubleValue]/1000];
    /*
    if ([type isEqualToString:@"paymentCashIn"]) {
        NSDictionary *paymentPayload = [payload objectForKey:@"payment"];
        createdAt = [NSDate dateWithTimeIntervalSince1970:[[paymentPayload objectForKey:@"createdAt"] doubleValue]/1000];
    }
    */
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM"];
    NSString *dateStr   = [format stringFromDate:createdAt];
    
    NSString *statusStr = @"";
    if (status && ![type isEqualToString:@"payment"]) {
        if([status intValue] == 0) statusStr = @"Pendente";
        if([status intValue] == 1) statusStr = @"Concluido";
        if([status intValue] == 2) statusStr = @"Cancelado";
    }
    
    if ([type isEqualToString:@"payment"])  {
        statusStr = payload[@"reasonMessage"];
        //Mudança feita dia 27/07/2017:
        //Adaptação feita a pedido do Fhilipe Linhares para não quebrar o layout com o texto do backend
        if ([statusStr rangeOfString:@"."].location != NSNotFound) {
            statusStr = [statusStr substringToIndex:[statusStr rangeOfString:@"."].location];
        }
    }
    
    UILabel *date  = [cell viewWithTag:3];
    date.text = [NSString stringWithFormat:@"%@ - %@", dateStr, statusStr];
    
    date.font      = [layout fontWithSize:layout.regularFontSize];

    UILabel *value = [cell viewWithTag:4];
    double amount = 0;
    if ([type isEqualToString:@"payment"] || [type isEqualToString:@"paymentCashIn"]) {
        NSDictionary *payment = payload;
        if ([type isEqualToString:@"paymentCashIn"]) {
            payment = [payload objectForKey:@"payment"];
        }
        amount = ABS([[payment objectForKey:@"amount"] doubleValue]);
        
    } else {
        amount = ABS([[payload objectForKey:@"amount"] doubleValue]);
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    value.text = [formatter stringFromNumber: [NSNumber numberWithFloat:amount/100]];
    value.text = [value.text stringByReplacingOccurrencesOfString:@"R$" withString:@"- R$ "];
    if (isIncoming) {
        value.text = [value.text stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    }

    value.font = [layout boldFontWithSize:layout.regularFontSize];

    if (([status intValue] == 0) || ([type isEqualToString:@"payment"] && ([status intValue] == 1 || [status intValue] == 9))) {
        //Se for pendente
        name.textColor = layout.debitStatementColor;
        date.textColor = layout.debitStatementColor;
        value.textColor = layout.debitStatementColor;
        icon.image = [icon.image withColor:layout.debitStatementColor];
        cell.contentView.alpha = 0.55;
    } else if (isIncoming) {
        //Senão, se for entrada
        name.textColor = layout.creditStatementColor;
        date.textColor = layout.creditStatementColor;
        value.textColor = layout.creditStatementColor;
        icon.image = [icon.image withColor:layout.creditStatementColor];
        cell.contentView.alpha = 1;
    } else {
        //Senão é saída
        name.textColor = layout.debitStatementColor;
        date.textColor = layout.debitStatementColor;
        value.textColor = layout.debitStatementColor;
        icon.image = [icon.image withColor:layout.debitStatementColor];
        cell.contentView.alpha = 1;
    }

    separator.alpha = 1;
    
    NSMutableAttributedString *att = [value.attributedText mutableCopy];
    [att addAttribute:NSFontAttributeName
                value:[layout fontWithSize:layout.regularFontSize]
                range:[value.text rangeOfString:@"+"]];
    
    [att addAttribute:NSFontAttributeName
                value:[layout fontWithSize:layout.regularFontSize]
                range:[value.text rangeOfString:@"-"]];
    
    [att addAttribute:NSFontAttributeName
                value:[layout fontWithSize:layout.regularFontSize]
                range:[value.text rangeOfString:@"R$"]];
    value.attributedText = att;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sortedKeys.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sortedKeys[section];
    
    return [[self.months objectForKey:key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];

    UILabel *label = [cell viewWithTag:1];
    NSString *key = self.sortedKeys[section];
    
    NSString *date = [DateUtil convertDateString:key fromFormat:@"yyyy-MM" toFormat:@"MMMM 'de' yyyy"];
    
    date = [date stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[date substringToIndex:1] uppercaseString]];
    label.text = date;
    
    LayoutManager *layout = [LayoutManager sharedManager];
    label.font      = [layout fontWithSize:layout.regularFontSize];
    label.textColor = [layout debitStatementColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 30;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.lastContentOffset < scrollView.contentOffset.y) {
        //scrollView moved to top
        if(self.tableView.contentSize.height > self.tableView.frame.size.height + 75) {
            if (self.didScroll) {
                self.didScroll(scrollView);
            }
        }
    } else {
        //scrollView moved to bottom
        if (self.didScroll) {
            self.didScroll(scrollView);
        }
    }
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;

    
    float reload_distance = 0;
    if(y > h + reload_distance) {
        if (!self.isLoading) {
            [self loadMoreData];
        }   
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [AnalyticsUtil logEventWithName:@"detalhes_transacao" andParameters:nil];
    
    NSString *key         = self.sortedKeys[indexPath.section];
    NSDictionary *payload = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"payload"];
    NSString *type        = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    if ([type isEqualToString:@"deposit"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeDeposit withData:payload];
    }
    if ([type isEqualToString:@"withdrawal"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeWithdraw withData:payload];
    }
    if ([type isEqualToString:@"p2pTransfer"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeTransfer withData:payload];
    }
    if ([type isEqualToString:@"payment"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeTransaction withData:payload];
    }
    if ([type isEqualToString:@"paymentCashIn"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeCashInPaymentSlip withData:payload];
    }
    if ([type isEqualToString:@"cashback"]) {
        [_rootViewController showReceiptOfType:ReceiptTypeDeposit withData:payload];
    }
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];

    [self.addCreditLabel setText:[NSString stringWithFormat:@"Aproveite para adicionar dinheiro na sua Carteira %@", self.balanceTypeFriendlyName]];
    
    switch (self.transactionFilter) {
        case PPTransactionFilterAll:
            self.descriptionLabel.text = [NSString stringWithFormat: @"Ops! Você ainda não realizou nenhum pagamento com a Carteira %@", self.balanceTypeFriendlyName];
            break;
        case PPTransactionFilterIn:
            self.descriptionLabel.text = [NSString stringWithFormat: @"Ops! Você não tem saldo na sua Carteira %@", self.balanceTypeFriendlyName];
            break;
        case PPTransactionFilterOut:
            self.descriptionLabel.text = [NSString stringWithFormat: @"Ops! Você ainda não realizou nenhum pagamento com a Carteira %@", self.balanceTypeFriendlyName];
//            self.addCreditLabel.text   = [NSString stringWithFormat: @"Use a sua Carteira 4all e deixe tudo mais verde com a gente :)", self.balanceTypeFriendlyName];
            break;
    }
    
    self.descriptionLabel.font      = [layout fontWithSize:layout.regularFontSize];
    self.descriptionLabel.textColor = [layout darkFontColor];

    self.addCreditLabel.font      = [layout boldFontWithSize:layout.regularFontSize];
    self.addCreditLabel.textColor = [layout darkFontColor];

}

@end
