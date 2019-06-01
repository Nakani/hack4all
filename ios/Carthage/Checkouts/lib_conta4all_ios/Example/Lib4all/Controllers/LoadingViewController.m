//
//  LoadingViewController.m
//  Example
//
//  Created by 4all on 4/28/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "Lib4allPreferences.h"
#import "UIImage+Color.h"

@interface LoadingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgBars;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBarsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBarsWidthConstraint;
@end


@implementation LoadingViewController

+ (id)sharedManager {
    static LoadingViewController *sharedUser = nil;
    
    @synchronized(self) {
        if (sharedUser == nil)
            sharedUser = [[self alloc] init];
    }
    return sharedUser;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isLoading = NO;
        self.view = [[NSBundle getLibBundle] loadNibNamed:@"LoadingViewController" owner:self options:nil][0];
        //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        self.lblTitle.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
        
        if ([Lib4allPreferences sharedInstance].loaderColor != nil) {
            self.imgBars.image = [self.imgBars.image withColor:[Lib4allPreferences sharedInstance].loaderColor];
        }
        
        double iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
        if (iOSVersion >= 8.0 && !UIAccessibilityIsReduceTransparencyEnabled()) {
            self.modalPresentationStyle = UIModalPresentationCustom;
            
            self.view.backgroundColor = [UIColor clearColor];
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = self.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.view addSubview:blurEffectView];
            [self.view sendSubviewToBack:blurEffectView];
        }  
        else {
            self.modalPresentationStyle = UIModalPresentationFullScreen;
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        }
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 2.0f;
    animation.repeatCount = INFINITY;
    [self.imgBars.layer addAnimation:animation forKey:@"SpinAnimation"];
}

- (void)startLoading:(UIViewController *)rootView title:(NSString *)title completion: (void (^)())completion {
    
    double iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (iOSVersion < 8) {
        [rootView presentViewController:self animated:NO completion:completion];
    } else {
        [rootView presentViewController:self animated:YES completion:completion];
    }
    self.lblTitle.text = title;
    self.isLoading = YES;
}

- (void)startLoading:(UIViewController *)rootView title:(NSString *)title{
    
    if ([Lib4allPreferences sharedInstance].loaderColor != nil) {
        self.imgBars.image = [self.imgBars.image withColor:[Lib4allPreferences sharedInstance].loaderColor];
    }
    
    [self startLoading:rootView title:title completion:nil];
}

- (void)finishLoading: (void (^)())completion{
    self.isLoading = NO;
    
    double iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (iOSVersion < 8) {
        [self dismissViewControllerAnimated:NO completion:completion];
    } else {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
}

@end
