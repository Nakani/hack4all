//
//  PPCreatePaymentSlipViewController.m
//  Example
//
//  Created by Adriano Soares on 27/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPCreatePaymentSlipViewController.h"
#import "PPPaymentSlipConfirmationViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "AnalyticsUtil.h"
#import "CurrencyUtil.h"
#import "PrePaidServices.h"
#import "Lib4allPreferences.h"

@interface PPCreatePaymentSlipViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *selectValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *button20;
@property (weak, nonatomic) IBOutlet UIButton *button50;
@property (weak, nonatomic) IBOutlet UIButton *button100;
@property (weak, nonatomic) IBOutlet UIButton *button150;
@property (weak, nonatomic) IBOutlet UIButton *button200;
@property (weak, nonatomic) IBOutlet UIButton *button250;

@property (weak, nonatomic) IBOutlet UILabel *feeLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeDescriptionLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property BOOL isButtonSelected;
@property NSInteger buttonSelected;
@property NSArray *buttonArray;


@end

@implementation PPCreatePaymentSlipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.valueField.keyboardType = UIKeyboardTypeNumberPad;
    self.valueField.delegate     = self;
    
    self.isButtonSelected = NO;
    self.buttonSelected = 0;
    self.buttonArray = @[_button20, _button50, _button100, _button150, _button200, _button250];
    
    for (int i = 0; i < self.buttonArray.count; i++ ) {
        UIButton *button = self.buttonArray[i];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button addTarget:self action:@selector(selectValue:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.bottomConstraint.constant = 22.0;
    
    [self configureLayout];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fee > 0) {
        self.feeDescriptionLabel.text = [self.feeDescriptionLabel.text stringByReplacingOccurrencesOfString:@"<fee>" withString:[CurrencyUtil currencyFormatter:_fee]];
    } else {
        LoadingViewController *loading = [[LoadingViewController alloc] init];
        
        [loading startLoading:self title:@"Aguarde..." completion:^{
            PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
            PrePaidServices *client = [[PrePaidServices alloc] init];
            
            client.successCase = ^(id data) {
                [loading finishLoading:^{
                    self.fee = [[data objectForKey:@"paymentSlipPaymentCashInFee"] doubleValue];
                    self.dueDays = [[data objectForKey:@"paymentSlipPaymentCashInDueDateDays"] doubleValue];
                    self.feeDescriptionLabel.text = [self.feeDescriptionLabel.text stringByReplacingOccurrencesOfString:@"<fee>" withString:[CurrencyUtil currencyFormatter:_fee]];
                }];
                
            };
            
            client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
                [loading finishLoading:^{
                    NSString *msg = @"Erro ao carregar as informações! Verifique sua conexão.";
                    [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:^{
                        if ([_parentVC.navigationController.viewControllers count] == 1) {
                            [_parentVC dismissViewControllerAnimated:YES completion:nil];
                        } else {
                            [_parentVC.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                }];
            };
            
            [client balance];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.bottomConstraint.constant = 22.0;
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [[newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (newString.length > 0 && [newString doubleValue] > 0) {
        textField.text = [CurrencyUtil currencyFormatter:[newString doubleValue]];
        if (self.isButtonSelected) {
            self.isButtonSelected = NO;
            [self renderButtons];
        }
    } else {
        textField.text = @"";
    }
    return NO;
}


- (void) selectValue:(UIButton *)sender {
    for (int i = 0; i < self.buttonArray.count; i++ ) {
        UIButton *button = self.buttonArray[i];
        if (button == sender) {
            self.isButtonSelected = YES;
            self.buttonSelected   = i;
        }
    }
    self.valueField.text = nil;
    [self dismissKeyboard];
    [self renderButtons];
}

- (BOOL) isValid {
    double value = [CurrencyUtil currencyToDouble:self.valueField.text];
    if (self.isButtonSelected || value > 0) {
        return YES;
    }
    return NO;
}

- (IBAction)createPaymentSlip:(id)sender {
    if ([self isValid]) {
        PPPaymentSlipConfirmationViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPPaymentSlipConfirmationViewController"];
        destination.fee = self.fee;
        destination.dueDays = self.dueDays;
        if (_isButtonSelected) {
            [AnalyticsUtil logEventWithName:@"cashIn_boleto_valor_pre_definido" andParameters:nil];
            
            NSArray *values = @[@2000, @5000, @10000, @15000, @20000, @25000];
            destination.total = [values[self.buttonSelected] doubleValue] ;
        } else {
            [AnalyticsUtil logEventWithName:@"cashIn_boleto_digitacao_valor" andParameters:nil];
    
            if(([CurrencyUtil currencyToDouble:self.valueField.text]/100) < 5) {
                PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                [alert show:self title:@"Atenção" description:@"O valor do boleto deve ser maior que R$ 5,00" imageMode:Error buttonAction:nil];
                return;
            }
            destination.total = [CurrencyUtil currencyToDouble:self.valueField.text];
        }
        [self.navigationController pushViewController:destination animated:YES];
    }
}

- (void) renderButtons {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layout backgroundColor];
    
    for (int i = 0; i < self.buttonArray.count; i++ ) {
        UIButton *button = self.buttonArray[i];
        if (self.isButtonSelected && i == self.buttonSelected) {
            button.backgroundColor = layout.secondaryColor;
            [button setTitleColor:layout.lightFontColor forState:UIControlStateNormal];
        } else {
            button.backgroundColor = [layout darkBackgroundColor];
            [button setTitleColor:[layout darkerGray] forState:UIControlStateNormal];
        }
    }
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    NSArray *regularLabels = @[_titleLabel, _selectValueLabel];
    for (int i = 0; i < regularLabels.count; i++ ) {
        UILabel *label = regularLabels[i];
        label.font = [layout fontWithSize:layout.regularFontSize];
        label.textColor = [layout darkFontColor];
    }
    
    [self.titleLabel setText:[NSString stringWithFormat:@"Você pode recarregar a sua Carteira %@ através do pagamento de um boleto bancário", [Lib4allPreferences sharedInstance].balanceTypeFriendlyName]];
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    
    [self.valueField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.valueField.floatLabelFont = [layout fontWithSize:[layout miniFontSize]];
    self.valueField.font = [layout fontWithSize:[layout regularFontSize]];
    self.valueField.textColor = [layout darkFontColor];
    self.valueField.floatLabelActiveColor = [layout darkFontColor];
    [self.valueField setBottomBorderWithColor:[layout lightGray]];
    self.valueField.clearButtonMode = UITextFieldViewModeNever;
    self.valueField.horizontalPadding = 0;
    
    for (int i = 0; i < self.buttonArray.count; i++ ) {
        UIButton *button = self.buttonArray[i];
        button.layer.cornerRadius = 8.0;
        button.titleLabel.font = [layout boldFontWithSize:layout.titleFontSize];
        
    }
    [self renderButtons];
    
    self.feeLabel.font = [layout boldFontWithSize:layout.midFontSize];
    self.feeLabel.textColor = [layout darkFontColor];

    self.feeDescriptionLabel.font = [layout fontWithSize:layout.midFontSize];
    self.feeDescriptionLabel.textColor = [layout darkFontColor];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 22.0;
        
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
    
}

@end
