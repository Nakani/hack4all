//
//  PaymentDetailsViewController.m
//  Example
//
//  Created by 4all on 12/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PaymentDetailsViewController.h"
#import "ComponentViewController.h"
#import "LayoutManager.h"
#import "Loyalty.h"
#import "MyReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Lib4all.h"
#import "Lib4allPreferences.h"
#import "Services.h"
#import "LoyaltyServices.h"
#import "CreditCardsList.h"
#import "ReceiptViewController.h"
#import "QRCodeMerchantOfflineViewController.h"
#import "UIImage+Color.h"
#import <QuartzCore/QuartzCore.h>
#import "Installment.h"
#import "PopUpBoxViewController.h"
#import "NSString+Decode.h"
#import "AnalyticsUtil.h"

@interface PaymentDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageMerchant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageMerchantWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *labelMerchantName;
@property (weak, nonatomic) IBOutlet UILabel *labelPaymentDate;

@property (weak, nonatomic) IBOutlet UIView *subtotalView;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtotal;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtotalAmount;

@property (weak, nonatomic) IBOutlet UIView *promocodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promocodeConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconTogglePromocode;
@property (weak, nonatomic) IBOutlet UILabel *labelPromocode;
@property (weak, nonatomic) IBOutlet UILabel *labelPromocodeAmount;
@property (weak, nonatomic) IBOutlet UIButton *iconDeletePromocode;
@property (weak, nonatomic) IBOutlet UIButton *validatePromocode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPromocode;
@property (weak, nonatomic) IBOutlet UILabel *labelInvalidPromocode;

@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UILabel *labelPayment;
@property (weak, nonatomic) IBOutlet UILabel *labelPaymentAmount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paymentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *labelInstallmentsAmount;

@property (weak, nonatomic) IBOutlet UILabel *labelSelectPaymentMethod;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) NSString *transactionConfirmation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtotalHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *innerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectPaymentTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *installmentContainerView;
@property (weak, nonatomic) IBOutlet UILabel *installmentLabel;
@property (weak, nonatomic) IBOutlet UITableView *installmentMenuTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *installmentTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *installmentContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;

@property BOOL      promocodeIsOpen;
@property BOOL      installmentMenuIsOpen;
@property BOOL isPaymentToken;
@property Loyalty   *loyaltyInfo;
@property NSString  *discountAmount;
@property NSString  *finalTotalAmount;
@property NSDictionary  *selectedInstallment;
@property NSArray *installmentsForCardBrands;
@property NSArray *installments;
@end

@implementation PaymentDetailsViewController

static NSString* const kNavigationTitle = @"Resumo do pagamento";
static CGFloat const kBottomConstraintMin = 60.0;
static CGFloat const kBottomConstraintMax = 140.0;

static CGFloat const kHeightConstraintMin = 60.0;
static CGFloat const kHeightConstraintMax = 80.0;

ComponentViewController *component;

-(void) viewDidLoad {
    [super viewDidLoad];
    _loyaltyInfo = nil;
    [self configureLayout];
    [_infoImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfoModal)]];
    [_infoImageView setUserInteractionEnabled:YES];
    
    [AnalyticsUtil logEventWithName:@"identificacao_EC_e_valor" andParameters:nil];
}

