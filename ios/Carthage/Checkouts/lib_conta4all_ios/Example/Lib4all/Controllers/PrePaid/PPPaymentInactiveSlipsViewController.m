//
//  PPPaymentInactiveSlipsViewController.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 05/10/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPPaymentInactiveSlipsViewController.h"
#import "PrePaidServices.h"
#import "LayoutManager.h"
#import "BaseNavigationController.h"

@interface PPPaymentInactiveSlipsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *avaliableLabel;
@property (weak, nonatomic) IBOutlet UIButton *showBalanceButton;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelIntro;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstStep;
@property (weak, nonatomic) IBOutlet UILabel *labelSecondStep;
@property (weak, nonatomic) IBOutlet UILabel *labelThirdStep;
@property (weak, nonatomic) IBOutlet UILabel *labelFourthStep;
@property (weak, nonatomic) IBOutlet UIView *viewVerticalLine;

@property (strong, nonatomic) UITapGestureRecognizer *tryAgainGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *toggleBalanceGestureRecognizer;


@property double balance;

@end

@implementation PPPaymentInactiveSlipsViewController

static BOOL isBalanceVisible;

static NSString* const kNavigationTitle = @"Depositar";

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    id showBalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"showBalance"];
    if (showBalance == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showBalance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    isBalanceVisible = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBalance"];
    
    self.tryAgainGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getBalance)];
    self.toggleBalanceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBalance:)];
    
    [self configureLayout];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"left-nav-arrow"]
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        
        self.navigationItem.leftBarButtonItem = closeButton;

    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getBalance];
    
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
     [((BaseNavigationController *) self.navigationController) configureLayout];

    self.navigationItem.title = @"";
}


- (void)configureLayout{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.avaliableLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.balanceLabel.textColor = layout.lightFontColor;
    self.avaliableLabel.textColor = layout.lightFontColor;
    
    
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault]; //UIlibuttonTransferallImageNamed:@"transparent.png"
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    NSArray *regularFonts = @[_labelDescription, _labelFirstStep,_labelSecondStep, _labelThirdStep,_labelFourthStep, _labelOne, _labelTwo, _labelThree, _labelFour];
    NSArray *roundLabels = @[_labelOne, _labelTwo, _labelThree, _labelFour];
    
    for (UILabel *label in regularFonts) {
        label.font = [layout fontWithSize:layout.regularFontSize];
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
    
    for (UILabel *label in roundLabels) {
        label.layer.cornerRadius = label.frame.size.height/2;
        label.layer.borderColor  = layout.primaryColor.CGColor;
        label.textColor          = layout.primaryColor;
        label.layer.borderWidth  = 1;
    }
    
    
    self.navigationItem.title = kNavigationTitle;
    
    _labelIntro.font = [layout boldFontWithSize:layout.subTitleFontSize];
    _viewVerticalLine.backgroundColor = layout.primaryColor;
    
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


- (IBAction)toggleBalance:(id)sender {
    isBalanceVisible = !isBalanceVisible;
    [[NSUserDefaults standardUserDefaults] setBool:isBalanceVisible forKey:@"showBalance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self renderBalance];
}
    
- (void)closeButtonTouched {
    [self dismissViewControllerAnimated:true completion:nil];
}
    
@end
