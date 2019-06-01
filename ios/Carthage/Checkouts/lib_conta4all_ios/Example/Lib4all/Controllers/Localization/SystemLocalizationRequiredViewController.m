//
//  SystemLocalizationRequiredViewController.m
//  Example
//
//  Created by Cristiano Matte on 05/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SystemLocalizationRequiredViewController.h"
#import "LayoutManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+Gradient.h"

@interface SystemLocalizationRequiredViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation SystemLocalizationRequiredViewController

static NSString* const kNavigationTitle = @"Cadastro";

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.title = kNavigationTitle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.navigationItem.title = @"";

}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    if ([CLLocationManager locationServicesEnabled]) {
        [_flowController viewControllerDidFinish:self];
    }
}

// MARK: - Actions

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)enableLocalizationButtonTouched {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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
