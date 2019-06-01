//
//  PinConfirmationViewController.m
//  Example
//
//  Created by Cristiano Matte on 30/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "PinConfirmationViewController.h"
#import "LoadingViewController.h"
#import "ChallengeViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "UIView+Gradient.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"
#import "Services.h"
#import "MainActionButton.h"

@interface PinConfirmationViewController () < UITextFieldDelegate, UIGestureRecognizerDelegate >

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *pinTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet MainActionButton *mainButton;

@end

@implementation PinConfirmationViewController

static CGFloat const kBottomConstraintMin = 22.0;
static NSString* const kNavigationTitle = @"Cadastro";
// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [_pinTextField setKeyboardType:UIKeyboardTypeDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
    [_pinTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.title = @"";
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_pinTextField resignFirstResponder];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        if([[UIScreen mainScreen] bounds].size.height < 568){
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = _heightHeader.constant - 95;
        }
        
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        if ([[UIScreen mainScreen] bounds].size.height<=480.0f) {
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = 222;
        }
        
        self.bottomConstraint.constant = kBottomConstraintMin;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
}


// MARK: - Actions

- (IBAction)continueButtonTouched {
    if (![self isPinValid:_pinTextField.text]) {
        [_pinTextField showFieldWithError:YES];
        return;
    } else {
        [_pinTextField showFieldWithError:NO];
    }
    
    if (_signFlowController.isLogin) {
        Services *services = [[Services alloc] init];
        LoadingViewController *loading = [[LoadingViewController alloc] init];
        
        services.failureCase = ^(NSString *cod, NSString *msg){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:ok];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading finishLoading:^{
                    [self presentViewController:alert animated:YES completion:nil];
                }];
            });
        };
        
        services.successCase = ^(NSDictionary *response){
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading finishLoading:^{
                    [_signFlowController viewControllerDidFinish:self];
                }];
            });
        };
        
        
        [loading startLoading:self title:@"Aguarde..."];
        [services setNewPassword:self.pinTextField.text oldPassword:nil];
    } else {
        // Se está em processo de cadastro, senha será enviada apenas no completeCustomerCreation
        [_signFlowController viewControllerDidFinish:self];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)isPinValid:(NSString *)pin {
    if ([pin isEqualToString:_signFlowController.enteredPassword]) {
        return YES;
    } else {
        return NO;
    }
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueButtonTouched];
    return YES;
}

// MARK: - Layout

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    // Configura view
    self.view.backgroundColor = layout.backgroundColor;
    
    // Configura navigation bar
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault]; //UIlib4allImageNamed:@"transparent.png"
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    self.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.titleLabel.text = @"Por favor, confirme sua senha.";
    self.titleLabel.numberOfLines = 5;
    self.titleLabel.textColor = layout.lightFontColor;
    
    self.subTitleLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.subTitleLabel.text = @"É importante para sua segurança.";
    self.subTitleLabel.textColor = layout.lightFontColor;
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.pinTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.pinTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.pinTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.pinTextField setBottomBorderWithColor: layout.lightGray];
    self.pinTextField.clearButtonMode = UITextFieldViewModeNever;
    self.pinTextField.delegate = self;
    
    self.pinTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.pinTextField.textColor = layout.darkFontColor;
    [self.pinTextField setPlaceholder:@"Repetir senha"];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
}


#pragma mark - Gesture Recognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    //Evita a necessidade de tocar duas vezes  no botão
    if ([touch.view isDescendantOfView:_mainButton]) {
        return NO;
    }
    
    return YES;
}

@end
