//
//  PPAccountSummaryViewController.m
//  Example
//
//  Created by Adriano Soares on 23/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPAccountSummaryViewController.h"
#import "PrePaidServices.h"
#import "LayoutManager.h"
#import "GradientView.h"
#import "UIImage+Color.h"
#import "Lib4allPreferences.h"
#import "AnalyticsUtil.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface PPAccountSummaryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerConstraint;
@property (weak, nonatomic) IBOutlet UIView             *headerButton;
@property (weak, nonatomic) IBOutlet UIImageView        *headerArrow;
@property (weak, nonatomic) IBOutlet UILabel            *headerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *button7;
@property (weak, nonatomic) IBOutlet UIImageView *button15;
@property (weak, nonatomic) IBOutlet UIImageView *button30;
@property (weak, nonatomic) IBOutlet UIImageView *button60;
@property (weak, nonatomic) IBOutlet UIImageView *button90;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *number7;
@property (weak, nonatomic) IBOutlet UILabel *number15;
@property (weak, nonatomic) IBOutlet UILabel *number30;
@property (weak, nonatomic) IBOutlet UILabel *number60;
@property (weak, nonatomic) IBOutlet UILabel *number90;

@property BOOL      headerIsOpen;
@property NSInteger periodSelected;
@property NSInteger paymentTotal;
@property NSArray  *payments;
@property double    amountTotal;
@property NSArray  *amounts;
@property NSArray *colors;
@property (copy, nonatomic) NSString *balanceTypeFriendlyName;

@end

@implementation PPAccountSummaryViewController

static CGFloat const kBottomConstraintMin = 50.0;
static CGFloat const kBottomConstraintMax = 140.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    self.headerIsOpen = false;
    self.headerConstraint.constant = kBottomConstraintMin;
    
    self.paymentTotal = 0;
    self.payments     = @[@0, @0];
    
    self.amountTotal  = 0;
    self.amounts      = @[@0, @0];
    
    self.periodSelected = 0;
    
    self.colors = @[[LayoutManager sharedManager].primaryColor,
                     [LayoutManager sharedManager].darkGreen];
    
    self.balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    
    [self.headerButton setUserInteractionEnabled:YES];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleHeader)];
    [self.headerButton addGestureRecognizer:gestureRecognizer];
    
    NSArray *periods = @[_button7, _button15, _button30, _button60, _button90];
    for (int i = 0; i < periods.count; i++) {
        UIView *button = (UIView *)periods[i];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePeriod:)];
        [button setUserInteractionEnabled:YES];
        [button addGestureRecognizer:gestureRecognizer];
    }
    
    [self loadData];

    UINavigationBar *navBar = [self.view viewWithTag:77];
    [navBar setTintColor:[LayoutManager sharedManager].lightFontColor];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    [navigationItem setTitle:@"Histórico de pagamentos"];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"x"]
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(closeButton:)];
    
    navigationItem.leftBarButtonItem = closeButton;
    [navBar setItems:@[navigationItem]];
    
    [self configureLayout];
    
    [AnalyticsUtil logEventWithName:@"visualizar_historico_pagamentos" andParameters:nil];
}

- (void) loadData {
    [self.tableView setHidden:YES];
    [_activityIndicator setHidesWhenStopped:YES];
    [_activityIndicator startAnimating];
    PrePaidServices *services = [[PrePaidServices alloc] init];
    
    NSArray *periods = @[@7, @15, @30, @60, @90];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [_activityIndicator stopAnimating];
        PopUpBoxViewController *popUp = [[PopUpBoxViewController alloc] init];
        [popUp show:self title:@"Atenção" description:msg imageMode:Error  buttonAction:nil];
    };
    
    services.successCase = ^(NSDictionary *response) {
        _payments = @[ [response objectForKey:@"totalCheckingAccount"], [response objectForKey:@"totalCredit"]  ];
        _amounts  = @[ [response objectForKey:@"totalCheckingAccountAmount"], [response objectForKey:@"totalCreditAmount"]  ];
        
        _paymentTotal = [_payments[0] integerValue] + [_payments[01] integerValue];
        _amountTotal  = [_amounts[0] doubleValue]   + [_amounts[01] doubleValue];
        
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    };
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -[periods[_periodSelected] integerValue];
    
    NSCalendar *calendar         = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date                 = [calendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    [services getSummary:[date timeIntervalSince1970]];
}

- (void)changePeriod:(UITapGestureRecognizer *)gestureRecognizer {
    UIView *touchedView = gestureRecognizer.view;

    NSArray *periods = @[_button7, _button15, _button30, _button60, _button90];
    for (int i = 0; i < periods.count; i++) {
        if(touchedView == periods[i]) {
            _periodSelected = i;
        }
    }
    [self loadData];
    [self renderPeriodButtons];
}


