//
//  PPBalanceViewController.m
//  Example
//
//  Created by Adriano Soares on 09/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPBalanceViewController.h"
#import "PPTransactionsTableViewController.h"
#import "PrePaidServices.h"
#import "MDTabBarViewController.h"
#import "UIView+Gradient.h"
#import "LayoutManager.h"
#import "MDButton.h"
#import "UIView+MDExtension.h"
#import "PPTransferContactConfirmationViewController.h"
#import "PPPaymentSlipsViewController.h"
#import "UIImage+Color.h"
#import "Lib4allPreferences.h"
#import "AnalyticsUtil.h"

@interface PPBalanceViewController () <MDTabBarViewControllerDelegate, UIGestureRecognizerDelegate, MDButtonDelegate>
@property NSArray *viewArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMarginRight;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonCloseReceipt;
@property (weak, nonatomic) IBOutlet UIView *viewShadow;
@property (weak, nonatomic) IBOutlet UIView *viewWhiteShadow;
@property(nonatomic) CGPoint startPoint;
@property (weak, nonatomic) IBOutlet MDButton *buttonFloatAction;
@property (weak, nonatomic) IBOutlet MDButton *buttonToken;
@property (weak, nonatomic) IBOutlet MDButton *buttonWithdraw;
@property (weak, nonatomic) IBOutlet MDButton *buttonDeposit;
@property (weak, nonatomic) IBOutlet MDButton *buttonTransfer;
@property (weak, nonatomic) IBOutlet UIButton *labelToken;
@property (weak, nonatomic) IBOutlet UIButton *labelWithdraw;
@property (weak, nonatomic) IBOutlet UIButton *labelDeposit;
@property (weak, nonatomic) IBOutlet UIButton *labelTransfer;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *avaliableLabel;
@property (weak, nonatomic) IBOutlet UIButton *showBalanceButton;
@property (weak, nonatomic) IBOutlet UIButton *showSummaryButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *balanceLabelTopConstraint;

@property (strong, nonatomic) UITapGestureRecognizer *tryAgainGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *toggleBalanceGestureRecognizer;

@property double balance;
@property double paymentSlipFee;
@property double paymentDueDays;
@property NSArray *cardCashInFees;

@end

@implementation PPBalanceViewController {
    MDTabBarViewController *tabBarViewController;
}

static CGFloat   const kConstraintMax = 139;
static CGFloat   const kConstraintMin = 60;
static BOOL isBalanceVisible;

- (void)viewDidLoad {
    [super viewDidLoad];

    void (^didScroll)(UIScrollView *scrollView) = ^(UIScrollView *scrollView) {
        if (scrollView.contentOffset.y >= 0) {
            self.headerHeightConstraint.constant = MAX(kConstraintMax - scrollView.contentOffset.y, kConstraintMin);
            [self.view updateConstraintsIfNeeded];
        }
    };
    
    PPTransactionsTableViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTransactionsTableViewController"];
    vc1.transactionFilter = PPTransactionFilterAll;
    vc1.rootViewController = self;
    vc1.didScroll = didScroll;
    [vc1 loadData];
    
    PPTransactionsTableViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTransactionsTableViewController"];
    vc2.transactionFilter = PPTransactionFilterIn;
    vc2.rootViewController = self;
    vc2.didScroll = didScroll;
    [vc2 loadData];
    
    PPTransactionsTableViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTransactionsTableViewController"];
    vc3.transactionFilter = PPTransactionFilterOut;
    vc3.rootViewController = self;
    vc3.didScroll = didScroll;
    [vc3 loadData];
    
    self.viewArray = @[vc1, vc2, vc3];

    tabBarViewController = [[MDTabBarViewController alloc] initWithDelegate:self];
    NSArray *names = @[
                       @"TUDO",
                       @"ENTRADA",
                       @"SAÍDA"
                      ];
    [tabBarViewController setItems:names];

    [self addChildViewController:tabBarViewController];
    UIView *containerView = [self.view viewWithTag:99];
    [containerView addSubview:tabBarViewController.view];
    [tabBarViewController didMoveToParentViewController:self];

    UIView *controllerView = tabBarViewController.view;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(controllerView);

    [self.view addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|["
                     @"controllerView]|"
                     options:0
                     metrics:nil
                     views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"H:|[controllerView]|"
                     options:0
                     metrics:nil
                     views:viewsDictionary]];

    [self configureLayout];
    
    UITapGestureRecognizer *tapOnShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadow:)];
    
    [_viewShadow addGestureRecognizer:tapOnShadow];
    
    UITapGestureRecognizer *tapOnWhiteShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadow:)];
    
    
    [_viewWhiteShadow addGestureRecognizer:tapOnWhiteShadow];


    id showBalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"showBalance"];
    if (showBalance == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showBalance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    isBalanceVisible = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBalance"];
    
    self.tryAgainGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getBalance)];
    self.toggleBalanceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBalance:)];
    
    [self.showSummaryButton setHidden:[Lib4allPreferences sharedInstance].hideSummaryButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureActionButtonCoordinates];
    [self configureNavigationBar];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getBalance];
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Se estiver voltando a partir do back button
        [AnalyticsUtil logEventWithName:@"voltando_de_extrato" andParameters:nil];
    }
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    [self tapShadow:_viewWhiteShadow];
}

