//
//  BaseNavigationController.m
//  Example
//
//  Created by 4all on 5/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "BaseNavigationController.h"
#import "LayoutManager.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (instancetype)init {
    self = [super init];

    if (self) {
        [self configureLayout];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self configureLayout];
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        [self configureLayout];
    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        [self configureLayout];
    }
    
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    
    if (self) {
        [self configureLayout];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureLayout];
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    self.navigationBar.barStyle = layout.barStyle;
    self.navigationBar.translucent = YES;
    //self.navigationBar.barTintColor = [[LayoutManager sharedManager] lightGreen];
    self.navigationBar.tintColor = layout.lightFontColor;
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:layout.lightFontColor, NSFontAttributeName:[[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] navigationTitleFontSize]]}];
    
    //set the gradient effect
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    int size = 20;
    
    if ([UIScreen mainScreen].nativeBounds.size.height >= 2436) {
        //Iphone X
        size = 44;
    }
    
    gradient.frame = CGRectMake(0, 0, self.navigationBar.bounds.size.width, self.navigationBar.bounds.size.height+size);
    gradient.colors = [NSArray arrayWithObjects:(id)[[layout primaryColor] CGColor], (id)[[layout gradientColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint   = CGPointMake(1, 1);
    
    [self.navigationBar setBackgroundImage:[self imageFromLayer:gradient] forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