- (void) toggleHeader {
    self.headerIsOpen = !self.headerIsOpen;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.headerIsOpen) {
            self.headerArrow.transform = CGAffineTransformMakeRotation(180.01 * M_PI/180);
        } else {
            self.headerArrow.transform = CGAffineTransformMakeRotation(0 * M_PI/180);

        }
        
        

        self.headerConstraint.constant = self.headerIsOpen ? kBottomConstraintMax : kBottomConstraintMin;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    
    }];
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell"];
    UIImageView *icon = [cell viewWithTag:1];
    
    UILabel *title  = [cell viewWithTag:2];
    UILabel *method = [cell viewWithTag:3];
    UILabel *value  = [cell viewWithTag:4];

    LayoutManager *layout = [LayoutManager sharedManager];

    
    double  amount = 0;
    switch (indexPath.row) {
        case 0:
            title.text  = @"Total de pagamentos";
            method.text = [NSString stringWithFormat: @"Pagamentos via %@", self.balanceTypeFriendlyName];
            icon.image  = [UIImage lib4allImageNamed:@"icone_cel"];
            amount = _amountTotal;
            break;
        case 1:
            title.text  = [NSString stringWithFormat: @"Saldo %@", self.balanceTypeFriendlyName];
            method.text = @"Pagamentos via saldo da carteira";
            icon.image  = [UIImage lib4allImageNamed:@"icone_dinheiro"];
            amount = [_amounts[0] doubleValue];
            break;
            
        case 2:
            title.text  = @"Cartão de crédito";
            method.text = @"Pagamentos via cartão de credito";
            icon.image  = [UIImage lib4allImageNamed:@"icone_cartao"];
            amount = [_amounts[1] doubleValue];
            break;
    }
    
    value.text = [self currencyFormatter:amount];
    icon.image = [icon.image withColor:layout.primaryColor];
    
    title.font = [layout boldFontWithSize:layout.regularFontSize];
    method.font = [layout fontWithSize:layout.midFontSize];
    value.font = [layout boldFontWithSize:layout.regularFontSize];

    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewCell *footer = [tableView dequeueReusableCellWithIdentifier:@"footerCell"];

    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 215;
    
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UIView *chartView = [view viewWithTag:1];
    LayoutManager *layout = [LayoutManager sharedManager];
    
    float startAngle = -90;
    float radius     = (chartView.bounds.size.width/2.0);
    
    
    if ([self.payments[0] floatValue] == 0 && [self.payments[1] floatValue] == 0) {
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        float endAngle = 360.0;
        
        [shapeLayer setPath:([UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                            radius:radius-5
                                                        startAngle:DEGREES_TO_RADIANS(startAngle)
                                                          endAngle:DEGREES_TO_RADIANS(endAngle)
                                                         clockwise:YES ]).CGPath];
        
        [shapeLayer setLineCap:kCALineCapRound];
        
        [shapeLayer setFrame:[chartView bounds]];
        [shapeLayer setLineWidth:5];
        
        [shapeLayer setFillColor:[UIColor clearColor].CGColor];
        [shapeLayer setStrokeColor:layout.lightGray.CGColor];
        [chartView.layer addSublayer:shapeLayer];
        [chartView layoutSublayersOfLayer:chartView.layer];
        
        
    } else {
    
        for (int i = 0; i < [self.payments count]; i++) {
            
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            [shapeLayer setFillColor:[UIColor clearColor].CGColor];
            
            float endAngle = (360.0*([_payments[i] floatValue]/_paymentTotal)) + startAngle;
            NSLog(@"start %f", startAngle);
            NSLog(@"end %f", endAngle);
            
            
            [shapeLayer setPath:([UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                                radius:radius-5
                                                            startAngle:DEGREES_TO_RADIANS(startAngle)
                                                              endAngle:DEGREES_TO_RADIANS(endAngle)
                                                             clockwise:YES ]).CGPath];
            
            [shapeLayer setLineCap:kCALineCapRound];
            
            [shapeLayer setFrame:[chartView bounds]];
            [shapeLayer setLineWidth:5];
            
            [shapeLayer setStrokeColor:((UIColor *)self.colors[i]).CGColor];
            
            [chartView.layer addSublayer:shapeLayer];
            [chartView layoutSublayersOfLayer:chartView.layer];
            
            startAngle = endAngle;
            
        }
    }
    UILabel *chartLabel = [view viewWithTag:2];
    chartLabel.text           = [NSString stringWithFormat:@"%02ld \npagamentos \nno total", (long)self.paymentTotal];
    chartLabel.textAlignment  = NSTextAlignmentCenter;
    chartLabel.font           = [layout fontWithSize:[layout regularFontSize]];
    
    
    NSMutableAttributedString *att = [chartLabel.attributedText mutableCopy];
    
    [att addAttribute:NSFontAttributeName
                value:[layout boldFontWithSize:layout.titleFontSize]
                range:[chartLabel.text rangeOfString:[NSString stringWithFormat:@"%02ld", (long)self.paymentTotal]]];

    chartLabel.attributedText = att;

    
    [view viewWithTag:3].backgroundColor = self.colors[0];
    [view viewWithTag:5].backgroundColor = self.colors[1];
    
    NSString *walletBalance = @"Saldo da conta";
    
    NSArray *roundViews = @[[view viewWithTag:3], [view viewWithTag:5]];
    NSArray *labels     = @[[view viewWithTag:4], [view viewWithTag:6]];
    NSArray *methods    = @[walletBalance, @"cartão de crédito"];
    
    
    for (int i = 0; i < roundViews.count; i++) {
        UIView *roundView = roundViews[i];
        roundView.backgroundColor = self.colors[i];
        roundView.layer.cornerRadius = roundView.frame.size.height/2;
        
        UILabel *label = labels[i];
        label.text     = [NSString stringWithFormat:@"%02d pagamentos via %@", [self.payments[i] intValue], methods[i]];
        label.font     = [layout fontWithSize:layout.regularFontSize];
        
        NSMutableAttributedString *att = [label.attributedText mutableCopy];
        
        [att addAttribute:NSFontAttributeName
                    value:[layout boldFontWithSize:layout.titleFontSize]
                    range:[label.text rangeOfString:[NSString stringWithFormat:@"%02d", [self.payments[i] intValue]]]];
        
        
        [att addAttribute:NSFontAttributeName
                    value:[layout boldFontWithSize:layout.regularFontSize]
                    range:[label.text rangeOfString:methods[i]]];
        label.attributedText = att;
        
    }
    
    UILabel *titleLabel = [view viewWithTag:99];
    titleLabel.font     = [layout boldFontWithSize:layout.titleFontSize];
    


    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;

}