-(void) configureNavigationBar {
    self.navigationItem.title = @"Extrato";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    if(self.navigationController.viewControllers[0] == self) {
        UIImage *closeButtonImage = [UIImage lib4allImageNamed:@"x"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[closeButtonImage withColor:[LayoutManager sharedManager].lightFontColor]  style:UIBarButtonItemStylePlain target:self action:@selector(didPressCloseButton)];
    }
    
    if ([UIScreen mainScreen].nativeBounds.size.height >= 2436) {
        //Iphone X
        _balanceLabelTopConstraint.constant = 80;
    }
    
}

- (UIViewController *)tabBarViewController: (MDTabBarViewController *)viewController viewControllerAtIndex:(NSUInteger)index {
    switch (((PPTransactionsTableViewController *) _viewArray[index]).transactionFilter) {
        case PPTransactionFilterIn:
            [AnalyticsUtil logEventWithName:@"visualizar_entradas" andParameters:nil];
            break;
        case PPTransactionFilterOut:
            [AnalyticsUtil logEventWithName:@"visualizar_saidas" andParameters:nil];
            break;
        default:
            break;
    }
    return _viewArray[index];
}

- (void)tabBarViewController:(MDTabBarViewController *)viewController didMoveToIndex:(NSUInteger)index {
}


- (void) getBalance {

    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    [self.balanceLabel removeGestureRecognizer:_tryAgainGestureRecognizer];
    [self.balanceLabel removeGestureRecognizer:_toggleBalanceGestureRecognizer];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator setHidden:YES];
            self.balanceLabel.text = @"Tentar novamente";
            [self.balanceLabel setHidden:NO];
            
            [self.balanceLabel addGestureRecognizer:_tryAgainGestureRecognizer];
        });

    };
    
    services.successCase = ^(NSDictionary *response) {
        self.balance = [[response objectForKey:@"balance"] doubleValue];
        if ([response objectForKey:@"paymentSlipPaymentCashInFee"] != [NSNull null]) {
            self.paymentSlipFee = [[response objectForKey:@"paymentSlipPaymentCashInFee"] doubleValue];
        }
        self.paymentDueDays = [[response objectForKey:@"paymentSlipPaymentCashInDueDateDays"] doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator setHidden:YES];
            [self.balanceLabel setHidden:NO];
            [self.avaliableLabel setHidden:NO];
            [self.showBalanceButton setHidden:NO];
            
            [self renderBalance];
            
            [self.balanceLabel addGestureRecognizer:_toggleBalanceGestureRecognizer];
        });
        if([response objectForKey:@"cardCashInFees"] != [NSNull null]) {
            self.cardCashInFees = [response objectForKey:@"cardCashInFees"];
        }

    };
    
    [self.activityIndicator setHidden:NO];
    [self.balanceLabel setHidden:YES];
    [self.avaliableLabel setHidden:YES];
    [self.showBalanceButton setHidden:YES];
    
    LayoutManager *layout = [LayoutManager sharedManager];
    self.balanceLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    [services balance];
}

//MARK: Methods

-(void)showReceiptOfType:(ReceiptType)type withData:(NSDictionary *)receiptData{
    UIView *contentView = [[DetailsManager sharedManager] getConfiguredViewByType:type withDataToFill:receiptData withCardCashInFees: self.cardCashInFees];

    // Esta view é nil somente quando dá erro no backend!
    if(contentView == nil) {
        [[[PopUpBoxViewController alloc] init] show:self
                                              title:@"Atenção"
                                        description:@"Não foi possível obter detelhes da transação."
                                          imageMode:Error
                                       buttonAction:nil];
        return;
    }
    
    contentView.frame = _containerView.bounds;
    contentView.tag   = 99;
    
    UIView *previousView = [self.containerView viewWithTag:99];
    [previousView removeFromSuperview];
    
    [self.containerView addSubview:contentView];
    [self.containerView sendSubviewToBack:contentView];
    self.navigationController.navigationBar.layer.zPosition = -1;

    [UIView animateWithDuration:0.5 animations:^{
        _constraintMarginRight.constant = 0;
        _viewShadow.hidden = NO;
        _viewShadow.alpha = 1;
        [self.view layoutIfNeeded];
    }];
}

