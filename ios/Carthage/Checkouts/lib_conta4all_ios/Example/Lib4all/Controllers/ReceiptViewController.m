//
//  ReceiptViewController.m
//  Example
//
//  Created by 4all on 30/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "ReceiptViewController.h"
#import "Loyalty.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"

@interface ReceiptViewController ()
@property (weak, nonatomic) IBOutlet UILabel *receiptTitle;
@property (weak, nonatomic) IBOutlet UILabel *receiptSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *iconCheck;

@property (weak, nonatomic) IBOutlet UIImageView *merchantIcon;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UILabel *transactionDate;

@property (weak, nonatomic) IBOutlet UIView *subtotalView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtotalViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalAmount;

@property (weak, nonatomic) IBOutlet UIView *promocodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promocodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *promocodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *promocodeAmount;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *installmentsAmount;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *merchantIconWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *paymentTokenInstallmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentTokenInstallmentAmount;
@property (weak, nonatomic) IBOutlet UIView *paymentTokenInstallmentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paymentTokenInstallmentViewHeightConstraint;

@end

@implementation ReceiptViewController

static CGFloat const kHeightConstraintMin = 60.0;
static CGFloat const kHeightConstraintMax = 80.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self.navigationController.navigationBar setTintColor:[LayoutManager sharedManager].lightFontColor];

    
    [self configureLayout];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initGifAnimation];
}

- (void)initGifAnimation {
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for(int i=1; i <= 46; i++) {
        NSString *finalName = [NSString stringWithFormat:@"%@%d", @"wink-", i];
        UIImage *imageFromMyLibraryBundle = [UIImage imageWithContentsOfFile:[[[NSBundle getLibBundle] resourcePath] stringByAppendingPathComponent:finalName]];
        imageFromMyLibraryBundle = [imageFromMyLibraryBundle withColor:[LayoutManager sharedManager].primaryColor];
        [imageArray addObject:imageFromMyLibraryBundle];
    }
    
    UIImage *lastImage = [UIImage lib4allImageNamed:@"wink-46"];
    self.iconCheck.image = [lastImage withColor:[LayoutManager sharedManager].primaryColor];
    self.iconCheck.animationImages = imageArray;
    self.iconCheck.animationDuration = 1.3f;
    self.iconCheck.animationRepeatCount = 1;
    [self.iconCheck startAnimating];
}