- (void) renderPeriodButtons {
    NSArray *periods = @[_button7, _button15, _button30, _button60, _button90];
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    for (int i = 0; i < periods.count; i++) {
        UIView *button = periods[i];
        button.layer.cornerRadius = button.frame.size.height/2;
        button.layer.borderColor  = [layout primaryColor].CGColor;
        button.layer.borderWidth  = 1.0f;
        if (i == self.periodSelected) {
            button.backgroundColor = [layout primaryColor];
        } else {
            button.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
    }
    NSString *period = @"";
    
    switch (self.periodSelected) {
        case 0:
            period = @" 7";
            break;
        case 1:
            period = @"15";
            break;
        case 2:
            period = @"30";
            break;
        case 3:
            period = @"60";
            break;
        case 4:
            period = @"90";
            break;
    }
    
    self.headerLabel.text = [NSString stringWithFormat:@"Periodo: últimos %@ dias", period];

}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    self.tableView.backgroundColor = layout.backgroundColor;
    [self renderPeriodButtons];
    
    self.titleLabel.font  = [layout boldFontWithSize:layout.titleFontSize];
    self.headerLabel.font = [layout fontWithSize:layout.subTitleFontSize];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    //[self.tableView setHidden:YES];
    
    UINavigationBar *navBar = [self.view viewWithTag:77];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:layout.lightFontColor, NSFontAttributeName:[layout fontWithSize:[layout navigationTitleFontSize]]}];
    
    //set the gradient effect
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, navBar.bounds.size.width, navBar.bounds.size.height+40);
    gradient.colors = [NSArray arrayWithObjects:(id)[[layout primaryColor] CGColor], (id)[[layout gradientColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint   = CGPointMake(1, 1);
    
    
    [navBar setBackgroundImage:[self imageFromLayer:gradient] forBarMetrics:UIBarMetricsDefault];
    
    NSArray *numberArray = @[_number7, _number15, _number30, _number60, _number90];
    for (UILabel *label in numberArray) {
        label.textColor = layout.primaryColor;
    }
    
    self.line.backgroundColor = layout.primaryColor;
    self.headerArrow.image = [self.headerArrow.image withColor:layout.primaryColor];
}


- (void) viewDidLayoutSubviews {
    LayoutManager *layout = [LayoutManager sharedManager];

    UINavigationBar *navBar = [self.view viewWithTag:77];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:layout.lightFontColor, NSFontAttributeName:[layout fontWithSize:[layout navigationTitleFontSize]]}];
    
    //set the gradient effect
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, navBar.bounds.size.width, navBar.bounds.size.height+40);
    gradient.colors = [NSArray arrayWithObjects:(id)[[layout primaryColor] CGColor], (id)[[layout gradientColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint   = CGPointMake(1, 1);
    
    [navBar setBackgroundImage:[self imageFromLayer:gradient] forBarMetrics:UIBarMetricsDefault];

}


- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (IBAction)closeButton:(id)sender {
    [AnalyticsUtil logEventWithName:@"sair_tela_historico" andParameters:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNavigationBar" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *) currencyFormatter:(double) amount {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *value = [formatter stringFromNumber: [NSNumber numberWithFloat:amount/100]];
    value = [value stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    return value;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
