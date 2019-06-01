//
//  PPPaymentSlipsViewController.m
//  Example
//
//  Created by Luciano Bohrer on 22/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPPaymentSlipsViewController.h"
#import "PPMyPaymentSlipsTableViewController.h"
#import "PPCreatePaymentSlipViewController.h"
#import "BaseNavigationController.h"
#import "MDTabBarViewController.h"
#import "UIView+Gradient.h"
#import "LayoutManager.h"
#import "PopUpBoxViewController.h"

@interface PPPaymentSlipsViewController () <MDTabBarViewControllerDelegate>
@property NSArray *viewArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMarginRight;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonCloseReceipt;
@property (weak, nonatomic) IBOutlet UIView *viewShadow;
@property (weak, nonatomic) IBOutlet UIView *navBar;

@end

@implementation PPPaymentSlipsViewController

static NSString* const kNavigationTitle = @"Adicionar dinheiro";


- (void)viewDidLoad {
    [super viewDidLoad];

    UIViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"PPCreatePaymentSlipViewController"];
    
    UIViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"PPMyPaymentSlipsTableViewController"];

    self.viewArray = @[vc1 ,vc2];
    
    ((PPCreatePaymentSlipViewController *)vc1).fee        = _fee;
    ((PPCreatePaymentSlipViewController *)vc1).dueDays    = _dueDays;
    ((PPCreatePaymentSlipViewController *)vc1).parentVC   = self;

    ((PPMyPaymentSlipsTableViewController *)vc2).parentVC = self;
    
    self.tabBarViewController = [[MDTabBarViewController alloc] initWithDelegate:self];
    NSArray *names = @[
                       @"GERAR BOLETO",
                       @"MEUS BOLETOS"
                       ];
    [self.tabBarViewController setItems:names];
    
    
    [self addChildViewController:self.tabBarViewController];
    UIView *containerView = [self.view viewWithTag:99];
    [containerView addSubview:self.tabBarViewController.view];
    [self.tabBarViewController didMoveToParentViewController:self];
    
    UIView *controllerView = self.tabBarViewController.view;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(controllerView);
    
    [self.view
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|["
                     @"controllerView]|"
                     options:0
                     metrics:nil
                     views:viewsDictionary]];
    [self.view
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"H:|[controllerView]|"
                     options:0
                     metrics:nil
                     views:viewsDictionary]];
    
    [self configureLayout];
    
    UITapGestureRecognizer *tapOnShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadow:)];
    
    [_viewShadow addGestureRecognizer:tapOnShadow];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"left-nav-arrow"]
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched)];
        
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.viewArray[1] loadData];
    
    [self configureLayout];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationItem.title = @"";

}

-(void) loadData {
    [self.viewArray[1] loadData];

}

-(void) configureLayout{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    [(BaseNavigationController *)self.navigationController configureLayout];
    
    self.navigationItem.title = kNavigationTitle;
    
    self.tabBarViewController.tabBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tabBarViewController.tabBar.rippleColor     = [UIColor groupTableViewBackgroundColor];
    self.tabBarViewController.tabBar.indicatorColor  = layout.secondaryColor;
    self.tabBarViewController.tabBar.normalTextColor = layout.mediumGray;
    self.tabBarViewController.tabBar.normalTextFont  = [layout fontWithSize:layout.regularFontSize];
    self.tabBarViewController.tabBar.textColor       = [UIColor blackColor];
    self.tabBarViewController.tabBar.textFont        = [layout fontWithSize:layout.regularFontSize];
    
    
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
    
    
    [self.navBar setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
}

-(void)showReceiptOfType:(ReceiptType)type withData:(NSDictionary *)receiptData{
    UIView *contentView = [[DetailsManager sharedManager] getConfiguredViewByType:type withDataToFill:receiptData withCardCashInFees:nil];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)tabBarViewController: (MDTabBarViewController *)viewController viewControllerAtIndex:(NSUInteger)index {
    
    return _viewArray[index];
}

- (void)tabBarViewController:(MDTabBarViewController *)viewController didMoveToIndex:(NSUInteger)index {
}


- (void) closeButtonTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