-(void) viewDidAppear:(BOOL)animated {
    self.navigationItem.title = kNavigationTitle;
    
    [self configurePaymentComponent];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) configureLayout {
    LayoutManager *layoutManager = [LayoutManager sharedManager];

    //Merchant info
    self.labelMerchantName.font = [layoutManager boldFontWithSize:layoutManager.regularFontSize];
    self.labelMerchantName.textColor = layoutManager.darkFontColor;
    self.labelMerchantName.text = [[[self.transactionInfo merchant] name] stringByRemovingPercentEncoding];
    
    self.labelPaymentDate.font = [layoutManager fontWithSize:layoutManager.midFontSize];
    self.labelPaymentDate.textColor = layoutManager.darkFontColor;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [dateFormatter setDateFormat:@"d 'de' MMMM 'de' yyyy"];
    [self.labelPaymentDate setText:[dateFormatter stringFromDate:[NSDate new]]];
    self.imageMerchantWidthConstraint.constant = 0;
    
    //Subtotal
    self.promocodeConstraint.constant = kBottomConstraintMin;
    self.promocodeIsOpen = NO;
    
    self.subtotalView.layer.borderWidth = 1;
    self.subtotalView.layer.borderColor = [[layoutManager lightGray] CGColor];

    self.labelSubtotal.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelSubtotal.textColor = layoutManager.darkFontColor;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.labelSubtotalAmount.font = [layoutManager boldFontWithSize:layoutManager.regularFontSize];
    self.labelSubtotalAmount.textColor = layoutManager.darkFontColor;
    self.labelSubtotalAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([[self.transactionInfo amount] doubleValue]/100.0)]];
    self.labelSubtotalAmount.text = [self.labelSubtotalAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    
    NSMutableAttributedString *att = [self.labelSubtotalAmount.attributedText mutableCopy];
    [att addAttribute:NSFontAttributeName
                value:[layoutManager fontWithSize:layoutManager.regularFontSize]
                range:[self.labelSubtotalAmount.text rangeOfString:@"R$"]];
    self.labelSubtotalAmount.attributedText = att;
    
    //Promocode
    self.labelPromocode.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelPromocode.textColor = layoutManager.darkFontColor;
    self.labelPromocodeAmount.font = [layoutManager boldFontWithSize:layoutManager.regularFontSize];
    self.labelPromocodeAmount.textColor = layoutManager.darkFontColor;
    self.labelInvalidPromocode.font = [layoutManager fontWithSize:layoutManager.midFontSize];
    self.labelInvalidPromocode.textColor = layoutManager.errorColor;
    
    self.labelInvalidPromocode.hidden = YES;
    self.labelPromocodeAmount.hidden = YES;
    self.iconDeletePromocode.hidden = YES;
    
    self.textFieldPromocode.layer.masksToBounds = NO;
    self.textFieldPromocode.layer.shadowRadius = 1.0;
    self.textFieldPromocode.layer.shadowColor = [UIColor blackColor].CGColor;
    self.textFieldPromocode.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.textFieldPromocode.layer.shadowOpacity = 0.2;
    
    self.iconTogglePromocode.image = [self.iconTogglePromocode.image withColor:layoutManager.primaryColor];
    
    //Toggle Promocode
    [self.iconTogglePromocode setUserInteractionEnabled:YES];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePromocode)];
    [self.iconTogglePromocode addGestureRecognizer:gestureRecognizer];
    
    [self.labelPromocode setUserInteractionEnabled:YES];
    UITapGestureRecognizer *gestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePromocode)];
    [self.labelPromocode addGestureRecognizer:gestureRecognizer2];
    

    //Action to dismiss keyboard
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    //Valor a pagar
    self.paymentView.layer.borderWidth = 1;
    self.paymentView.layer.borderColor = [[layoutManager lightGray] CGColor];
    
    self.labelPayment.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelPayment.textColor = layoutManager.darkFontColor;
    
    self.labelPaymentAmount.font = [layoutManager boldFontWithSize:30];
    self.labelPaymentAmount.textColor = layoutManager.primaryColor;
    self.labelPaymentAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([[self.transactionInfo amount] doubleValue]/100.0)]];
    self.labelPaymentAmount.text = [self.labelPaymentAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];

    NSMutableAttributedString *att3 = [self.labelPaymentAmount.attributedText mutableCopy];
    
    [att3 addAttribute:NSFontAttributeName
                value:[layoutManager fontWithSize:layoutManager.regularFontSize]
                range:[self.labelPaymentAmount.text rangeOfString:@"R$"]];
    self.labelPaymentAmount.attributedText = att3;
    
    
    self.labelSelectPaymentMethod.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelSelectPaymentMethod.textColor = layoutManager.darkFontColor;
    
    //Parcelamento gerado pelo lojista
    if([self.transactionInfo.installments intValue] > 1) {
        self.paymentViewHeightConstraint.constant = kHeightConstraintMax;
        
        self.labelInstallmentsAmount.font = [layoutManager fontWithSize:layoutManager.midFontSize];
        self.labelInstallmentsAmount.textColor = layoutManager.darkFontColor;
        self.labelInstallmentsAmount.text = [NSString stringWithFormat:@"Parcelado em %@x", _transactionInfo.installments];
    } else {
        self.labelInstallmentsAmount.hidden = YES;
        self.paymentViewHeightConstraint.constant = kHeightConstraintMin;
    }
    
    
    //Botão voltar
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"left-nav-arrow"]
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(closeButtonTouched)];
    self.navigationItem.leftBarButtonItem = closeButton;

    //Parcelamento Menu Dropdown
    _isPaymentToken = [_transactionInfo.type isEqual: @"PAYMENT_TOKEN"];
    if(_isPaymentToken) {
        _installmentContainerView.hidden = NO;
        _installmentContainerView.layer.borderWidth = 1;
        _installmentContainerView.layer.borderColor = [[layoutManager lightGray] CGColor];
        _installmentLabel.textColor = layoutManager.darkFontColor;
        _installmentLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
        _installmentMenuIsOpen = NO;
        _installmentMenuTableView.layer.cornerRadius = 8.0;
        _installmentMenuTableView.layer.borderWidth = 0.5;
        _installmentMenuTableView.layer.borderColor = [layoutManager.lightGray CGColor];
        _installmentMenuTableView.scrollEnabled = NO;
        _installmentMenuTableView.delegate = self;
        _installmentMenuTableView.dataSource = self;
        [self loadMerchantDataWithAmount:_transactionInfo.amount andTransactionId:[_transactionInfo.transactionID stringByDecodingURLFormat]];
    } else {
        _installmentContainerView.hidden = YES;
        _installmentContainerViewHeightConstraint.constant = 0;
        [self loadMerchantDataWithAmount:nil andTransactionId:_transactionInfo.transactionID];
    }

    if(!self.transactionInfo.acceptsPromoCodes) {
        self.promocodeConstraint.constant = 0;
        self.subtotalHeightConstraint.constant = 0;
        self.subtotalView.hidden = YES;
        self.promocodeView.hidden = YES;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        if(!_isPaymentToken) {
            self.innerViewHeightConstraint.constant = screenHeight - 64;
            self.selectPaymentTopConstraint.active = NO;
        } else {
            self.innerViewHeightConstraint.active = NO;
            [self.innerView removeConstraint:self.innerViewHeightConstraint];
        }
    } else {
        self.innerViewHeightConstraint.active = NO;
        [self.innerView removeConstraint:self.innerViewHeightConstraint];
    }

    NSArray *acceptedPaymentTypes = [_transactionInfo getAcceptedModes];
    
    if(![acceptedPaymentTypes containsObject:@(CheckingAccount)] ||
       ![[Lib4allPreferences sharedInstance].acceptedPaymentTypes containsObject:@(CheckingAccount)]) {
        self.labelSelectPaymentMethod.hidden = YES;
        self.selectPaymentTopConstraint.constant = 0;
    }
    
    if (![acceptedPaymentTypes containsObject:@(Credit)]) {
        _labelSelectPaymentMethod.hidden = YES;
    }
}

