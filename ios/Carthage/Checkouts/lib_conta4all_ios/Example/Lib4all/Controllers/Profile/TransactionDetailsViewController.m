//
//  TransactionDetailsViewController.m
//  Example
//
//  Created by Cristiano Matte on 03/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "TransactionDetailsViewController.h"
#import "SubscriptionDetailsView.h"
#import "LayoutManager.h"
#import "Services.h"

@interface TransactionDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *transactionInfoView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *merchantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityAndStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusSubscription;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transactionInfoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transactionInfoViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *transactionIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *installments;

@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation TransactionDetailsViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.transparentView addGestureRecognizer:singleFingerTap];
    
    self.typeLabel.text = self.transaction.subscriptionID != nil? @"Assinatura" : @"Compra";
    self.merchantNameLabel.text = self.transaction.merchant.name;
    self.addressLabel.text = self.transaction.merchant.street;
    self.cityAndStateLabel.text = [[self.transaction.merchant.city stringByAppendingString:@"/"] stringByAppendingString:self.transaction.merchant.state];
    
    NSString *status;
    if (self.showAsSubscriptionDetails) {
        [self.transactionIdLabel removeFromSuperview];
        [self.dateLabel removeFromSuperview];
        status = @"VALOR RECORRENTE";
        self.labelStatusSubscription.hidden = NO;

        
        switch ([self.transaction.status intValue]){
            case 0:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_awaitingPayment];
                self.labelStatusSubscription.text = @"Aguardando aprovação";
                break;
            case 1:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_processing];
                self.labelStatusSubscription.text = @"Aguardando aprovação";
                break;
            case 2:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_unApprovedPayment];
                self.labelStatusSubscription.text = @"Aguardando aprovação";
                break;
            case 3:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_paidOut];
                self.labelStatusSubscription.text = @"Pagamento em dia";
                break;
            case 4:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_awaitingReversal];
                self.labelStatusSubscription.text = @"Aguardando pagamento";
                break;
            case 5:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_reversal];
                self.labelStatusSubscription.text = @"Pagamento atrasado";
                break;
            case 6:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_unApprovedReversal];
                self.labelStatusSubscription.text = @"Assinatura vencida";
                break;
            case 7:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_awaitingcontested];
                self.labelStatusSubscription.text = @"Cancelada";
                break;
            case 8:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_contested];
                self.labelStatusSubscription.text = @"Cancelada";
                break;
            case 9:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_processing];
                self.labelStatusSubscription.text = @"Cancelada";
                break;
            case 10:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_paymentDenied];
                self.labelStatusSubscription.text = @"Em processo de encerramento";
                break;
            default:
                self.labelStatusSubscription.backgroundColor = [[LayoutManager sharedManager] status_undefined];
                self.labelStatusSubscription.text = @"Indefinido";
        }
        
    } else {
        self.transactionIdLabel.text = [@"id 4all: " stringByAppendingString:self.transaction.transactionID];
        self.labelStatusSubscription.hidden = YES;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        self.dateLabel.text = [dateFormatter stringFromDate:self.transaction.paidAt];
        
        switch ([self.transaction.status intValue]) {
            case 0:
                status = @"AGUARDANDO PAGAMENTO";
                break;
            case 1:
                status = @"EM PROCESSAMENTO";
                break;
            case 2:
                status = @"PAGAMENTO NÃO APROVADO";
                break;
            case 3:
                status = @"PAGAMENTO EFETUADO";
                break;
            case 4:
                status = @"EM CANCELAMENTO";
                break;
            case 5:
                status = @"CANCELADA";
                break;
            case 6:
                status = @"CANCELAMENTO NÃO REALIZADO";
                break;
            case 7:
                status = @"PAGAMENTO CONTESTADO. EM PROCESSO DE ANÁLISE.";
                break;
            case 8:
                status = @"CONTESTAÇÃO APROVADA";
                break;
            case 9:
                status = @"EM PROCESSAMENTO";
                break;
            default:
                break;
        }
    }

    self.statusLabel.text = status;
    
    // Exibe o valor com o separador de decimais localizado
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = numberFormatter.minimumFractionDigits = 2;
    self.amountLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self.transaction.amount doubleValue] / 100.0]];
    
    // Caso seja uma transação de assinatura, busca os dados da assinatura e insere na view
    if (self.transaction.subscriptionID) {
        [self addAndConfigureSubscriptionViews];
    }
    
    [self.installments setHidden:YES];
    
    if (self.transaction.installments > 1) {
        [self.installments setHidden:NO];
        
        self.installments.text = [NSString stringWithFormat:@"Parcelado em %ldx", self.transaction.installments];
    }
}

