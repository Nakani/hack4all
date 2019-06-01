//
//  SubscriptionsViewController.m
//  Example
//
//  Created by Cristiano Matte on 31/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SubscriptionsViewController.h"
#import "TransactionDetailsViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "Subscription.h"
#import "Transaction.h"
#import "UIImage+Color.h"

// MARK: - SubscriptionTableViewCell

@interface SubscriptionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosure;

@end

@implementation SubscriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.dateLabel.font = [layoutManager fontWithSize:16.0];
    self.dateLabel.textColor = [layoutManager darkFontColor];
    
    self.placeLabel.font = [layoutManager fontWithSize:22.0];
    self.placeLabel.textColor = [layoutManager darkFontColor];
    
    self.recurrencyLabel.font = [layoutManager fontWithSize:16.0];
    self.recurrencyLabel.textColor = [layoutManager darkFontColor];
    
    self.currencyLabel.font = [layoutManager fontWithSize:14.0];
    self.currencyLabel.textColor = [layoutManager darkFontColor];
    
    self.amountLabel.font = [layoutManager fontWithSize:22.0];
    self.amountLabel.textColor = [layoutManager darkFontColor];
    
    self.disclosure.image = [self.disclosure.image withColor:layoutManager.primaryColor];
    }

@end


// MARK: - SubscriptionsViewController

@interface SubscriptionsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, atomic) NSMutableArray *subscriptions;
@property (readonly, atomic) int batch;
@property BOOL downloadedAllSubscriptions;

@end

@implementation SubscriptionsViewController

@synthesize batch = _batch;

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 58;
    
    self.downloadedAllSubscriptions = NO;
    _batch = 30;
    self.subscriptions = [[NSMutableArray alloc] init];
    [self listSubscriptionsWithStartingIndex:0];
}

- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Se não há assinaturas para o período selecionado, exibe a emptyLabel
    if (self.downloadedAllSubscriptions && self.subscriptions.count == 0) {
        self.emptyLabel.hidden = NO;
    } else {
        self.emptyLabel.hidden = YES;
    }
    
    return self.downloadedAllSubscriptions ? self.subscriptions.count : self.subscriptions.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Verifica se o indexPath é da célular de "Carregando..."
    if (indexPath.row == self.subscriptions.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        
        UILabel *loadingLabel = [cell viewWithTag:1];
        loadingLabel.font = [[LayoutManager sharedManager] fontWithSize:15.0];
        loadingLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
        
        return cell;
    }
    
    SubscriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell" forIndexPath:indexPath];
    Subscription *subscription = self.subscriptions[indexPath.row];
    
    cell.placeLabel.text = subscription.merchant.name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMM";
    if (subscription.nextPaymentDate != nil) {
        cell.dateLabel.text = [@"Próximo venc.: " stringByAppendingString:[dateFormatter stringFromDate:subscription.nextPaymentDate]];
    }else{
        cell.dateLabel.text = @"";
    }
    
    // Exibe o valor com o separador de decimais localizado
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = numberFormatter.minimumFractionDigits = 2;
    cell.amountLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[subscription.recurringAmount doubleValue] / 100.0]];
    
    return cell;
}

// MARK: - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView setUserInteractionEnabled:NO];
    
    TransactionDetailsViewController *vc = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"TransactionDetailsViewController"];
    
    /*
     * TODO: Code smell. O TransactionDetailsViewController recebe uma Transaction para
     * exibir os dados, e por isso está convertendo a subscription selecionada para uma
     * transaction. Buscar uma solução mais genérica.
     */
    Subscription *subscription = self.subscriptions[indexPath.row];
    Transaction *transaction = [[Transaction alloc] init];
    transaction.subscriptionID = subscription.subscriptionID;
    transaction.amount = subscription.recurringAmount;
    transaction.merchant = subscription.merchant;
    transaction.status = subscription.status;
    vc.transaction = transaction;
    vc.showAsSubscriptionDetails = YES;
    
    __weak SubscriptionsViewController *weakSelf = self;
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
    
    // Carrega mais assinaturas se estiver a "3 scrollViews" do fim da scrollView
    double reloadDistance = 3 * (aScrollView.bounds.size.height);
    
    /*
     * Se ainda houverem assinaturas para o período a serem baixadas e estiver próximo
     * do fim da tabela, baixa mais assinaturas.
     */
    if (!self.downloadedAllSubscriptions && currentPoint > aScrollView.contentSize.height - reloadDistance) {
        [self listSubscriptionsWithStartingIndex:(int)self.subscriptions.count];
    }
}

// MARK: - Services

- (void)listSubscriptionsWithStartingIndex:(int)index {
    static BOOL isDownloading = NO;
    
    if (isDownloading) {
        return;
    }
    
    Services *service = [[Services alloc] init];
    __block int i = index;
    
    service.successCase = ^(NSArray *subscriptions) {
        [self.subscriptions addObjectsFromArray:subscriptions];
        
        // Se baixou menos assinaturas que o solicitado, então baixou todas as assinaturas do usuário
        if (subscriptions.count < _batch) {
            self.downloadedAllSubscriptions = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        isDownloading = NO;
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        /*
         * Se o erro não for "Assinaturas inexistentes", tenta baixar novamente
         * Se for, informa que já baixou todas as transações
         */
        if (![cod isEqualToString:@"33.7"]) {
            [self listSubscriptionsWithStartingIndex:i];
        } else {
            self.downloadedAllSubscriptions = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        isDownloading = NO;
    };
    
    isDownloading = YES;
    [service listSubscriptionsWithStartingItemIndex:[NSNumber numberWithInt:index] itemCount:[NSNumber numberWithInt:self.batch]];
}

// MARK: - Layout

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Assinaturas";
    
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
        
    // Configura a label que informa quando não há assinaturas a serem exibidas
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.font = [[LayoutManager sharedManager] fontWithSize:16.0];
    self.emptyLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.text = @"Não existem assinaturas.";
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
