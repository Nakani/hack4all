//
//  PPTokenViewController.m
//  Example
//
//  Created by Adriano Soares on 29/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPTokenViewController.h"
#import "LayoutManager.h"
#import "UIView+Gradient.h"
#import "User.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "UIImage+Color.h"
#import "TOTPGenerator.h"
#import "MF_Base32Additions.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface PPTokenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView  *chartView;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;

@property (strong, nonatomic) NSTimer *generatorTimer;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;


@property (strong, nonatomic) NSString *totpKey;


@end

@implementation PPTokenViewController

static NSString* const kNavigationTitle = @"Token";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tokenLabel setHidden:YES];

    self.totpKey = [User sharedUser].totpKey;
    
    if (self.totpKey == nil) {
        Services *getAccountDataService = [[Services alloc] init];
        
        getAccountDataService.failureCase = ^(NSString *cod, NSString *msg) {};
        
        getAccountDataService.successCase = ^(NSDictionary *response) {
            self.totpKey = [User sharedUser].totpKey;
            [self renderChart];
        };
        
        [getAccountDataService getAccountData:@[TotpKey]];
    }
    
    [self configureLayout];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self renderBaseChart];
    if (self.totpKey) {
        self.generatorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(renderChart) userInfo:nil repeats:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.totpKey) {
        [self.generatorTimer invalidate];
        self.generatorTimer = nil;
    }
    self.navigationItem.title = @"";
}

- (void) renderBaseChart {
    float radius     = (self.chartView.bounds.size.width/2.0);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:([UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                        radius:radius-5
                                                    startAngle:DEGREES_TO_RADIANS(0)
                                                      endAngle:DEGREES_TO_RADIANS(360)
                                                     clockwise:YES ]).CGPath];
    
    [shapeLayer setLineCap:kCALineCapRound];
    
    [shapeLayer setFrame:[self.chartView bounds]];
    [shapeLayer setLineWidth:12];
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor];
    
    [self.chartView.layer addSublayer:shapeLayer];
    [self.chartView layoutSublayersOfLayer:self.chartView.layer];

}

- (void) renderChart {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger  seconds   = [calendar component:NSCalendarUnitSecond fromDate:[NSDate date]];
    
    float startAngle = -90.0;
    float endAngle = (360.0*(seconds%30/30.0)) + startAngle;

    float radius = (self.chartView.bounds.size.width/2.0);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:([UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                        radius:radius-5
                                                    startAngle:DEGREES_TO_RADIANS(startAngle)
                                                      endAngle:DEGREES_TO_RADIANS(endAngle)
                                                     clockwise:YES ]).CGPath];
    
    [shapeLayer setLineCap:kCALineCapRound];
    
    [shapeLayer setFrame:[self.chartView bounds]];
    [shapeLayer setLineWidth:12];
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:[[LayoutManager sharedManager] tokenProgressColor].CGColor];
    
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = shapeLayer;
    
    [self.chartView.layer addSublayer:shapeLayer];
    [self.chartView layoutSublayersOfLayer:self.chartView.layer];
    
    
    NSData *base32Data = [NSData dataWithBase32String:_totpKey];
    
    
    TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:base32Data
                                                           algorithm:kOTPGeneratorSHA1Algorithm
                                                              digits:6
                                                              period:30];
    
    NSString *totpPin = [generator generateOTPForDate:[NSDate date]];
    
    self.tokenLabel.text = [NSString stringWithFormat:@"%@ %@", [totpPin substringToIndex:3], [totpPin substringFromIndex:3]];;
    [self.tokenLabel setHidden:NO];
    
    if (self.generatorTimer == nil) {
        self.generatorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(renderChart) userInfo:nil repeats:YES];
    }
}

- (void) configureNavigationBar {
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
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.titleLabel.font = [layout fontWithSize:[layout subTitleFontSize]];
    self.titleLabel.textColor = layout.lightFontColor;
    
    self.tokenLabel.font = [layout fontWithSize:40];
    self.tokenLabel.textColor = layout.lightFontColor;

    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    if([Lib4allPreferences sharedInstance].tokenScreenTitle) {
        _titleLabel.text = [Lib4allPreferences sharedInstance].tokenScreenTitle;
    }
}

- (void) didPressCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
