//
//  ComponentViewController.m
//  Lib4all
//
//  Created by 4all on 3/29/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ComponentViewController.h"
#import "User.h"
#import "Services.h"
#import "CreditCardsList.h"
#import "CreditCard.h"
#import "LayoutManager.h"
#import "CompleteDataViewController.h"
#import "BaseNavigationController.h"
#import "Lib4allPreferences.h"
#import "SignFlowController.h"
#import "SignInViewController.h"
#import "CardAdditionFlowController.h"
#import <CoreLocation/CoreLocation.h>
#import "PaymentFlowController.h"
#import "LocalizationFlowController.h"
#import "LocationManager.h"
#import "LoginPaymentAction.h"
#import "CardsTableViewController.h"
#import "UIButton+Color.h"
#import "BEMCheckBox.h"
#import "PrePaidServices.h"
#import "UIImageView+WebCache.h"

@interface ComponentViewController () <UIActionSheetDelegate, BEMCheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mainButton;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIButton *changeCardButton;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardBrandImage;
@property (weak, nonatomic) IBOutlet UIView *viewCardChecking;
@property (weak, nonatomic) IBOutlet UILabel *labelCheckingTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelAmountChecking;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkChecking;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkCard;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *prepaidAccountImageView;
@property (weak, nonatomic) IBOutlet UILabel *addCardLabel;
@property CGPoint originalCenterPrepaid;
@property LoginPaymentAction * loginPaymentAction;
@property CAGradientLayer *gradient;

@end

@implementation ComponentViewController

- (id)init {
    
    self = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ComponentVC"];
    
    if (self) {
        self.acceptedPaymentTypes = [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
        self.acceptedBrands = [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects];
    }

    return self;
}

- (id)initWithAcceptedPaymentMode:(PaymentMode)paymentMode {
    self = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ComponentVC"];
    
    if (self) {
        
        NSAssert(paymentMode == PaymentModeDebit || paymentMode == PaymentModeCredit || paymentMode == PaymentModeCreditAndDebit,
                 @"LIB4ALL: initWithAcceptedPaymentMode: deve receber PaymentModeDebit, PaymentModeCredit ou PaymentModeCreditAndDebit");
        
        if (paymentMode == PaymentModeDebit) {
            self.acceptedPaymentTypes = @[@(Debit)];
        } else if (paymentMode == PaymentModeCredit) {
            self.acceptedPaymentTypes = @[@(Credit)];
        } else {
            self.acceptedPaymentTypes = @[@(Credit), @(Debit)];
        }
        
        [[Lib4allPreferences sharedInstance] setAcceptedPaymentTypes:self.acceptedPaymentTypes];
        
        self.acceptedBrands = [[[Lib4allPreferences sharedInstance] acceptedBrands] allObjects];
    }
    
    return self;
}

-(id)initWithAcceptedPaymentTypes:(NSArray *)arrayPaymentTypes andAcceptedBrands:(NSArray *)arrayBrands{
    self = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"ComponentVC"];
    if (self) {
        for (int i = 0; i < [arrayPaymentTypes count]; i++) {
            NSInteger type = [(NSNumber *)[arrayPaymentTypes objectAtIndex:i] integerValue];
            
            NSAssert(type >= 0 && type < NumOfTypes, @"LIB4ALL: initWithAcceptedPaymentTypes deve receber um array de PaymentType.");
        }
        
        for (int i = 0; i < [arrayBrands count]; i++) {
            NSInteger brand = [(NSNumber *)[arrayBrands objectAtIndex:i] integerValue];
            
            NSAssert(brand >= 0 && brand < NumOfBrands, @"LIB4ALL: initWithAcceptedPaymentTypes deve receber um array de CardBrand.");
        }
        
        self.acceptedPaymentTypes = arrayPaymentTypes;
        self.acceptedBrands = arrayBrands;
    }
    return self;
}

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert([Lib4allPreferences sharedInstance].applicationID != nil && [Lib4allPreferences sharedInstance].applicationVersion != nil,
             @"LIB4ALL: Antes de instanciar a classe ComponentViewController, você deve configurar o applicationID e o applicationVersion.");
    
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[Lib4allPreferences sharedInstance] setCurrentVisibleComponent:self];
    if (![_acceptedPaymentTypes containsObject:@(Credit)]) {
        _disabledCreditCardPayment = YES;
    }
    [self updateComponentViews];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mainButton setBackgroundColor:[[LayoutManager sharedManager] mainButtonColor]];
    _gradient = [self.mainButton setGradientFromColor:[[LayoutManager sharedManager] mainButtonColor] toColor:[[LayoutManager sharedManager] mainButtonGradientColor]];
    [self updateComponentViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([[Lib4allPreferences sharedInstance] currentVisibleComponent] == self) {
        [[Lib4allPreferences sharedInstance] setCurrentVisibleComponent:nil];
    }
}