- (void) renderBalance {
    LayoutManager *layout = [LayoutManager sharedManager];
    self.balanceLabel.font = [layout boldFontWithSize:layout.titleFontSize];
    
    if (isBalanceVisible) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.balanceLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:self.balance/100]];
        self.balanceLabel.text = [self.balanceLabel.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    
        
        NSMutableAttributedString *attributtedString = [self.balanceLabel.attributedText mutableCopy];
        
        [attributtedString addAttribute:NSFontAttributeName
                                  value:[layout fontWithSize:layout.regularFontSize]
                                  range:[self.balanceLabel.text rangeOfString:@"R$"]];
        
        self.balanceLabel.attributedText = attributtedString;
        [self.avaliableLabel setHidden: NO];
        UIImage *image = [UIImage lib4allImageNamed:@"saldo_visivel"];
        image = [image withColor:layout.balanceIconColor];
        [self.showBalanceButton setImage:image forState:UIControlStateNormal];
        
    } else {
        self.balanceLabel.text = @"Saldo";
        [self.avaliableLabel setHidden: YES];
        UIImage *image = [UIImage lib4allImageNamed:@"saldo_invisivel"];
        image = [image withColor:layout.lightFontColor];
        [self.showBalanceButton setImage:image forState:UIControlStateNormal];
    }
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];

    self.avaliableLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.balanceLabel.textColor = layout.lightFontColor;
    self.avaliableLabel.textColor = layout.lightFontColor;
    UIImage *image = [UIImage lib4allImageNamed:@"resumo"];
    image = [image withColor:layout.lightFontColor];
    [self.showSummaryButton setImage:image forState:UIControlStateNormal];

    tabBarViewController.tabBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tabBarViewController.tabBar.rippleColor     = [UIColor groupTableViewBackgroundColor];
    tabBarViewController.tabBar.indicatorColor  = layout.balanceIconColor;
    tabBarViewController.tabBar.normalTextColor = layout.mediumGray;
    tabBarViewController.tabBar.normalTextFont  = [layout fontWithSize:layout.regularFontSize];
    tabBarViewController.tabBar.textColor       = [UIColor blackColor];
    tabBarViewController.tabBar.textFont        = [layout fontWithSize:layout.regularFontSize];

    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    _buttonCloseReceipt.layer.cornerRadius = _buttonCloseReceipt.frame.size.height/2;
    _buttonCloseReceipt.clipsToBounds = YES;
    
    //Shadow receipt view
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_containerView.bounds];
    _containerView.layer.masksToBounds = NO;
    _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _containerView.layer.shadowOffset = CGSizeMake(-5.0f, 0.0f);
    _containerView.layer.shadowOpacity = 0.5f;
    _containerView.layer.shadowPath = shadowPath.CGPath;
    
    //Shadow close button receipt
    UIBezierPath *shadowPathButton = [UIBezierPath bezierPathWithRoundedRect:_buttonCloseReceipt.bounds cornerRadius:_buttonCloseReceipt.layer.cornerRadius];
    _buttonCloseReceipt.layer.masksToBounds = NO;
    _buttonCloseReceipt.layer.shadowColor = [UIColor blackColor].CGColor;
    _buttonCloseReceipt.layer.shadowOffset = CGSizeMake(-6.0f, 0.0f);
    _buttonCloseReceipt.layer.shadowOpacity = 0.5f;
    _buttonCloseReceipt.layer.shadowPath = shadowPathButton.CGPath;
    _buttonCloseReceipt.imageView.image  = [UIImage lib4allImageNamed:@"right-nav-arrow"];
    
    //ActionButton
    _buttonFloatAction.hidden = ![Lib4allPreferences sharedInstance].isBalanceFloatingButtonEnabled;
    self.buttonFloatAction.mdButtonDelegate = self;
    NSArray *buttonsFab = @[_buttonToken, _buttonWithdraw, _buttonDeposit, _buttonTransfer, _labelTransfer, _labelDeposit, _labelWithdraw, _labelToken];
    _startPoint = CGPointMake(0, 0);
    _startPoint = CGPointMake(self.buttonFloatAction.center.x, self.buttonFloatAction.center.y - 5);
    _buttonFloatAction.backgroundColor = [LayoutManager sharedManager].primaryColor;
    for (UIView *view in buttonsFab) {
        view.alpha = 0.f;
        view.center = _startPoint;
        if ([view isKindOfClass:[MDButton class]]) {
            view.backgroundColor = [LayoutManager sharedManager].primaryColor;
        }
    }
}

