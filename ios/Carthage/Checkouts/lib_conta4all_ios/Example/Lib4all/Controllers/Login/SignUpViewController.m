//
//  SignUpViewController.m
//  Lib4all
//
//  Created by 4all on 3/30/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SignUpViewController.h"
#import "UITextFieldMask.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"
#import "ErrorTextField.h"
#import "LayoutManager.h"
#import "BEMCheckBox.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "CpfCnpjUtil.h"
#import "DateUtil.h"
#import "Lib4allPreferences.h"
#import "PinViewController.h"
#import "UIImage+Color.h"
#import "NSStringMask.h"
#import "Lib4all.h"

@interface SignUpViewController () < UIActionSheetDelegate, UITextFieldDelegate >

@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterDataLabel;
@property (weak, nonatomic) IBOutlet ErrorTextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet ErrorTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet ErrorTextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet ErrorTextField *cpfOrCnpjTextField;
@property (weak, nonatomic) IBOutlet ErrorTextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkbox;
@property (weak, nonatomic) IBOutlet UIView *termsAndConditionView;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionButton;

@property (strong, nonatomic) LoadingViewController *loadingView;
@property int currentTextFieldTag;

@end

@implementation SignUpViewController

- (id)init {
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]];
    self = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];

    return self;
}

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];

    NSDictionary *customerData = [Lib4all customerData];
    if (_signFlowController.enteredPhoneNumber != nil && ![_signFlowController.enteredPhoneNumber isEqualToString:@""]) {
        self.phoneNumberTextField.text = (NSString *)[NSStringMask maskString:_signFlowController.enteredPhoneNumber
                                                      withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
        self.phoneNumberTextField.userInteractionEnabled = NO;
        
        if (customerData[@"emailAddress"] != nil) {
            NSString *data = customerData[@"emailAddress"];
            _emailAddressTextField.text = data;
        }
    }
    
    if (_signFlowController.enteredEmailAddress != nil && ![_signFlowController.enteredEmailAddress isEqualToString:@""]) {
        self.emailAddressTextField.text = _signFlowController.enteredEmailAddress;
        self.emailAddressTextField.userInteractionEnabled = NO;
        
        if (customerData[@"phoneNumber"] != nil) {
            NSString *data = customerData[@"phoneNumber"];
            self.phoneNumberTextField.text = (NSString *)[NSStringMask maskString:data
                                                                      withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
        }

    }
    
    if (customerData[@"fullName"] != nil) {
        NSString *data = customerData[@"fullName"];
        self.fullNameTextField.text = data;
    }

    if (customerData[@"birthdate"] != nil) {
        NSString *data = customerData[@"birthdate"];
        self.birthdateTextField.text = [data stringByApplyingMask:@"##/##/####" maskCharacter:'#'];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    
}

// MARK: - Actions

- (IBAction)signUpButtonTouched {
    NSArray *cpfOrCnpj = [[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.cpfOrCnpjTextField.text] toNumberArray];
    
    BOOL phoneValid = [self.phoneNumberTextField checkIfContentIsValid:YES];
    BOOL emailValid = [self.emailAddressTextField checkIfContentIsValid:YES];
    BOOL fullNameValid = [self.fullNameTextField checkIfContentIsValid:YES];
    if (fullNameValid && [self.fullNameTextField.text componentsSeparatedByString:@" "].count < 2) {
        [self.fullNameTextField showFieldWithError:NO];
        fullNameValid = NO;
    }
    BOOL cpfOrCnpjValid = ![Lib4allPreferences sharedInstance].requireCpfOrCnpj || [CpfCnpjUtil isValidCpfOrCnpj:cpfOrCnpj];
    BOOL birthdateValid = YES;
    //    BOOL birthdateValid = [self.birthdateTextField checkIfContentIsValid:YES];
//    if (birthdateValid && ![DateUtil isValidBirthdateString:self.birthdateTextField.text]) {
//        [self.birthdateTextField showFieldWithError:NO];
//        birthdateValid = NO;
//    }
    if (phoneValid && emailValid && fullNameValid && cpfOrCnpjValid && birthdateValid) {
        // Verifica se o usuário concordou com os termos de uso e política de privacidade
        if (!self.checkbox.on) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                            message:@"Para continuar, você deve aceitar os termos e condições de uso."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            if ([self.loadingView isLoading]) {
                [self.loadingView finishLoading:^{
                    [alert show];
                }];
            } else {
                [alert show];
            }
            return;
        }
        
        [self callCreation];
    }
}

- (IBAction)showTermsOfService {
    [[UIApplication sharedApplication] openURL:[[Lib4allPreferences sharedInstance] termsOfServiceURL]];
}

// MARK: - Keyboard handling

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    // viewHighestY calcula a posição Y do bottom da view mais abaixo da tela
    CGFloat viewHighestY = self.scrollView.subviews[0].frame.origin.y + self.scrollView.subviews[0].frame.size.height + 44;
    CGFloat keyboardOriginY = (self.view.frame.size.height - self.view.frame.origin.y) - kbRect.size.height;
    
    // Se o teclado esconde alguma parte da view, adiciona scroll
    if (viewHighestY > keyboardOriginY) {
        // Adiciona inset to tamanho que o teclado está escondendo
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.bottom = kbRect.size.height;
        self.scrollView.contentInset = contentInset;
        self.scrollView.scrollIndicatorInsets = contentInset;
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)nextTextField:(UIBarButtonItem *)sender {
    _currentTextFieldTag++;
    
    if (_currentTextFieldTag == 2 && ![Lib4allPreferences sharedInstance].requireCpfOrCnpj) {
        _currentTextFieldTag++;
    }
    
    // Try to find next responder
    UIResponder *nextResponder = (UIResponder *)[self.view viewWithTag:_currentTextFieldTag];
    
    if (nextResponder != nil){
        [nextResponder becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
}

- (void)previousTextField:(UIBarButtonItem *)sender{
    if(_currentTextFieldTag > 1){
        _currentTextFieldTag--;
    }
    
    if (_currentTextFieldTag == 2 && ![Lib4allPreferences sharedInstance].requireCpfOrCnpj) {
        _currentTextFieldTag--;
    }
    
    // Try to find next responder
    UIResponder *nextResponder = (UIResponder *)[self.view viewWithTag:_currentTextFieldTag];
    
    if (nextResponder != nil){
        [nextResponder becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneNumberTextField) {
        NSString *cleanNumber = [[[[textField.text stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                  stringByReplacingOccurrencesOfString:@")" withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([string isEqualToString:@""] && range.location != 0) {
            textField.text = (NSString *)[NSStringMask maskString:cleanNumber withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
            return YES;
        }
        
        if (cleanNumber.length < 11) {
            textField.text = (NSString *)[NSStringMask maskString:cleanNumber withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
            return YES;
        } else {
            return NO;
        }
    } else if (textField == self.cpfOrCnpjTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Permite backspace apenas com cursor no último caractere
        if (range.length == 1 && string.length == 0 && range.location != newString.length) {
            textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
            return NO;
        }
        
        newString = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:newString];
        
        if (newString.length <= 11) {
            textField.text = [newString stringByApplyingMask:@"###.###.###-##" maskCharacter:'#'];
        } else {
            textField.text = [newString stringByApplyingMask:@"##.###.###/####-##" maskCharacter:'#'];
        }
        
        return NO;
    } else if (textField == self.birthdateTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Permite backspace apenas com cursor no último caractere
        if (range.length == 1 && string.length == 0 && range.location != newString.length) {
            textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
            return NO;
        }
        
        newString = [newString stringByReplacingOccurrencesOfString:@"/" withString:@"" ];
        textField.text = [newString stringByApplyingMask:@"##/##/####" maskCharacter:'#'];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentTextFieldTag = textField.tag;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.fullNameTextField) {
        [self.phoneNumberTextField becomeFirstResponder];
    } else if (textField == self.phoneNumberTextField) {
        [self.emailAddressTextField becomeFirstResponder];
    } else if (textField == self.emailAddressTextField && [Lib4allPreferences sharedInstance].requireCpfOrCnpj) {
        [self.cpfOrCnpjTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.cpfOrCnpjTextField) {
        NSArray *cpfOrCnpj = [[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.cpfOrCnpjTextField.text] toNumberArray];
        BOOL fieldValid = [CpfCnpjUtil isValidCpfOrCnpj:cpfOrCnpj];
        
        [self.cpfOrCnpjTextField showFieldWithError:fieldValid];
    } else if (textField == self.fullNameTextField) {
        [(ErrorTextField*)textField checkIfContentIsValid:YES];
        
        if ([self.fullNameTextField.text componentsSeparatedByString:@" "].count < 2) {
            [(ErrorTextField*)textField showFieldWithError:NO];
        }
    } else if (textField == self.birthdateTextField){
        [(ErrorTextField*)textField checkIfContentIsValid:NO];
    }else {
        [(ErrorTextField*)textField checkIfContentIsValid:YES];
    }
}

// MARK: - Services calls

- (void)callCreation {
    NSString *cleanNumber = [self.phoneNumberTextField.text stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                                                                      withString:@""
                                                                                         options:NSRegularExpressionSearch
                                                                                           range:NSMakeRange(0, self.phoneNumberTextField.text.length)];
    cleanNumber = [cleanNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleanNumber = [NSString stringWithFormat:@"55%@", cleanNumber];
    
    Services *creation = [[Services alloc] init];
    
    creation.failureCase = ^(NSString *cod, NSString *msg){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"Fechar"
                                              otherButtonTitles:nil];
        [self.loadingView finishLoading:^{
            [alert show];
        }];
    };
    
    creation.successCase = ^(NSDictionary *response){
        [self.loadingView finishLoading:^{
            _signFlowController.enteredPhoneNumber = self.phoneNumberTextField.text;
            _signFlowController.enteredEmailAddress = self.emailAddressTextField.text;
            
            NSMutableDictionary *accountData = [[NSMutableDictionary alloc] init];
            [accountData setObject:self.fullNameTextField.text forKey:FullNameKey];
            if (self.birthdateTextField.text != nil && [self.birthdateTextField hasText]) {
                [accountData setObject:[DateUtil convertDateString:self.birthdateTextField.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"] forKey:BirthdateKey];
            }
            
            if ([Lib4allPreferences sharedInstance].requireCpfOrCnpj) {
                accountData[CPFKey] = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.cpfOrCnpjTextField.text];
            }
            
            _signFlowController.accountData = accountData;
            
            [_signFlowController viewControllerDidFinish:self];
        }];
    };
    
    if (!self.loadingView.isLoading) {
        [self.loadingView startLoading:self title:@"Aguarde..."];
    }
    
    [creation startCustomerCreationWithPhoneNumber:cleanNumber emailAddress:self.emailAddressTextField.text];
}

// MARK: - Layout configuration

- (void)configureLayout {
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgTitle.image = [UIImage lib4allImageNamed:@"4allwhite"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imgTitle;
    
    self.greetingLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.greetingLabel.textColor = [layoutManager darkFontColor];
    
    self.enterDataLabel.font = [layoutManager fontWithSize:[layoutManager subTitleFontSize]];
    self.enterDataLabel.textColor = [layoutManager darkFontColor];
    
    // Configura toolbar do teclado
    UIToolbar *keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    keyboardToolBar.barStyle    = UIBarStyleDefault;
    keyboardToolBar.tintColor   = [UIColor grayColor];
    
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"left-nav-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(previousTextField:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"right-nav-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(nextTextField:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage lib4allImageNamed:@"close"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSArray<UIBarButtonItem *> *items = [[NSArray alloc] initWithObjects:previousButton,nextButton,flexSpace,doneButton, nil];
    [keyboardToolBar setItems:items];
    
    // Adiciona toolbar ao teclado dos campos
    self.fullNameTextField.tag = 1;
    self.cpfOrCnpjTextField.tag = 2;
    self.phoneNumberTextField.tag = 3;
    self.emailAddressTextField.tag = 4;
    self.birthdateTextField.tag = 5;
    self.fullNameTextField.inputAccessoryView = keyboardToolBar;
    self.cpfOrCnpjTextField.inputAccessoryView = keyboardToolBar;
    self.phoneNumberTextField.inputAccessoryView = keyboardToolBar;
    self.emailAddressTextField.inputAccessoryView = keyboardToolBar;
    self.birthdateTextField.inputAccessoryView = keyboardToolBar;
    
    self.phoneNumberTextField.regex = @"^\\d{11}$";
    self.emailAddressTextField.regex = @"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$";
    self.fullNameTextField.regex = @"^\\p{L}+$";
    self.birthdateTextField.regex = @"^[0-9]{2}/[0-9]{2}/[0-9]{4}$";
    [self.fullNameTextField roundTopCornersRadius:5];
    [self.fullNameTextField setBorder:[layoutManager lightGray] width:1];
    [self.fullNameTextField setFont:[layoutManager fontWithSize:[LayoutManager sharedManager].regularFontSize]];
    [self.fullNameTextField setIconsImages:[UIImage lib4allImageNamed:@"iconFullName"]
                                  errorImg:[[UIImage lib4allImageNamed:@"iconFullName"] withColor:[layoutManager red]]];
    self.fullNameTextField.textColor = [layoutManager darkFontColor];
    self.fullNameTextField.placeholder = @"Nome completo";
    
    [self.phoneNumberTextField setBorder:[layoutManager lightGray] width:1];
    [self.phoneNumberTextField setFont:[layoutManager fontWithSize:[LayoutManager sharedManager].regularFontSize]];
    [self.phoneNumberTextField setIconsImages:[UIImage lib4allImageNamed:@"iconMobi"]
                                     errorImg:[[UIImage lib4allImageNamed:@"iconMobi"] withColor:[layoutManager red]]];
    self.phoneNumberTextField.textColor = [layoutManager darkFontColor];
    self.phoneNumberTextField.placeholder = @"(00) 00000 0000";
    
    [self.emailAddressTextField setBorder:[layoutManager lightGray] width:1];
    [self.emailAddressTextField setFont:[layoutManager fontWithSize:[LayoutManager sharedManager].regularFontSize]];
    [self.emailAddressTextField setIconsImages:[UIImage lib4allImageNamed:@"iconMail"]
                                      errorImg:[[UIImage lib4allImageNamed:@"iconMail"] withColor:[layoutManager red]]];
    self.emailAddressTextField.textColor = [layoutManager darkFontColor];
    self.emailAddressTextField.placeholder = @"email@email.com";
    
    [self.birthdateTextField roundBottomCornersRadius:5.0];
    [self.birthdateTextField setBorder:[layoutManager lightGray] width:1];
    [self.birthdateTextField setFont:[layoutManager fontWithSize:[LayoutManager sharedManager].regularFontSize]];
    [self.birthdateTextField setIconsImages:[UIImage lib4allImageNamed:@"iconStar"]
                                   errorImg:[[UIImage lib4allImageNamed:@"iconStar"] withColor:[layoutManager red]]];
    self.birthdateTextField.textColor = [layoutManager darkFontColor];
    self.birthdateTextField.placeholder = @"Data de nascimento";
        
    if ([Lib4allPreferences sharedInstance].requireCpfOrCnpj) {
        [self.cpfOrCnpjTextField setBorder:[layoutManager lightGray] width:1];
        [self.cpfOrCnpjTextField setFont:[layoutManager fontWithSize:[LayoutManager sharedManager].regularFontSize]];
        [self.cpfOrCnpjTextField setIconsImages:[UIImage lib4allImageNamed:@"iconCpf"]
                                       errorImg:[[UIImage lib4allImageNamed:@"iconCpf"] withColor:[layoutManager red]]];
        self.cpfOrCnpjTextField.textColor = [layoutManager darkFontColor];
        self.cpfOrCnpjTextField.placeholder = @"CPF ou CNPJ";
    } else {
        [self.cpfOrCnpjTextField removeFromSuperview];
    }
    
    // Configura label e botão dos termos e condições
    self.termsAndConditionsLabel.font = [layoutManager fontWithSize:[LayoutManager sharedManager].midFontSize];
    self.termsAndConditionsLabel.textColor = [layoutManager darkFontColor];
    self.termsAndConditionButton.titleLabel.font = [layoutManager fontWithSize:[LayoutManager sharedManager].midFontSize];
    
    [self.termsAndConditionButton setTitleColor:[layoutManager primaryColor] forState:UIControlStateNormal];
    [self.termsAndConditionButton setTitleColor:[layoutManager gradientColor] forState:UIControlStateSelected];
    [self.termsAndConditionButton setTitleColor:[layoutManager gradientColor] forState:UIControlStateHighlighted];
    
    self.loadingView = [[LoadingViewController alloc] init];
    
    self.checkbox.onAnimationType = BEMAnimationTypeFade;
    self.checkbox.offAnimationType = BEMAnimationTypeFade;
}

@end
