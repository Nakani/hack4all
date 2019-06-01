//
//  WithdrawViewController.m
//  Example
//
//  Created by Luciano Bohrer on 23/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPWithdrawViewController.h"
#import "PPTokenViewController.h"
#import "PrePaidServices.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"
#import "User.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "TOTPGenerator.h"
#import "MF_Base32Additions.h"
#import "Lib4allPreferences.h"
#import "AnalyticsUtil.h"

@interface PPWithdrawViewController ()
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *avaliableLabel;
@property (weak, nonatomic) IBOutlet UIButton *showBalanceButton;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelIntro;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (weak, nonatomic) IBOutlet UILabel *labelFive;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstStep;
@property (weak, nonatomic) IBOutlet UILabel *labelSecondStep;
@property (weak, nonatomic) IBOutlet UILabel *labelThirdStep;
@property (weak, nonatomic) IBOutlet UILabel *labelFourthStep;
@property (weak, nonatomic) IBOutlet UILabel *labelFifthStep;

@property (weak, nonatomic) IBOutlet UIProgressView *tokenProgressView;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tokenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *balanceLabelTopConstraint;

@property (strong, nonatomic) NSTimer *generatorTimer;
@property (strong, nonatomic) UITapGestureRecognizer *tryAgainGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *toggleBalanceGestureRecognizer;
@property (strong, nonatomic) NSString *totpKey;

@property double balance;

@end

@implementation PPWithdrawViewController

static BOOL isBalanceVisible;

static NSString* const kNavigationTitle = @"Sacar";

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.totpKey = [User sharedUser].totpKey;
    
    id showBalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"showBalance"];
    if (showBalance == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showBalance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    isBalanceVisible = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBalance"];
    
    self.tryAgainGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getBalance)];
    self.toggleBalanceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBalance:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configureNavigationBar)
                                                 name:@"updateNavigationBar"
                                               object:nil];
    
    [self configureLayout];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator setHidden:YES];
            [self.balanceLabel setHidden:NO];
            [self.avaliableLabel setHidden:NO];
            [self.showBalanceButton setHidden:NO];
            
            [self.balanceLabel addGestureRecognizer:_toggleBalanceGestureRecognizer];
            [self renderBalance];
        });
    };
    
    [self.activityIndicator setHidden:NO];
    [self.balanceLabel setHidden:YES];
    [self.avaliableLabel setHidden:YES];
    [self.showBalanceButton setHidden:YES];
    
    LayoutManager *layout = [LayoutManager sharedManager];
    self.balanceLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    [services balance];
}

-(void)viewWillAppear:(BOOL)animated {
    [self getBalance];
    [self configureNavigationBar];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateNavigationBar" object:nil];
    
    self.navigationItem.title = @"";
    
    if (self.totpKey) {
        [self.generatorTimer invalidate];
        self.generatorTimer = nil;
    }
}

- (void)configureNavigationBar {
    
    self.navigationItem.title = kNavigationTitle;
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

- (void)configureLayout{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.avaliableLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.balanceLabel.textColor = layout.lightFontColor;
    self.avaliableLabel.textColor = layout.lightFontColor;
    
    NSArray *regularFonts = @[_labelDescription, _labelFirstStep,_labelSecondStep, _labelThirdStep,_labelFourthStep, _labelFifthStep, _tokenLabel];
    NSArray *numberLabels = @[_labelOne, _labelTwo, _labelThree, _labelFour, _labelFive];
    
    for (UILabel *label in regularFonts) {
        label.font = [layout fontWithSize:layout.regularFontSize];
        label.textColor = layout.darkFontColor;
        if ([label.text containsString:@"Saque e Pague"]) {
            NSMutableAttributedString *att = [label.attributedText mutableCopy];
            [att addAttribute:NSFontAttributeName
                        value:[layout boldFontWithSize:layout.regularFontSize]
                        range:[label.text rangeOfString:@"Saque e Pague"]];
            
            label.attributedText = att;
        }
        
        if ([label.text containsString:@"\"Token\""]) {
            NSMutableAttributedString *att = [label.attributedText mutableCopy];
            [att addAttribute:NSFontAttributeName
                        value:[layout boldFontWithSize:layout.regularFontSize]
                        range:[label.text rangeOfString:@"\"Token\""]];
            
            label.attributedText = att;
        }
    }
    
    for (UILabel *label in numberLabels) {
        label.textColor = layout.primaryColor;
        label.font = [layout boldFontWithSize:layout.regularFontSize];
    }
    
    _labelIntro.font = [layout boldFontWithSize:layout.subTitleFontSize];
    _labelIntro.textColor = layout.darkFontColor;
    
    [_tokenView setUserInteractionEnabled:YES];
    [_tokenView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tokenTouched)]];
    
    _tokenLabel.text = @"Gerar token";
    _tokenProgressView.hidden = YES;
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    _labelSecondStep.text = [_labelSecondStep.text stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
    
    _tokenProgressView.progressTintColor = layout.secondaryColor;
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
        [self.showBalanceButton setImage:image forState:UIControlStateNormal];
        
    } else {
        self.balanceLabel.text = @"Saldo";
        [self.avaliableLabel setHidden: YES];
        UIImage *image = [UIImage lib4allImageNamed:@"saldo_invisivel"];
        [self.showBalanceButton setImage:image forState:UIControlStateNormal];
    }
}
    
- (void) didPressCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleBalance:(id)sender {
    isBalanceVisible = !isBalanceVisible;
    [[NSUserDefaults standardUserDefaults] setBool:isBalanceVisible forKey:@"showBalance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self renderBalance];
}

- (void)tokenTouched {
    [AnalyticsUtil logEventWithName:@"gerar_token_saque" andParameters:nil];
    
    self.totpKey = [User sharedUser].totpKey;
    
    if (self.totpKey == nil) {
        Services *getAccountDataService = [[Services alloc] init];
        
        getAccountDataService.failureCase = ^(NSString *cod, NSString *msg) {};
        
        getAccountDataService.successCase = ^(NSDictionary *response) {
            self.totpKey = [User sharedUser].totpKey;
            [self renderProgressView];
        };
        
        [getAccountDataService getAccountData:@[TotpKey]];
    } else {
        [self renderProgressView];
    }
}

- (void) renderProgressView {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger  seconds   = [calendar component:NSCalendarUnitSecond fromDate:[NSDate date]];
    
    NSInteger expirationTime;
    
    if (seconds > 30) {
        expirationTime = 60 - seconds;
    } else {
        expirationTime = 30 - seconds;
    }
    
    if (expirationTime == 0) {
        expirationTime = 30;
    }
    
    _tokenProgressView.progress = expirationTime/30.0;
    
    
    NSData *base32Data = [NSData dataWithBase32String:_totpKey];
    
    
    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:base32Data
                                                           algorithm:kOTPGeneratorSHA1Algorithm
                                                              digits:6
                                                              period:30];
    
    NSString *totpPin = [generator generateOTPForDate:[NSDate date]];
    
    self.tokenLabel.text = [NSString stringWithFormat:@"%@ %@", [totpPin substringToIndex:3], [totpPin substringFromIndex:3]];;
    self.tokenProgressView.hidden = NO;
    
    if (self.generatorTimer == nil) {
        self.generatorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(renderProgressView) userInfo:nil repeats:YES];
    }
}

@end