- (void) showInfoModal {
    PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
    [modal show:self title:@"Sobre o Pagamento" description:@"O valor da parcela pode sofrer um ajuste mínimo de mês para mês. Isso acontece para que o total da soma das parcelas corresponda ao valor exato da sua compra. \n A variação é de acordo com o emissor do seu cartão de crédito." imageMode:Info buttonAction:nil];
}

- (void) loadMerchantDataWithAmount:(nullable NSNumber *)amount andTransactionId:(NSString *)transactionId {
    MyReachability *networkReachability = [MyReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        
        Services *client = [Services new];
        
        client.successCase = ^(NSDictionary *response) {
            
            if([response valueForKey:@"merchantLogoURL"] != (id)[NSNull null]) {
                self.imageMerchantWidthConstraint.constant = 52;
                self.transactionInfo.merchant.merchantLogo = [response valueForKey:@"merchantLogoURL"];
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.transactionInfo.merchant.merchantLogo]];
                self.imageMerchant.image = [UIImage imageWithData: imageData];
            }
            
            [[LoadingViewController sharedManager] finishLoading:nil];
            
            if(_isPaymentToken) {
                //Tem parcelamento
                NSArray *installmentsBrands = [response valueForKey:@"brands"];
                _installmentsForCardBrands = installmentsBrands;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self realoadInstallments];
                });
            }
        };
        
        client.failureCase = ^(NSString *cod, NSString *msg){
            _installmentContainerView.hidden = YES;
            _installmentContainerViewHeightConstraint.constant = 0;
            [[LoadingViewController sharedManager] finishLoading:nil];
        };
        
        [[LoadingViewController sharedManager] startLoading:self title:@"Aguarde..." completion: ^{
           [client getMerchantData:transactionId andAmount:amount isPaymentToken:_isPaymentToken];
        }];
    }
}

- (void) togglePromocode {
    self.promocodeIsOpen = !self.promocodeIsOpen;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.promocodeIsOpen) {
            self.iconTogglePromocode.transform = CGAffineTransformMakeRotation(180.01 * M_PI/180);
        } else {
            self.iconTogglePromocode.transform = CGAffineTransformMakeRotation(0 * M_PI/180);
        }
        
        self.promocodeConstraint.constant = self.promocodeIsOpen ? kBottomConstraintMax : kBottomConstraintMin;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
}