-(void)callOnClick:(BOOL)isCheckingAccount {
    NSString *checkingAccount;
    if(isCheckingAccount) {
        checkingAccount = @"CHECKING_ACCOUNT";
    }else{
        checkingAccount = nil;
    }

    [self.loginPaymentAction callMainAction:self delegate:self.delegate acceptedPaymentTypes:self.acceptedPaymentTypes acceptedBrands:self.acceptedBrands checkingAccount:checkingAccount];

}

// MARK: - Actions

- (IBAction)mainButtonTouched {
    
    self.loginPaymentAction = [[LoginPaymentAction alloc] init];
    NSString *checkingAccount;
    if (_checkChecking.on) {
        checkingAccount = @"CHECKING_ACCOUNT";
    } else {
        
        // Se pressionar o botão de pagar e a card view estiver selecionada enquanto o usuário não há cartões, mostra aviso
        if ([[CreditCardsList sharedList] getDefaultCard] == nil && [[User sharedUser] currentState] == UserStateLoggedIn) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção" message:@"Cadastre um carão ou efetue o pagamento utilizando seu saldo da conta" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        checkingAccount = nil;
        self.loginPaymentAction.isQrCodePayment = self.isQrCodePayment;
    }
    
    [self.loginPaymentAction callMainAction:self delegate:self.delegate acceptedPaymentTypes:self.acceptedPaymentTypes acceptedBrands:self.acceptedBrands checkingAccount:checkingAccount];

}

- (void)showDefaultCard {
    if ([[User sharedUser] currentState] == UserStateLoggedIn) {
        // Obtém o cartão default de maneira assíncrona pois a leitura do arquivo pode demorar
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            CreditCard *defaultCard = [[CreditCardsList sharedList] getDefaultCard];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCheckBox];
            });
            
            if (_disabledCreditCardPayment) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cardView.hidden = YES;
                    self.viewCardChecking.center = _cardView.center;
                    _checkChecking.on = YES;
                    _checkCard.on = NO;
                    _cardTypeLabel.hidden = YES;
                    _cardNumberLabel.hidden = YES;
                    _addCardLabel.hidden = YES;
                    _changeCardButton.hidden = YES;
                });
            } else if (defaultCard != nil) {
                
                NSString *maskedPan = [defaultCard getMaskedPan];
                NSString *cardType = defaultCard.cardDescription;

                if (!defaultCard.isProvider) {
                    cardType = defaultCard.sharedDetails[0][@"identifier"];
                }
                
                // Atualiza os dados do cartão default e exibe a view do cartão
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cardTypeLabel.hidden = NO;
                    _cardNumberLabel.hidden = NO;
                    _addCardLabel.hidden = YES;
                    _changeCardButton.hidden = NO;
                    [self.cardBrandImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", defaultCard.brandLogoUrl]]
                placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
                    self.cardTypeLabel.text = cardType;
                    self.cardNumberLabel.text = maskedPan;
                    self.cardView.hidden = NO;
                    self.viewCardChecking.center = CGPointMake(_cardView.center.x, _originalCenterPrepaid.y);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cardView.hidden = _disabledCreditCardPayment;
                    _checkChecking.on = YES;
                    _checkCard.on = NO;
                    _cardTypeLabel.hidden = YES;
                    _cardNumberLabel.hidden = YES;
                    _addCardLabel.hidden = NO;
                    _changeCardButton.hidden = YES;
                    _cardBrandImage.image = [UIImage lib4allImageNamed:@"addCardIcon"];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_delegate && [_delegate respondsToSelector:@selector(didLoadPaymentType)]){
                    [_delegate didLoadPaymentType];
                }
            });

        });
    } else {
        self.addCardLabel.hidden = YES;
        self.cardView.hidden = YES;
        self.viewCardChecking.hidden = YES;
    }
}

// MARK: - Layout

