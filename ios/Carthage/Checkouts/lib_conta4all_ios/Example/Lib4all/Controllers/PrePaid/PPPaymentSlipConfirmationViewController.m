//
//  PPPaymentSlipConfirmationViewController.m
//  Example
//
//  Created by Adriano Soares on 27/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPPaymentSlipConfirmationViewController.h"
#import "PPPaymentSlipSuccessViewController.h"
#import "ServicesConstants.h"
#import "PrePaidServices.h"
#import "CurrencyUtil.h"
#import "DateUtil.h"
#import "UIView+Gradient.h"
#import "LayoutManager.h"

@interface PPPaymentSlipConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *paymentSlipLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentSlipAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *feeLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;

@end

@implementation PPPaymentSlipConfirmationViewController

static NSString* const kNavigationTitle = @"Adicionar dinheiro";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paymentSlipAmountLabel.text = [CurrencyUtil currencyFormatter:self.total];
    self.creditAmountLabel.text      = [CurrencyUtil currencyFormatter:self.total-self.fee];
    self.feeAmountLabel.text = [CurrencyUtil currencyFormatter:self.fee];
    
    self.feeAmountLabel.text = [self.feeAmountLabel.text stringByAppendingString:@" (será descontada do valor do boleto)"];
    
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = _dueDays ;
    
    NSCalendar *calendar         = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date                 = [calendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSDateFormatter *dateFormat  = [[NSDateFormatter alloc] init];
    dateFormat.calendar          = calendar;
    dateFormat.dateFormat        = @"dd/MM/yyyy";
    dateFormat.locale            = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    self.expirationDateLabel.text= [dateFormat stringFromDate:date];
    
    
    
    [self configureLayout];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    self.navigationItem.title = @"";
}

- (IBAction)confirmTouched:(id)sender {
    
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [loading finishLoading:^{
            PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
            [modal show:self
                  title:@"Atenção"
            description:msg
              imageMode:Error
           buttonAction:nil];
        }];
    };
    
    services.successCase = ^(NSDictionary *response) {
        NSLog(@"%@", response);
        [loading finishLoading:^{
            PPPaymentSlipSuccessViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPPaymentSlipSuccessViewController"];
            destination.amount = self.total;
            
            NSDictionary *paymentCashIn = [response objectForKey:@"paymentCashIn"];
            NSDictionary *payment = [paymentCashIn objectForKey:@"payment"];
            destination.paymentId = [payment objectForKey:@"paymentId"];
            NSDictionary *paymentSlip = [payment objectForKey:@"paymentSlipData"];
            
            //Adicionado esse if por causa de um erro recorrente
            //em que "do nada" o backend envia o paymentSlipData dentro de uma String
            if([paymentSlip isKindOfClass:NSString.class]) {
                NSData *jsonData = [[payment objectForKey:@"paymentSlipData"] dataUsingEncoding:NSUTF8StringEncoding];
                paymentSlip = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
            }
            destination.expirationDate =  [DateUtil convertDateString:[paymentSlip objectForKey:@"due_date"] fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
            destination.barCode = [paymentSlip objectForKey:@"typeable_line"];
            
            [self.navigationController pushViewController:destination animated:YES];
        }];
    };
    
    [loading startLoading:self title:@"Aguarde ..."];
    
    [services createPaymentCashIn:self.total payMode:TransactionPayModePaymentSlip receiverCpf:nil receiverPhoneNumber:nil description:nil cardId:nil password:nil];
    

}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    
    self.titleLabel.font = [layout fontWithSize:layout.titleFontSize];
    self.titleLabel.textColor = layout.lightFontColor;

    
    NSArray *boldLabels = @[_paymentSlipAmountLabel, _creditAmountLabel, _feeAmountLabel, _expirationDateLabel];
    
    for (int i = 0; i < boldLabels.count; i++) {
        UILabel *label = boldLabels[i];
        
        label.font = [layout boldFontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
        
    }

    NSArray *regularLabels = @[_paymentSlipLabel, _creditLabel, _feeLabel, _expirationLabel];
    
    for (int i = 0; i < regularLabels.count; i++) {
        UILabel *label = regularLabels[i];
        
        label.font = [layout fontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }

    
    NSMutableAttributedString *att = [self.feeAmountLabel.attributedText mutableCopy];
    
    [att addAttribute:NSFontAttributeName
                value:[layout fontWithSize:layout.regularFontSize]
                range:[self.feeAmountLabel.text rangeOfString:@"(será descontada do valor do boleto)"]];
    
    
    self.feeAmountLabel.attributedText = att;
    
}

@end
