//
//  LocalizationPermissionViewController.m
//  Example
//
//  Created by Cristiano Matte on 01/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LocalizationPermissionViewController.h"
#import "LayoutManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+Gradient.h"
#import "AnalyticsUtil.h"

@interface LocalizationPermissionViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation LocalizationPermissionViewController

static NSString* const kNavigationTitle = @"Cadastro";

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AnalyticsUtil createScreenViewWithName:@"permissao_localizacao"];
    
    [self configureLayout];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
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
    [AnalyticsUtil createEventWithCategory:@"account" action:@"allow" label:@"allow access location" andValue:nil];

    [_locationManager requestWhenInUseAuthorization];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
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
    
    self.descriptionLabel.font = [layout fontWithSize:[layout regularFontSize]];
    self.descriptionLabel.textColor = layout.lightFontColor;
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
}

@end
