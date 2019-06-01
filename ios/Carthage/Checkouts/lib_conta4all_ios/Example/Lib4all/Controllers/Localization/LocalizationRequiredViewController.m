//
//  LocalizationRequiredViewController.m
//  Example
//
//  Created by Cristiano Matte on 03/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LocalizationRequiredViewController.h"
#import "LayoutManager.h"
#import "User.h"
#import "UIView+Gradient.h"
#import <CoreLocation/CoreLocation.h>

@interface LocalizationRequiredViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation LocalizationRequiredViewController

static NSString* kNavigationTitle = @"Cadastro";


// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    if(_flowController.isFromAddCardMenu) {
        kNavigationTitle = @"Cartão";
        _titleLabel.text = @"Desculpa! Você precisa autorizar a sua localização para finalizar o processo de adição do cartão.";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.title = kNavigationTitle;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLayout];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
}

// MARK: - Actions

- (IBAction)enableLocalizationButtonTouched {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];    
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [_flowController viewControllerDidFinish:self];
    }
}

// MARK: - Layout

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [layout backgroundColor];
    
    self.titleLabel.font = [layout fontWithSize:[layout subTitleFontSize]];
    self.titleLabel.textColor = layout.lightFontColor;
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
   
    /*
    NSString *firstName = [[User sharedUser].fullName componentsSeparatedByString:@" "][0];
    if (firstName == nil) {
        firstName = @"";
    }
    self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"<name>" withString:firstName];
    */
}

@end