- (void)configureActionButtonCoordinates {
    //Configuring Label
    _labelToken.center = CGPointMake(self.buttonFloatAction.center.x - 48, self.buttonToken.center.y);
    _labelWithdraw.center = CGPointMake(self.buttonFloatAction.center.x - 48, self.buttonWithdraw.center.y);
    _labelDeposit.center = CGPointMake(self.buttonFloatAction.center.x - 48, self.buttonDeposit.center.y);
    _labelTransfer.center = CGPointMake(self.buttonFloatAction.center.x - 48, self.buttonTransfer.center.y);
}

-(void)viewDidLayoutSubviews{
    NSArray *buttonsFab = @[_buttonToken, _buttonWithdraw, _buttonDeposit, _buttonTransfer];
    
    _startPoint = CGPointMake(self.buttonFloatAction.center.x, self.buttonFloatAction.center.y - 5);
    for (UIButton *button in buttonsFab) {
        button.center = _startPoint;
    }
}


- (IBAction)btnClicked:(id)sender {
    if (sender == self.buttonFloatAction) {
        self.buttonFloatAction.rotated = false;//reset floating finging button
    }
    
}

-(void)rotationStarted:(id)sender {
    if (self.buttonFloatAction == sender){
        int padding = 60;
        CGFloat duration = 0.2f;
        if (!self.buttonFloatAction.rotated) {
            //mostra itens
            
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options: (UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
                             animations:^{
                                 _viewWhiteShadow.alpha = 0.8;
                                 self.buttonToken.alpha = 1;
                                 self.buttonToken.transform = CGAffineTransformMakeScale(1.0,.4);
                                 self.buttonToken.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -padding*4), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.labelToken.alpha = 1;
                                 self.labelToken.transform = CGAffineTransformMakeScale(1.0,.4);
                                 self.labelToken.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-50, -padding*4), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.buttonWithdraw.alpha = 1;
                                 self.buttonWithdraw.transform = CGAffineTransformMakeScale(1.0,.5);
                                 self.buttonWithdraw.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -padding*3), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.labelWithdraw.alpha = 1;
                                 self.labelWithdraw.transform = CGAffineTransformMakeScale(1.0,.5);
                                 self.labelWithdraw.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-50, -padding*3), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.buttonDeposit.alpha = 1;
                                 self.buttonDeposit.transform = CGAffineTransformMakeScale(1.0,.6);
                                 self.buttonDeposit.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -padding*2), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.labelDeposit.alpha = 1;
                                 self.labelDeposit.transform = CGAffineTransformMakeScale(1.0,.6);
                                 self.labelDeposit.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-50, -padding*2), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.buttonTransfer.alpha = 1;
                                 self.buttonTransfer.transform = CGAffineTransformMakeScale(1.0,.7);
                                 self.buttonTransfer.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -padding), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                                 self.labelTransfer.alpha = 1;
                                 self.labelTransfer.transform = CGAffineTransformMakeScale(1.0,.7);
                                 self.labelTransfer.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-50, -padding), CGAffineTransformMakeScale(1.0, 1.0));
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        } else {
            //ESCONDE ITENS
            [UIView animateWithDuration:duration/2
                                  delay:0.0
                                options: kNilOptions
                             animations:^{
                                 _viewWhiteShadow.alpha = 0.0;
                                 self.buttonToken.alpha = 0;
                                 self.buttonToken.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelToken.alpha = 0;
                                 self.labelToken.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonWithdraw.alpha = 0;
                                 self.buttonWithdraw.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelWithdraw.alpha = 0;
                                 self.labelWithdraw.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonDeposit.alpha = 0;
                                 self.buttonDeposit.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelDeposit.alpha = 0;
                                 self.labelDeposit.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonTransfer.alpha = 0;
                                 self.buttonTransfer.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelTransfer.alpha = 0;
                                 self.labelTransfer.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                             } completion:^(BOOL finished) {
                             }];
        }
    }
}
-(void)rotationCompleted:(id)sender{
    if (self.buttonFloatAction == sender){
        //NSLog(@"buttonFloatAction rotationCompleted %s", self.buttonFloatAction.isRotated?"rotated":"normal");
    }
}