- (void)configureLayout {
    
    NSArray *cardViews = @[_cardView, _viewCardChecking];
    _originalCenterPrepaid = _viewCardChecking.center;
    for (UIView *card in cardViews) {
        // cardView
        card.layer.cornerRadius        = 4.0f;
        card.layer.borderColor         = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
        card.layer.masksToBounds       = NO;
        card.layer.shadowOffset        = CGSizeMake(0, 1);
        card.layer.shadowRadius        = 2;
        card.layer.shadowColor         = [[LayoutManager sharedManager] darkGray].CGColor;
        card.layer.shadowOpacity       = 0.5;
        card.hidden                    = YES;
    }
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    // changeCardNumber
    [self.changeCardButton.titleLabel setFont:[[LayoutManager sharedManager] fontWithSize:layout.regularFontSize]];
    self.changeCardButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.changeCardButton setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
    
    // Labels
    self.cardNumberLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.regularFontSize];
    self.cardTypeLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    
    self.labelAmountChecking.font = [[LayoutManager sharedManager] fontWithSize:layout.regularFontSize];
    self.labelCheckingTitle.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    
    self.addCardLabel.textColor = layout.primaryColor;
    self.addCardLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.addCardLabel.hidden = YES;
    
    [self.labelCheckingTitle setText: [NSString stringWithFormat: @"Saldo da Carteira %@" , [Lib4allPreferences sharedInstance].balanceTypeFriendlyName]];
    
    // mainButton
    self.mainButton.layer.cornerRadius = 5.0f;
    [self.mainButton.titleLabel setFont:[[LayoutManager sharedManager] fontWithSize:layout.regularFontSize]];
    [self.mainButton setTitleColor:[LayoutManager sharedManager].lightFontColor forState:UIControlStateNormal];
    [self.mainButton setBackgroundColor:[[LayoutManager sharedManager] mainButtonColor]];
    _gradient = [self.mainButton setGradientFromColor:[[LayoutManager sharedManager] mainButtonColor] toColor:[[LayoutManager sharedManager] mainButtonGradientColor]];
     
    self.mainButton.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapOnCardView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    UITapGestureRecognizer *tapOnCheckView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCardTouched)];
    
    [_viewCardChecking addGestureRecognizer:tapOnCheckView];
    [_cardView addGestureRecognizer:tapOnCardView];
    [_addCardLabel setUserInteractionEnabled:YES];
    [_addCardLabel addGestureRecognizer:gestureRecognizer];
    
    self.checkCard.onTintColor = [LayoutManager sharedManager].primaryColor;
    self.checkCard.onCheckColor = [LayoutManager sharedManager].primaryColor;
    self.checkChecking.onTintColor = [LayoutManager sharedManager].primaryColor;
    self.checkChecking.onCheckColor = [LayoutManager sharedManager].primaryColor;

    //Se o app hospedeiro setar a prepaidAccountImage, utilizamos ela
    //caso contrário, continuamos com a da 4all (que está sendo setada por storyboard)
    if ([Lib4allPreferences sharedInstance].prepaidAccountImage != nil) {
        _prepaidAccountImageView.image = [Lib4allPreferences sharedInstance].prepaidAccountImage;
    }
}