-(void) setNewAmounts:(NSString *)newAmount withDiscountAmount:(NSString *)discountAmount {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.labelPromocodeAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([discountAmount doubleValue]/100.0)]];
    self.labelPromocodeAmount.text = [self.labelPromocodeAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"-R$ "];
    self.labelPromocodeAmount.hidden = YES;
    
    NSMutableAttributedString *att2 = [self.labelPromocodeAmount.attributedText mutableCopy];
    
    [att2 addAttribute:NSFontAttributeName
                 value:[[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize]
                 range:[self.labelPromocodeAmount.text rangeOfString:@"-R$"]];
    self.labelPromocodeAmount.attributedText = att2;
    
    
    self.labelPaymentAmount.text = [formatter stringFromNumber: [NSNumber numberWithFloat:([newAmount doubleValue]/100.0)]];
    self.labelPaymentAmount.text = [self.labelPaymentAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    
    NSMutableAttributedString *att3 = [self.labelPaymentAmount.attributedText mutableCopy];
    
    [att3 addAttribute:NSFontAttributeName
                 value:[[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize]
                 range:[self.labelPaymentAmount.text rangeOfString:@"R$"]];
    self.labelPaymentAmount.attributedText = att3;
    
    self.discountAmount = discountAmount;
    self.finalTotalAmount = newAmount;

}

- (IBAction)validatePromocodeTouched:(id)sender {
    
    MyReachability *networkReachability = [MyReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:@"Verifique sua conexão e tente novamente."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        
        [alertView show];
        
    } else{
        
        [self removePromocode];
        
        NSNumber *amount = [[NSNumber alloc] init];
        amount = _transactionInfo.amount;
        
        [Lib4all validatePromocode: _textFieldPromocode.text transactionId:_transactionInfo.transactionID merchantId:nil amount:amount completion:^(BOOL valid, NSNumber *newAmount, NSNumber *discountAmount, NSMutableDictionary *loyalty, NSString* message) {
            
            if(valid) {
                self.loyaltyInfo = [[Loyalty alloc] initWithJSONDictionary:loyalty];
                
                
                [self setNewAmounts: [newAmount stringValue]
                 withDiscountAmount:[discountAmount stringValue]];
                
                self.iconDeletePromocode.hidden = NO;
                self.labelInvalidPromocode.hidden = YES;
                self.labelPromocodeAmount.hidden = NO;
                
                [self togglePromocode];

            } else {
                
                self.iconDeletePromocode.hidden = YES;
                self.labelInvalidPromocode.hidden = NO;
                self.labelPromocodeAmount.hidden = YES;
                self.loyaltyInfo = nil;
                
                if([message containsString:@"Código inválido"]) {
                    self.labelInvalidPromocode.text = message;
                    self.labelInvalidPromocode.hidden = NO;
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                                        message:message
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Ok", nil];
                    [alertView show];
                }
                
            }
            
            [[LoadingViewController sharedManager] finishLoading:nil];
            
        }];
        
        [[LoadingViewController sharedManager] startLoading:self title:@"Aguarde..."];
    }
    

}


- (void)removePromocode {
    self.iconDeletePromocode.hidden = YES;
    self.labelInvalidPromocode.hidden = YES;
    self.labelPromocodeAmount.hidden = YES;
    self.loyaltyInfo = nil;
    
    [self setNewAmounts:[NSString stringWithFormat:@"%d", [self.transactionInfo.amount intValue]] withDiscountAmount:@"0"];
}

- (IBAction)deletePromocodeTouched:(id)sender {
    [self removePromocode];
    self.textFieldPromocode.text = @"";
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
}

- (void) closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) configurePaymentComponent{
    
    if (component != nil) {
        [component.view removeFromSuperview];
        [component removeFromParentViewController];
    }
    
    component = [[ComponentViewController alloc] init];
    
    component.acceptedBrands = [_transactionInfo getAcceptedBrands];
    
    component.acceptedPaymentTypes = [_transactionInfo getAcceptedModes];
    
    //Set delegate para callbacks pre e pós venda
    component.delegate = self;
    
    //Define o titulo do botão do componente
    component.buttonTitleWhenNotLogged = @"ENTRAR";
    
    //Define o titulo do botão após estar logado
    component.buttonTitleWhenLogged = @"PAGAR";
    
    component.isQrCodePayment = YES;
    
    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    component.view.frame = self.containerView.bounds;
    
    //Adiciona view do component ao controller
    [self.containerView addSubview:component.view];
    
    //Adiciona a parte funcional ao container
    [self addChildViewController:component];
    [component didMoveToParentViewController:component];
}

- (void) realoadInstallments {
    CreditCard *card = [[CreditCardsList sharedList] getDefaultCard];
    _installments = @[];
    for(int i=0; i<[_installmentsForCardBrands count]; i++) {
        if([_installmentsForCardBrands[i] valueForKey:BrandIDKey] == card.brandId) {
            _installments = [_installmentsForCardBrands[i] valueForKey:DescribedInstallmentsKey];
            _installmentContainerView.hidden = NO;
            _installmentContainerViewHeightConstraint.constant = _installmentTableViewHeightConstraint.constant + 20;
            [_installmentMenuTableView reloadData];
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
            return;
        }
    }
    _installmentContainerView.hidden = YES;
    _installmentContainerViewHeightConstraint.constant = 0;
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
}

//MARK: Callback Delegate

-(void)callbackPreVenda:(NSString *)sessionToken cardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode cvv:(NSString *)cvv {
    
    MyReachability *networkReachability = [MyReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:@"Estabelecimento não aceita pagamento offline."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        if(_transactionInfo.acceptsOfflinePayment) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:@"Pagamento não pode ser efetuado,\ndeseja tentar pagamento offline?"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"NÃO", @"SIM", nil];
        }
        
        [alertView show];
        
        
    } else {
        NSLog(@"There IS internet connection");
        Services *client = [Services new];
        
        if (paymentMode == PaymentModeChecking) {
            [AnalyticsUtil logEventWithName:@"pagar_com_saldo" andParameters:nil];
        } else {
            [AnalyticsUtil logEventWithName:@"pagar_com_cartao" andParameters:nil];
        }
        
        client.successCase = ^(NSDictionary *response) {
            [[LoadingViewController sharedManager] finishLoading:nil];
            
            if ([[response valueForKey:@"status"] integerValue] == 3 || [[response valueForKey:@"status"] integerValue] == 20) {
                if (self.isMerchantOffline) {
                    self.transactionConfirmation = [response valueForKey:@"transactionConfirmation"];
                    [self performSegueWithIdentifier:@"segueMerchantOffline" sender:self];
                }else{
                    [self performSegueWithIdentifier:@"segueReceipt" sender:self];
                }
            } else if (paymentMode == PaymentModeDebit && [[response valueForKey:@"status"] integerValue] == 9) {
                
                    NSURL *url = [[NSURL alloc] initWithString:[response valueForKey:@"debitTransactionURL"]];
                    [[Lib4all sharedInstance] openDebitWebViewInViewController:self withUrl:url completionBlock:^(BOOL success) {
                        
                        if (success) {
                            if (self.isMerchantOffline) {
                                self.transactionConfirmation = [response valueForKey:@"transactionConfirmation"];
                                [self performSegueWithIdentifier:@"segueMerchantOffline" sender:self];
                            }else{
                                [self performSegueWithIdentifier:@"segueReceipt" sender:self];
                            }
                        }
                    }];
            } else {
                NSString *msg = [response valueForKey:@"reasonMessage"];
                if (msg) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                                        message:msg
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Ok", nil];
                    [alertView show];
                }
            }
            
        };
        
        client.failureCase = ^(NSString *cod, NSString *msg) {
            [[LoadingViewController sharedManager] finishLoading:nil];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
        };
        
        [[LoadingViewController sharedManager] startLoading:self title:@"Aguarde..."];
        
        if (self.isMerchantOffline == true) {
            
            [client offlinePayTransaction:sessionToken
                        withTransactionId:_transactionInfo.transactionID
                                andCardId:cardId
                                  payMode:paymentMode
                                   amount:_transactionInfo.amount
                             installments:_transactionInfo.installments
                                cupomUIID:nil
                             campaignUUID:nil
                            merchantKeyId:_transactionInfo.merchant.merchantKeyId
                                     blob:_transactionInfo.blob
                       waitForTransaction:YES];
        }else{
            
            NSMutableDictionary *loyaltyParam = nil;
            if(_loyaltyInfo) {
                loyaltyParam = [[NSMutableDictionary alloc] init];
                [loyaltyParam setValue:@(2) forKey:VersionKey];
                [loyaltyParam setValue:_loyaltyInfo.programId forKey:ProgramIdKey];
                [loyaltyParam setValue:_loyaltyInfo.campaignUUID forKey:CampaignUuidKey];
                [loyaltyParam setValue:_loyaltyInfo.couponUUID forKey:CouponUuidKey];
                [loyaltyParam setValue:_loyaltyInfo.code forKey:CodeKey];
            }
            
            NSNumber *installments = _transactionInfo.installments;
            NSString *transactionID = _transactionInfo.transactionID;
            
            if(_isPaymentToken){
                transactionID = [transactionID stringByDecodingURLFormat];
                if (_selectedInstallment) {
                   installments = _selectedInstallment[NumberOfInstallmentsKey];
                }
           }
            
            [client payTransaction:sessionToken withTransactionId:transactionID andCardId:cardId payMode:paymentMode amount:_transactionInfo.amount installments:installments waitForTransaction:YES loyalty:loyaltyParam isPaymentToken:_isPaymentToken];
        }
    }
}