- (void)viewDidLayoutSubviews {
    // Centraliza a view com informações da transação na tela utilizando inset da scrollView
    self.scrollView.contentInset = UIEdgeInsetsMake((self.view.frame.size.height / 2) - 110, 0.0, 0.0, 0.0);
}

// MARK: - Actions

- (IBAction)closeButtonTouched {
    self.closeViewControllerBlock();
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    self.closeViewControllerBlock();
}

// MARK: - Subscription details

- (void)addAndConfigureSubscriptionViews {
    [self showLoadingLabel];
    
    [self getSubscriptionDetailsWithCompletionBlock:^(BOOL success, NSDictionary *subscriptionDetails, NSArray *subscriptionTransactions) {
        if (!success) {
            self.loadingLabel.text = @"Erro ao obter os detalhes da assinatura.";
            return;
        }
        
        [self.loadingLabel removeFromSuperview];
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        SubscriptionDetailsView *nextPaymentView;
        SubscriptionDetailsView *lastPaymentsView;
        UIView *bottomView = self.transactionInfoView;
        
        if (subscriptionDetails[@"nextPaymentDate"] != nil) {
            NSDate *date = [dateFormatter dateFromString:subscriptionDetails[@"nextPaymentDate"]];
            NSNumber *amount = [NSNumber numberWithDouble:[(NSNumber *)subscriptionDetails[@"recurringAmount"] doubleValue] / 100];
            
            nextPaymentView = [[SubscriptionDetailsView alloc] initWithValues:@[@{@"date": date, @"amount": amount}]];
            nextPaymentView.title = @"PRÓXIMO LANÇAMENTO";
            nextPaymentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.scrollView addSubview:nextPaymentView];
            [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView]-50-[nextPaymentView]"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{@"bottomView":bottomView,
                                                                                                @"nextPaymentView":nextPaymentView}]];
            [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[nextPaymentView]-20-|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{@"nextPaymentView":nextPaymentView}]];
            bottomView = nextPaymentView;
        }
        
        if (subscriptionTransactions != nil) {
            NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:subscriptionTransactions.count];
            for (Transaction *transaction in subscriptionTransactions) {
                [values addObject:@{@"date": transaction.paidAt, @"amount": [NSNumber numberWithDouble:[transaction.amount doubleValue] / 100]}];
            }
            
            lastPaymentsView = [[SubscriptionDetailsView alloc] initWithValues:values];
            lastPaymentsView.title = @"HISTÓRICO DESTA ASSINATURA";
            lastPaymentsView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.scrollView addSubview:lastPaymentsView];
            [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView]-50-[lastPaymentsView]"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{@"bottomView":bottomView,
                                                                                                @"lastPaymentsView":lastPaymentsView}]];
            [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[lastPaymentsView]-20-|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{@"lastPaymentsView":lastPaymentsView}]];
            bottomView = lastPaymentsView;
        }
        
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView]-10-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"bottomView":bottomView}]];
        
        [NSLayoutConstraint activateConstraints:constraints];
    }];
}

- (void)showLoadingLabel {
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    // Configura a label de carregamento
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingLabel.numberOfLines = 0;
    self.loadingLabel.font = [layoutManager boldFontWithSize:[LayoutManager sharedManager].regularFontSize];
    self.loadingLabel.textColor = [layoutManager darkFontColor];
    self.loadingLabel.text = @"Carregando...";
    
    // Adiciona as constraints da label dentro da scrollView
    [self.scrollView addSubview:self.loadingLabel];
    self.transactionInfoViewBottomConstraint.active = NO;
    
    NSMutableArray *loadingLabelConstraints = [[NSMutableArray alloc] init];
    [loadingLabelConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[transactionInfoView]-50-[loadingLabel]-|"
                                                                                          options:0
                                                                                          metrics:nil
                                                                                            views:@{@"transactionInfoView":self.transactionInfoView,
                                                                                                    @"loadingLabel":self.loadingLabel}]];
    [loadingLabelConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[loadingLabel]-10-|"
                                                                                          options:0
                                                                                          metrics:nil
                                                                                            views:@{@"loadingLabel":self.loadingLabel}]];
    [NSLayoutConstraint activateConstraints:loadingLabelConstraints];
    [self.view setNeedsLayout];
}

