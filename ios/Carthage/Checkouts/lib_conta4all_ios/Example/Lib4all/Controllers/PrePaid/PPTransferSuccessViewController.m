//
//  PPTransferSuccessViewController.m
//  Example
//
//  Created by Luciano Bohrer on 16/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPTransferSuccessViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"

#import "PPTransferContactViewController.h"
#import "PPBalanceViewController.h"

@interface PPTransferSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonTransferAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonDismiss;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;


@property (weak, nonatomic) IBOutlet UILabel *textNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *textAmountTitle;
@property (weak, nonatomic) IBOutlet UILabel *textAuthenticationTitle;

@property (weak, nonatomic) IBOutlet UILabel *textName;
@property (weak, nonatomic) IBOutlet UILabel *textAmount;
@property (weak, nonatomic) IBOutlet UILabel *textAuthentication;

@end

@implementation PPTransferSuccessViewController

static NSString* const kNavigationTitle = @"Transferir";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupController];
}

-(void)setupController{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    NSArray *regularLabels = @[_textNameTitle, _textAmountTitle, _textAuthenticationTitle];
    for (int i = 0; i < regularLabels.count; i++) {
        UILabel *label = regularLabels[i];
        
        label.font = [layout fontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }
    
    NSArray *boldLabels = @[_textName, _textAmount, _textAuthentication];
    for (int i = 0; i < boldLabels.count; i++) {
        UILabel *label = boldLabels[i];
        
        label.font = [layout boldFontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }
    
    NSArray *lineButtons = @[_buttonTransferAgain, _buttonDismiss];
    
    for (UIButton *button in lineButtons) {
        [button.layer setCornerRadius:6.0f];
        [button.layer setBorderColor:layout.primaryColor.CGColor];
        [button.layer setBorderWidth:1.0];
        [button.titleLabel setFont:[layout fontWithSize:layout.subTitleFontSize]];
        [button.titleLabel setTextColor:layout.primaryColor];
        [button setTintColor:layout.primaryColor];
    }
    
    [_labelDescription setFont:[layout fontWithSize:layout.titleFontSize]];
    
    _textName.text = _name;
    _textAmount.text = _amountValue;
    _textAuthentication.text = _transferId;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeController:)];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = closeButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (IBAction)transferAgain:(id)sender {
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[PPTransferContactViewController class]]) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
        }
    }
}


- (IBAction)closeController:(id)sender {
    
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[PPBalanceViewController class]]) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
            
        }
    }
    
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[PPTransferContactViewController class]]) {
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPBalanceViewController"];
            
            [controllers insertObject:destination atIndex:i];
            [self.navigationController setViewControllers: controllers];
            [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
            
        }
    }
}

@end
