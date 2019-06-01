//
//  DataFieldViewController.m
//  Example
//
//  Created by Cristiano Matte on 02/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "DataFieldViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "LoadingViewController.h"
#import "Services.h"
#import "UIImage+Color.h"
#import "UIView+Gradient.h"
#import "CardAdditionFlowController.h"

@interface DataFieldViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dataTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation DataFieldViewController

static CGFloat const kBottomConstraintMin = 22.0;
static NSString* const kNavigationTitle = @"Cadastro";

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    if(_dataFieldProtocol.preSettedField) {
        _dataTextField.text = _dataFieldProtocol.preSettedField;
    }
    
    if (_dataIsRequired) {
        
        UIButton *imageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 21)];
        [imageButton setBackgroundImage:[UIImage lib4allImageNamed:@"back-icon"] forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(backToRootViewController) forControlEvents:UIControlEventAllEvents];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_dataFieldProtocol.title == nil) {
        [self.titleLabel removeFromSuperview];
    } else {
        self.titleLabel.text = _dataFieldProtocol.title;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [_dataTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    
    [_dataTextField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
    }];
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = kBottomConstraintMin;
        [self.view updateConstraints];
    }];
}

// MARK: - Actions

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)continueButtonTouched {
    if (![_dataFieldProtocol isDataValid:_dataTextField.text]) {
        [_dataTextField showFieldWithError:YES];
        return;
    } else {
        [_dataTextField showFieldWithError:NO];
    }
    
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    Services *service = [[Services alloc] init];
    
    service.successCase = ^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingViewController finishLoading:^{
                if ([_flowController isKindOfClass:[CardAdditionFlowController class]]) {
                    if (((CardAdditionFlowController *)_flowController).requiredFields.count > 0) {
                        [((CardAdditionFlowController *)_flowController).requiredFields removeObjectAtIndex:0];
                    }
                }
                
                [_flowController viewControllerDidFinish:self];
            }];
        });
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Fechar" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingViewController finishLoading:^{
                [self presentViewController:alert animated:YES completion:nil];
            }];
        });
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    [service setAccountData:@{_dataFieldProtocol.serverKey: [_dataFieldProtocol serverFormattedData:_dataTextField.text]}];
}

- (IBAction)closeButtonTouched:(id)sender {
    if ([_flowController respondsToSelector:@selector(viewControllerWillClose:)]) {
        [_flowController viewControllerWillClose:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backToRootViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// MARK : Layout

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    if (_flowController.onLoginOrAccountCreation) {
        // Configura navigation bar
        self.navigationItem.title = kNavigationTitle;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    }
    
    // Configura view
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.dataTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.dataTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.dataTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.dataTextField setBottomBorderWithColor:layout.lightGray];
    self.dataTextField.clearButtonMode = UITextFieldViewModeNever;
    
    self.dataTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.dataTextField.textColor = layout.darkFontColor;
    [self.dataTextField setPlaceholder:_dataFieldProtocol.textFieldPlaceHolder];
    self.dataTextField.keyboardType = _dataFieldProtocol.keyboardType;
    self.dataTextField.delegate = _dataFieldProtocol;
    
    if (_dataFieldProtocol.title == nil) {
        [self.titleLabel removeFromSuperview];
    } else {
        self.titleLabel.text = _dataFieldProtocol.title;
    }
    
    self.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.titleLabel.textColor = layout.lightFontColor;
    

    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
}

@end