- (void)updateComponentViews {
    // Exibe o título do botão de acordo com o estado do usuário
    if ([[User sharedUser] currentState] == UserStateLoggedIn) {
        [self.mainButton setTitle:self.buttonTitleWhenLogged forState:UIControlStateNormal];
        _viewCardChecking.hidden = NO;
        // Atualiza a lista de cartões no servidor e o cartão default exibido
        Services *service = [[Services alloc] init];
        service.failureCase = ^(NSString *code, NSString *message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mainButton.enabled = YES;
                [self.mainButton setTitle:self.buttonTitleWhenLogged forState:UIControlStateNormal];
            });
        };
        
        service.successCase = ^(NSDictionary *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showDefaultCard];
                [self.mainButton setTitle:self.buttonTitleWhenLogged forState:UIControlStateNormal];
                self.mainButton.enabled = YES;
            });
        };
        
        [self.mainButton setTitle:@"Carregando os cartões..." forState:UIControlStateNormal];
        self.mainButton.enabled = NO;
        [service listCards];
        
        PrePaidServices *services = [[PrePaidServices alloc] init];
        
        services.failureCase = ^(NSString *cod, NSString *msg) {
            _labelAmountChecking.text = @"Não foi possível obter saldo";
        };
        
        services.successCase = ^(NSDictionary *response) {
            double balance = [[response objectForKey:@"balance"] doubleValue];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            self.labelAmountChecking.text = [formatter stringFromNumber: [NSNumber numberWithFloat:balance/100]];
            self.labelAmountChecking.text = [self.labelAmountChecking.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
        };
        
        [self updateCheckBox];
        
        _labelAmountChecking.text = @"Buscando saldo...";
        [services balance];
        
    } else {
        [self.mainButton setTitle:self.buttonTitleWhenNotLogged forState:UIControlStateNormal];
    }
    
    if (![self.acceptedPaymentTypes containsObject:@(CheckingAccount)] ||
        ![[Lib4allPreferences sharedInstance].acceptedPaymentTypes containsObject:@(CheckingAccount)]) {
        _viewCardChecking.hidden = YES;
        _containerView.frame = CGRectMake(_containerView.frame.origin.x, _containerView.frame.origin.y, _containerView.frame.size.width, 115);
        _heightContainerView.constant = 115;
    } else {
        _containerView.frame = CGRectMake(_containerView.frame.origin.x, _containerView.frame.origin.y, _containerView.frame.size.width, 165);
        _heightContainerView.constant = 165;
    }
    
    
    // Atualiza o cartão default exibido
    [self showDefaultCard];
}

-(void)didTapCheckBox:(BEMCheckBox *)checkBox{
    
    if (checkBox == _checkCard) {
        _checkChecking.on = NO;
        _checkCard.on = YES;
        [User sharedUser].preferredPaymentMethod = 0;
    }else if (checkBox == _checkChecking){
        _checkCard.on = NO;
        _checkChecking.on = YES;
        [User sharedUser].preferredPaymentMethod = 1;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[User sharedUser].preferredPaymentMethod]
                                              forKey:@"preferredPaymentMethod"];
    if (_delegate && [_delegate respondsToSelector:@selector(didLoadPaymentType)]){
            [_delegate didLoadPaymentType];
        }
}

-(IBAction)tapOnView:(UIGestureRecognizer *)sender{
    if (sender.view == _viewCardChecking) {
        [self didTapCheckBox:_checkChecking];
    }else{
        [self didTapCheckBox:_checkCard];
    }
}

- (void) updateCheckBox {
    NSInteger preferredPaymentMethod = [User sharedUser].preferredPaymentMethod;
    if (preferredPaymentMethod == 0) {
        _checkChecking.on = NO;
        _checkCard.on = YES;
    } else if (preferredPaymentMethod == 1) {
        _checkChecking.on = YES;
        _checkCard.on = NO;
    }
}

-(void) addCardTouched {
    
    NSMutableArray *acceptedPaymentTypes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<self.acceptedPaymentTypes.count; i++) {
        if ([[Lib4allPreferences sharedInstance].acceptedPaymentTypes containsObject:self.acceptedPaymentTypes[i]]) {
            [acceptedPaymentTypes addObject:self.acceptedPaymentTypes[i]];
        }
    }
    
    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:acceptedPaymentTypes andAcceptedBrands:self.acceptedBrands];
    flowController.isFromAddCardMenu = YES;
    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
    [flowController startFlowWithViewController:self];
}

//alteração Bruno Fernandes 3/2/17
//agora passa os tipos de pagamento e bandeiras do componente para o CardsTableViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ((segue.identifier != nil) && ([segue.identifier isEqualToString:@"changePaymentTypeComponentButtonSegue"])) {
        BaseNavigationController * baseNavController = segue.destinationViewController;
        CardsTableViewController * cardTableViewController = [[baseNavController viewControllers] objectAtIndex:0];
        
        NSMutableArray *acceptedPaymentTypes = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<self.acceptedPaymentTypes.count; i++) {
            if ([[Lib4allPreferences sharedInstance].acceptedPaymentTypes containsObject:self.acceptedPaymentTypes[i]]) {
                [acceptedPaymentTypes addObject:self.acceptedPaymentTypes[i]];
            }
        }
        
        cardTableViewController.acceptedPaymentTypes = acceptedPaymentTypes;
        cardTableViewController.acceptedBrands = self.acceptedBrands;
        cardTableViewController.isQrCodePayment = self.isQrCodePayment;
        
    }
}

@end
