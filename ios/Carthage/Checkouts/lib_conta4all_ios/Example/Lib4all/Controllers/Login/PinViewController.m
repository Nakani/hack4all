//
//  PinViewController.m
//  Example
//
//  Created by Cristiano Matte on 30/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "PinViewController.h"
#import "PinConfirmationViewController.h"
#import "LayoutManager.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "GenericDataViewController.h"
#import "UIView+Gradient.h"
#import "User.h"
#import "UIImage+Color.h"
#import "MainActionButton.h"

@interface PinViewController () < UITextFieldDelegate, UIGestureRecognizerDelegate >

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *pinTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet MainActionButton *mainButton;

@end

@implementation PinViewController

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
    
    [self removeTokenView];
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


- (void) removeTokenView {
    //Remove a tela de SMS da pilha, caso usuario clique em voltar, não retorna para ela
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    
    //Validando o protocol, evita-se que sejam removidas outras controllers novamente caso avance e volte
    
    NSInteger currentIndex = [viewControllers indexOfObject:self];
    if ([[viewControllers objectAtIndex:currentIndex-1] isKindOfClass: [GenericDataViewController class]]) {
        GenericDataViewController *previousController = [viewControllers objectAtIndex:currentIndex-1];
        [viewControllers removeObject:previousController];
        self.navigationController.viewControllers = viewControllers;
    }
}
// MARK: - Actions

- (IBAction)continueButtonTouched {
    if (![self isPinValid:_pinTextField.text]) {
        [_pinTextField showFieldWithError:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:@"Para criar uma senha forte utilize números e letras, ela deve ter mais de 6 caracteres e não pode ser igual aos seus dados pessoais."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else {
        [_pinTextField showFieldWithError:NO];
    }
    
    _signFlowController.enteredPassword = self.pinTextField.text;
    [self performSegueWithIdentifier:@"segueConfirmPIN" sender:nil];
}

- (void)closeButtonTouched {
    if ([_signFlowController respondsToSelector:@selector(viewControllerWillClose:)]) {
        [_signFlowController viewControllerWillClose:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)isPinValid:(NSString *)pin {
    if (pin.length < 6) {
        return NO;
    }
    /*
    if ([pin rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location == NSNotFound) {
        return NO;
    }
    if ([pin rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
        return NO;
    }
    if ([pin rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789012"]].location == NSNotFound) {
        return NO;
    }
    */
    int validationLength = 4;
    
    for (int i = 0; i <= pin.length - validationLength; i++) {
        NSString *passwordSubstring = [pin substringWithRange:NSMakeRange(i, validationLength)];
        
        if ([@"0123456789012" containsString:passwordSubstring]) {
            return NO;
        }
        if ([@"9876543210987" containsString:passwordSubstring]) {
            return NO;
        }
        for (int j = 0; j <= 9; j++ ) {
            NSString *repetitionString = [NSString stringWithFormat:@"%d%d%d%d", j, j, j, j];
            if ([repetitionString containsString:passwordSubstring]) {
                return NO;
            }
        }
        
        NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzabc";
        NSString *reversedAlphabet = @"zyxwvutsrqponmlkjihgfedcbazyx";
        if ([alphabet containsString:[passwordSubstring lowercaseString]]){
            return NO;
        }
        
        if ([reversedAlphabet containsString:[passwordSubstring lowercaseString]]){
            return NO;
        }
    }

    
    validationLength = 6;
    for (int i = 0; i <= pin.length - validationLength; i++) {
        NSString *passwordSubstring = [pin substringWithRange:NSMakeRange(i, validationLength)];
        NSString *phoneNumber = [_signFlowController.enteredPhoneNumber stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                                                                                  withString:@""
                                                                                                     options:NSRegularExpressionSearch
                                                                                                       range:NSMakeRange(0, _signFlowController.enteredPhoneNumber.length)];
        
        phoneNumber = [phoneNumber substringFromIndex:2];
        
        if ([phoneNumber containsString:passwordSubstring]){
            return NO;
        }
        NSString *cpf = _signFlowController.accountData[@"cpf"];
        if (cpf != nil && ![cpf isEqualToString:@""]) {
            if ([cpf containsString:passwordSubstring]){
                return NO;
            }
        }
    }
    
    NSString *email = [[_signFlowController enteredEmailAddress] componentsSeparatedByString:@"@"][0];
    if ([pin containsString:email]){
        return NO;
    }
    
    return YES;
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueButtonTouched];
    return YES;
}

// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueConfirmPIN"]) {
        PinConfirmationViewController *nextViewController = segue.destinationViewController;
        nextViewController.signFlowController = _signFlowController;
    }
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
    self.titleLabel.text = @"Muito bom, você vai precisar de uma senha para manter sua conta sempre segura.";
    self.titleLabel.numberOfLines = 5;
    self.titleLabel.textColor = layout.lightFontColor;
    
    self.subTitleLabel.font = [layout fontWithSize:layout.regularFontSize];
    self.subTitleLabel.text = @"A senha deve ter no mínimo 6 caracteres.";
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
    [self.pinTextField setPlaceholder:@"Senha"];
    
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
