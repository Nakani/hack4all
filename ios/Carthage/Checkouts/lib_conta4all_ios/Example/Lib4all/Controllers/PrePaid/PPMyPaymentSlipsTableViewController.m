//
//  PPMyPaymentSlipsTableViewController.m
//  Example
//
//  Created by Luciano Bohrer on 22/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPMyPaymentSlipsTableViewController.h"
#import "LayoutManager.h"
#import "PrePaidServices.h"
#import "DateUtil.h"
#import "UIImage+Color.h"
#import "Lib4allPreferences.h"

@interface PPMyPaymentSlipsTableViewController () <UITabBarDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;


@property (strong, nonatomic) NSArray *cashIns;
@property (strong, nonatomic) NSDictionary *months;
@property (strong, nonatomic) NSArray *sortedKeys;
@property BOOL isLoading;
@property double lastCreatedAt;

@property (weak, nonatomic) IBOutlet UILabel *noPaymentSlipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashInLabel;
@end

@implementation PPMyPaymentSlipsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];

    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.cashIns == nil) {
        [self.refreshControl beginRefreshing];
        [self loadData];
    }

}

- (void) loadData {
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        self.cashIns = @[];
        [self.refreshControl endRefreshing];
        [self.view layoutSubviews];
        [self.view updateConstraints];
        [self.tableView reloadData];
    };
    
    services.successCase = ^(NSDictionary *response) {
        self.cashIns = (NSArray *)response;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.view layoutSubviews];
            [self.view updateConstraints];
            if ([self.cashIns count] == 0) {
                [self.tableView setHidden:YES];
                
            } else {
                [self filterByMonth];
                [self.tableView reloadData];
                _isLoading = NO;
            }
            
            
            
        });

    };
    
    _isLoading = YES;
    
    [services paymentCashIn:0];
}

- (void) loadMoreData {
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        _isLoading = NO;
    };
    
    services.successCase = ^(NSDictionary *response) {
        self.cashIns = [self.cashIns arrayByAddingObjectsFromArray:(NSArray *)response];
        [self filterByMonth];
        [self.tableView reloadData];
        if ([(NSArray *)response count] > 0) {
            _isLoading = NO;
        }
        
    };
    
    _isLoading = YES;
    
    [services paymentCashIn:_lastCreatedAt];
}

- (void) filterByMonth {
    NSMutableDictionary *months = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.cashIns.count; i++) {
        
        NSDictionary *paymentPayload = [self.cashIns[i] objectForKey:@"payment"];
        double lastCreatedAt = [[self.cashIns[i] objectForKey:@"createdAt"] doubleValue];
        NSDate *createdAt = [NSDate dateWithTimeIntervalSince1970:lastCreatedAt/1000];

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM"];
        NSString *date = [format stringFromDate:createdAt];
        
        NSDictionary *dict = @{
                               @"payload" : _cashIns[i]
                               };
        if ([months objectForKey:date] == nil) {
            [months setObject:@[dict] forKey:date];
        } else {
            NSMutableArray *cashIns = [[months objectForKey:date] mutableCopy];
            [cashIns addObject:dict];
            [months setObject:cashIns forKey:date];
        }
        
        self.lastCreatedAt = lastCreatedAt;
    }
    self.sortedKeys = [months.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
    self.months = months;
    
}

- (IBAction)cashInTouched:(id)sender {
    [self.parentVC.tabBarViewController setSelectedIndex:0];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sortedKeys.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sortedKeys[section];
    
    return [[self.months objectForKey:key] count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell" forIndexPath:indexPath];
    LayoutManager *layout = [LayoutManager sharedManager];
    NSString *key         = self.sortedKeys[indexPath.section];
    NSDictionary *payload = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"payload"];
    
    UILabel *labelStatus  = [cell viewWithTag:1];
    UILabel *labelDate    = [cell viewWithTag:2];
    UILabel *labelAmount  = [cell viewWithTag:3];
    UIImageView *icon     = [cell viewWithTag:4];
    
    labelStatus.font = [layout boldFontWithSize:layout.regularFontSize];
    labelDate.font      = [layout fontWithSize:layout.regularFontSize];
    labelAmount.font = [layout boldFontWithSize:layout.regularFontSize];
    
    id status = [payload objectForKey:@"status"];
    
    if([status integerValue] == 1){
        labelStatus.text = @"Concluido";
        labelStatus.textColor = layout.creditStatementColor;
        labelDate.textColor = layout.creditStatementColor;
        labelAmount.textColor = layout.creditStatementColor;
        icon.image  = [icon.image withColor:[layout creditStatementColor]];
    }else{
        labelStatus.textColor = layout.debitStatementColor;
        labelDate.textColor = layout.debitStatementColor;
        labelAmount.textColor = layout.debitStatementColor;
        icon.image  = [icon.image withColor:[layout debitStatementColor]];
        
    }
    
    if([status integerValue] == 0){
        labelStatus.text = @"Pendente";
    }
    
    if([status integerValue] == 2) {
        labelStatus.text = @"Cancelado";
        
    }
    
    NSDate *createdAt     = [NSDate dateWithTimeIntervalSince1970:[[payload  objectForKey:@"createdAt"] doubleValue]/1000];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM"];
    NSString *dateStr   = [format stringFromDate:createdAt];
    labelDate.text = dateStr;
    double amount = 0;
    amount = ABS([[[payload objectForKey:@"payment"] objectForKey:@"amount"] doubleValue]);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    labelAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:amount/100]];
    labelAmount.text = [labelAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"+ R$ "];
    
    if([status integerValue] != 1){
        labelAmount.text = [labelAmount.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.backgroundColor = [[LayoutManager sharedManager] lightGray];
    
    NSString *key = self.sortedKeys[section];
    NSString *date = [DateUtil convertDateString:key fromFormat:@"yyyy-MM" toFormat:@"MMMM 'de' yyyy"];
    
    date = [date stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[date substringToIndex:1] uppercaseString]];
    header.textLabel.text = date;
    
    LayoutManager *layout = [LayoutManager sharedManager];
    header.textLabel.font      = [layout fontWithSize:layout.regularFontSize];
    header.textLabel.textColor = [layout debitStatementColor];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.didScroll) {
//        self.didScroll(scrollView);
//    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key         = self.sortedKeys[indexPath.section];
    NSDictionary *payload = [[self.months[key] objectAtIndex:indexPath.row] objectForKey:@"payload"];
    
    [_parentVC showReceiptOfType:ReceiptTypeCashInPaymentSlip withData:payload];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}


- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    
    self.noPaymentSlipsLabel.font      = [layout fontWithSize:layout.regularFontSize];
    self.noPaymentSlipsLabel.textColor = [layout darkFontColor];
    
    self.cashInLabel.font      = [layout boldFontWithSize:layout.regularFontSize];
    self.cashInLabel.textColor = [layout darkFontColor];
    
    [self.cashInLabel setText: [NSString stringWithFormat: @"Aproveite para adicionar dinheiro na sua Carteira %@", [Lib4allPreferences sharedInstance].balanceTypeFriendlyName]];

}

@end