- (void)getSubscriptionDetailsWithCompletionBlock:(void(^)(BOOL success, NSDictionary *subscriptionDetails, NSArray *subscriptionTransactions)) completion {
    // Obtém as informações da em outra thread para utilizar sincronização
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL __block getSubscriptionDetailsSucceeded = NO;
        BOOL __block listTransactionsSucceeded = NO;
        NSDictionary __block *subscriptionDetails;
        NSArray __block *subscriptionTransactions;
        
        // Utiliza o semáforo como barreira de sincronizaçãos
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        // Primeiro, baixa os detalhes da assinatura
        Services *subscriptionDetailsService = [[Services alloc] init];
        subscriptionDetailsService.successCase = ^(NSDictionary *response) {
            subscriptionDetails = response;
            getSubscriptionDetailsSucceeded = YES;
            dispatch_semaphore_signal(semaphore);
        };
        subscriptionDetailsService.failureCase = ^(NSString *cod, NSString *msg) {
            getSubscriptionDetailsSucceeded = NO;
            dispatch_semaphore_signal(semaphore);
        };
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [subscriptionDetailsService getSubscriptionDetailsWithSubscriptionID:self.transaction.subscriptionID];
        
        // Após, baixa as últimas 6 transações vinculadas à assinatura
        Services *subscriptionTransactionsService = [[Services alloc] init];
        subscriptionTransactionsService.successCase = ^(NSArray *response) {
            subscriptionTransactions = response;
            listTransactionsSucceeded = YES;
            dispatch_semaphore_signal(semaphore);
        };
        subscriptionTransactionsService.failureCase = ^(NSString *cod, NSString *msg) {
            listTransactionsSucceeded = NO;
            dispatch_semaphore_signal(semaphore);
        };
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [subscriptionTransactionsService listTransactionsWithSubscriptionID:self.transaction.subscriptionID
                                                          startingItemIndex:@0
                                                                  itemCount:@6];
        
        /*
         * Aguarda todas as informações serem baixadas para atualizar a interface.
         * Libera o semáforo para evitar warning.
         */
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(semaphore);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(getSubscriptionDetailsSucceeded && listTransactionsSucceeded, subscriptionDetails, subscriptionTransactions);
        });
    });
}

// MARK: - Layout

- (void)configureLayout {
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.typeLabel.font = [layoutManager fontWithSize:16.0];
    self.typeLabel.textColor = [layoutManager darkerGray];
    
    self.transactionIdLabel.font = [layoutManager fontWithSize:16.0];
    self.transactionIdLabel.textColor = [layoutManager darkerGray];
    
    self.merchantNameLabel.font = [layoutManager boldFontWithSize:20.0];
    self.merchantNameLabel.textColor = [layoutManager lightGray];
    
    self.addressLabel.font = [layoutManager fontWithSize:15.0];
    self.addressLabel.textColor = [layoutManager darkerGray];
    
    self.cityAndStateLabel.font = [layoutManager fontWithSize:15.0];
    self.cityAndStateLabel.textColor = [layoutManager darkerGray];
    
    self.dateLabel.font = [layoutManager fontWithSize:16.0];
    self.dateLabel.textColor = [layoutManager darkerGray];

    self.labelStatusSubscription.font = [layoutManager boldFontWithSize:14.0];
    self.labelStatusSubscription.textColor = [layoutManager lightGray];
    self.labelStatusSubscription.layer.cornerRadius = 4.0f;
    self.labelStatusSubscription.clipsToBounds = YES;
    
    self.statusLabel.font = [layoutManager boldFontWithSize:14.0];
    self.statusLabel.textColor = [layoutManager primaryColor];
    
    self.currencyLabel.font = [layoutManager fontWithSize:20.0];
    self.currencyLabel.textColor = [layoutManager darkerGray];
 
    self.amountLabel.font = [layoutManager fontWithSize:36.0];
    self.amountLabel.textColor = [layoutManager darkerGray];
    
    self.installments.font = [layoutManager fontWithSize:16.0];
    self.installments.textColor = [layoutManager darkerGray];
    
    // Adiciona imagem ao botão de fechar a view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage lib4allImageNamed:@"right-nav-arrow"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.closeButton addSubview:imageView];
  
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-11-[imageView]-13-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"imageView":imageView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-13-[imageView]-13-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"imageView":imageView}]];
}

@end