- (IBAction)closeReceipt:(id)sender {
    if (_didFinishPayment) {
        _didFinishPayment();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) configureLayout{
    
    LayoutManager *layout = [LayoutManager sharedManager];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.receiptTitle.font = [layout boldFontWithSize:layout.titleFontSize];
    self.receiptTitle.textColor = layout.receiptColor;
    
    self.receiptSubTitle.font = [layout fontWithSize:layout.regularFontSize];
    self.receiptSubTitle.textColor = layout.darkFontColor;
    
//    self.iconCheck.image = [self.iconCheck.image withColor:layout.primaryColor];
    
    
    self.merchantName.font = [layout boldFontWithSize:layout.regularFontSize];
    self.merchantName.textColor = layout.darkFontColor;
    self.merchantName.text = [[[self.transactionInfo merchant] name] stringByRemovingPercentEncoding];
    
    if(self.transactionInfo.merchant.merchantLogo != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.transactionInfo.merchant.merchantLogo]];
            self.merchantIcon.image = [UIImage imageWithData: imageData];
        });

    } else {
        self.merchantIconWidthConstraint.constant = 0;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *brLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    [dateFormatter setLocale:brLocale];
    [dateFormatter setDateFormat:@"d 'de' MMMM 'de' yyyy"];

    self.transactionDate.font = [layout fontWithSize:layout.midFontSize];
    self.transactionDate.textColor = layout.darkFontColor;
    [self.transactionDate setText:[dateFormatter stringFromDate:[NSDate new]]];
    
    
    self.subtotalLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.subtotalLabel.textColor = layout.darkFontColor;
    self.subtotalAmount.font = [layout boldFontWithSize:layout.regularFontSize];
    self.subtotalAmount.textColor = layout.darkFontColor;
    self.subtotalAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([[self.transactionInfo amount] doubleValue]/100.0)]];
    self.subtotalAmount.text = [self.subtotalAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    
    NSMutableAttributedString *att = [self.subtotalAmount.attributedText mutableCopy];
    [att addAttribute:NSFontAttributeName
                value:[layout fontWithSize:layout.regularFontSize]
                range:[self.subtotalAmount.text rangeOfString:@"R$"]];
    self.subtotalAmount.attributedText = att;
    
    self.totalLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.totalLabel.textColor = layout.darkFontColor;
    self.totalAmount.font = [layout boldFontWithSize:30];
    self.totalAmount.textColor = layout.receiptColor;

    NSNumber *newAmount = [self.transactionInfo amount];
    
    //Se tiver promocode
    if(self.loyaltyInfo) {
        self.promocodeLabel.font = [layout fontWithSize:layout.regularFontSize];
        self.promocodeLabel.textColor = layout.darkFontColor;
        self.promocodeLabel.text = [NSString stringWithFormat:@"Cupom %@", _loyaltyInfo.code];

        self.promocodeAmount.font = [layout boldFontWithSize:layout.regularFontSize];
        self.promocodeAmount.textColor = layout.darkFontColor;
        self.promocodeAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([self.discountAmount doubleValue]/100.0)]];
        self.promocodeAmount.text = [self.promocodeAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"-R$ "];
        
        NSMutableAttributedString *att2 = [self.promocodeAmount.attributedText mutableCopy];
        [att2 addAttribute:NSFontAttributeName
                     value:[layout fontWithSize:layout.regularFontSize]
                     range:[self.promocodeAmount.text rangeOfString:@"-R$"]];
        self.promocodeAmount.attributedText = att2;
        
        newAmount = [NSNumber numberWithInt:[self.finalTotalAmount intValue]];
        
        self.totalAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([newAmount doubleValue]/100.0)]];
        self.totalAmount.text = [self.totalAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
        
        
    } else {
        self.totalAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([self.transactionInfo.amount doubleValue]/100.0)]];
        self.totalAmount.text = [self.totalAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
        
        self.subtotalViewHeightConstraint.constant = 0;
        self.subtotalView.hidden = YES;
        
        self.promocodeViewHeightConstraint.constant = 0;
        self.promocodeView.hidden = YES;
    }
    
    NSMutableAttributedString *att3 = [self.totalAmount.attributedText mutableCopy];
    [att3 addAttribute:NSFontAttributeName
                 value:[layout fontWithSize:layout.regularFontSize]
                 range:[self.totalAmount.text rangeOfString:@"R$"]];
    self.totalAmount.attributedText = att3;
    
    
    
    //Se tiver parcelamento gerado pelo lojista
    if([self.transactionInfo.installments integerValue] > 1) {
        self.totalViewHeightConstraint.constant = kHeightConstraintMax;
        
        self.installmentsAmount.font = [layout fontWithSize:layout.midFontSize];
        self.installmentsAmount.textColor = layout.darkFontColor;
        self.installmentsAmount.text = [NSString stringWithFormat:@"Parcelado em %@x", self.transactionInfo.installments];
        
    } else {
        self.installmentsAmount.hidden = YES;
        self.totalViewHeightConstraint.constant = kHeightConstraintMin;
    }
    
    //Se for parcelamento selecionado pelo usuário
    if(_isPaymentToken) {
        _paymentTokenInstallmentLabel.font = [layout fontWithSize:layout.regularFontSize];
        _paymentTokenInstallmentLabel.textColor = layout.darkFontColor;
        _paymentTokenInstallmentAmount.font = [layout boldFontWithSize:layout.regularFontSize];
        _paymentTokenInstallmentAmount.textColor = [layout primaryColor];
        _paymentTokenInstallmentAmount.text = [[NSString stringWithFormat:@"%@x de R$ %0.2f", _paymentTokenInstallmentParcel, _paymentTokenInstallmentValue] stringByReplacingOccurrencesOfString:@"." withString:@","];
    } else {
        [_paymentTokenInstallmentView setHidden:YES];
        _paymentTokenInstallmentViewHeightConstraint.constant = 0;
    }
    
    if(self.transactionInfo.isCancellation) {
        self.receiptSubTitle.text = @"Transação cancelada com sucesso.";
    }
}

@end