//MARK: Gesture Recognizer & Actions
- (IBAction)handlePan:(id)sender {
    
    CGPoint netTranslation = CGPointMake(0, 0);
    CGPoint translation = [(UIPanGestureRecognizer *)sender translationInView:_containerView];
    
    CGFloat alpha = 1.0;
    
    if (netTranslation.x + translation.x > 0) {
        ((UIGestureRecognizer *)sender).view.transform = CGAffineTransformMakeTranslation(netTranslation.x + translation.x, 0);
        
        NSLog(@"%f",netTranslation.x + translation.x);
        alpha = 1 - (netTranslation.x + translation.x)/100.0;
        _viewShadow.alpha = alpha;

        if (((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateEnded) {
            [UIView animateWithDuration:0.5 animations:^{
                ((UIGestureRecognizer *)sender).view.transform = CGAffineTransformMakeTranslation(0, 0);
                if (netTranslation.x + translation.x > 85) {
                    _constraintMarginRight.constant = -300;
                    _viewShadow.hidden = YES;
                    _viewShadow.alpha = 0;
                    self.navigationController.navigationBar.layer.zPosition = 0;

                }else{
                    _constraintMarginRight.constant = 0;
                    _viewShadow.alpha = 1;

                }
                
                [self.view layoutIfNeeded];
            }];
        }
    }
    
}

- (IBAction)closeReceipt:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _constraintMarginRight.constant = -300;
        _viewShadow.alpha = 0;
        self.navigationController.navigationBar.layer.zPosition = 0;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)tapShadow:(id)sender {
    
    if ([sender isKindOfClass:[UIGestureRecognizer class]] && ((UIGestureRecognizer *)sender).view == _viewShadow) {
        [UIView animateWithDuration:0.5 animations:^{
            _constraintMarginRight.constant = -300;
            _viewShadow.alpha = 0;
            self.navigationController.navigationBar.layer.zPosition = 0;
            [self.view layoutIfNeeded];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            _viewWhiteShadow.alpha = 0;
            //ESCONDE ITENS
            [UIView animateWithDuration:0.2f/2
                                  delay:0.0
                                options: kNilOptions
                             animations:^{
                                 _viewWhiteShadow.alpha = 0.0;
                                 self.buttonToken.alpha = 0;
                                 self.buttonToken.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelToken.alpha = 0;
                                 self.labelToken.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonWithdraw.alpha = 0;
                                 self.buttonWithdraw.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelWithdraw.alpha = 0;
                                 self.labelWithdraw.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonDeposit.alpha = 0;
                                 self.buttonDeposit.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelDeposit.alpha = 0;
                                 self.labelDeposit.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.buttonTransfer.alpha = 0;
                                 self.buttonTransfer.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                                 self.labelTransfer.alpha = 0;
                                 self.labelTransfer.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                             } completion:^(BOOL finished) {
                             }];
            
            _buttonFloatAction.rotated = NO;
            [self.view layoutIfNeeded];
        }];
    }
}


- (IBAction)toggleBalance:(id)sender {
    isBalanceVisible = !isBalanceVisible;
    [[NSUserDefaults standardUserDefaults] setBool:isBalanceVisible forKey:@"showBalance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self renderBalance];
    [AnalyticsUtil logEventWithName:@"visualizar_ocultar_saldo" andParameters:nil];
}

- (IBAction)openToken:(id)sender {
    UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTokenViewController"];
    
    [self.navigationController pushViewController:destination animated:YES];
}

-(IBAction)openCashIn:(id)sender{
    
//    UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPCashInPaymentSlips"];
//    ((PPPaymentSlipsViewController *)destination).fee     = _paymentSlipFee;
//    ((PPPaymentSlipsViewController *)destination).dueDays = _paymentDueDays;
    UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPCashInViewController"];
        
    [self.navigationController pushViewController:destination animated:YES];
}

-(IBAction)openTransfer:(id)sender{
    UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTransferController"];
    
    [self.navigationController pushViewController:destination animated:YES];
}

-(IBAction)openWithdraw:(id)sender{
    
    UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPWithdrawViewController"];
    
    [self.navigationController pushViewController:destination animated:YES];
}

- (void) didPressCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