- (void) didLoadPaymentType {
    [self realoadInstallments];
}

//MARK: alertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [[Lib4all sharedInstance] generateAndShowOfflineQrCode:self ec:self.transactionInfo.merchant.name transactionId:self.transactionInfo.transactionID amount:[self.transactionInfo.amount intValue]];
    }
}

//MARK: TableView DropdownMenu

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"installmentCellIdentifier"];
    UIImageView *indicator = (UIImageView *) [cell viewWithTag:2];
    UILabel *title = (UILabel *) [cell viewWithTag:1];
    
    title.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    title.textColor = [LayoutManager sharedManager].darkFontColor;
    indicator.hidden = YES;
    title.text = @"à vista";
    
    if([_installments count] == 0) {
        return cell;
    }
    
    if(_selectedInstallment == nil) {
        _selectedInstallment = _installments[0];
    }
    
    NSDictionary *installment = _installments[indexPath.row];
    
    if(indexPath.row == 0) {
        indicator.hidden = NO;
        indicator.image = [[[UIImage imageNamed:@"iconDownArrow" inBundle:[NSBundle getLibBundle] compatibleWithTraitCollection:nil] withColor:[LayoutManager sharedManager].darkFontColor] withColor:[LayoutManager sharedManager].primaryColor];
        if(_installmentMenuIsOpen) {
            indicator.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            installment = _selectedInstallment;
        }
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    if([installment[NumberOfInstallmentsKey] longValue] > 1) {
        title.text = [[NSString stringWithFormat:@"%ldx de R$ %.02f", [installment[NumberOfInstallmentsKey] longValue], [installment[InstallmentAmountKey] floatValue]/100] stringByReplacingOccurrencesOfString:@"." withString:@","];
    }
    if(_installmentMenuIsOpen && installment == _selectedInstallment) {
        [_installmentMenuTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_installmentMenuIsOpen) {
        return [_installments count];
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_installmentMenuIsOpen) {
        _selectedInstallment = _installments[indexPath.row];
    }
    _installmentMenuIsOpen = !_installmentMenuIsOpen;
    [_installmentMenuTableView deselectRowAtIndexPath:indexPath animated:YES];
    [_installmentMenuTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
    [UIView animateWithDuration:0.3 animations:^{
        _installmentTableViewHeightConstraint.constant = _installmentMenuTableView.contentSize.height;
        _installmentContainerViewHeightConstraint.constant = _installmentTableViewHeightConstraint.constant + 20;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

//mark: Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueReceipt"]) {
        ReceiptViewController *destVc = (ReceiptViewController *) segue.destinationViewController;
        destVc.didFinishPayment = _didFinishPayment;
        destVc.transactionInfo = _transactionInfo;
        destVc.loyaltyInfo = _loyaltyInfo;
        destVc.discountAmount = _discountAmount;
        destVc.finalTotalAmount = _finalTotalAmount;
        destVc.isPaymentToken = _isPaymentToken;
        if(_isPaymentToken) {
            destVc.paymentTokenInstallmentParcel = [_selectedInstallment[NumberOfInstallmentsKey] stringValue];
            destVc.paymentTokenInstallmentValue = [_selectedInstallment[InstallmentAmountKey] floatValue]/100;
        }
    }else if([segue.identifier isEqualToString:@"segueMerchantOffline"]){
        QRCodeMerchantOfflineViewController *destVc = (QRCodeMerchantOfflineViewController *) segue.destinationViewController;
        destVc.contentQRCode = self.transactionConfirmation;
    }
}


@end
