//
//  TransferConfirmationViewController.m
//  Example
//
//  Created by Luciano Bohrer on 14/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPTransferContactConfirmationViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "NSString+Mask.h"
#import "PasswordModalViewController.h"
#import "PrePaidServices.h"
#import "NSStringMask.h"
#import "Services.h"
#import "PPTransferSuccessViewController.h"
#import "UIFloatLabelTextView.h"
#import "UIFloatLabelTextView+Border.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "User.h"
#import "ForgotPasswordViewController.h"
#import "CpfCnpjUtil.h"
#import "NSString+NumberArray.h"
#import "PPTransferConfirmationViewController.h"
#import "PopUpWithOptionViewController.h"
#import <tgmath.h>
#import "AnalyticsUtil.h"

@interface PPTransferContactConfirmationViewController () <UIGestureRecognizerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *textAmount;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextView *textMessage;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *textCpf;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstLetters;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelID;
@property (weak, nonatomic) IBOutlet UILabel *labelPara;
@property (weak, nonatomic) NSString *transferId;
@property (weak, nonatomic) IBOutlet UIView *labelParaBottomLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMessageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textCpfHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelFirstLettersSizeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelParaBottomLineViewHeightConstraint;
@property CGRect keyboardFrame;
@end

@implementation PPTransferContactConfirmationViewController

static NSString* const kNavigationTitle = @"Transferir";


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupController];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [self dismissKeyboard];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}

- (void)setupController{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    _labelFirstLetters.clipsToBounds = YES;
    _labelFirstLetters.layer.cornerRadius = _labelFirstLetters.frame.size.height/2;
    _labelFirstLetters.layer.borderColor  = [layout primaryColor].CGColor;
    _labelFirstLetters.layer.borderWidth  = 1.0f;
    _labelFirstLetters.textColor          = layout.primaryColor;
    _labelFirstLetters.font               = [layout fontWithSize:layout.subTitleFontSize];
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];

    [_textAmount setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textAmount.floatLabel.font = [layout fontWithSize:[layout miniFontSize]];
    _textAmount.font  = [layout fontWithSize:[layout regularFontSize]];
    _textAmount.floatLabelActiveColor = [layout darkFontColor];
    [_textAmount setBottomBorderWithColor:[layout lightGray]];
    _textAmount.clearButtonMode = UITextFieldViewModeNever;
    
    [_textMessage setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textMessage.floatLabel.font = [layout fontWithSize:[layout miniFontSize]];
    _textMessage.font = [layout fontWithSize:[layout regularFontSize]];
    _textMessage.floatLabelActiveColor = [layout darkFontColor];
    [_textMessage setBottomBorderWithColor:[layout lightGray]];
    _textMessage.placeholder = @"Envie uma mensagem";
    _textMessage.scrollEnabled = NO;
    
    [[self.view viewWithTag:12] setBackgroundColor:[layout lightGray]];
    _labelName.font = [layout boldFontWithSize:layout.regularFontSize];
    _labelID.font = [layout fontWithSize:layout.regularFontSize];
    
    _labelPara.font = [layout fontWithSize:layout.regularFontSize];
    
    if(!_userHasAccount) {
        [_textCpf setTranslatesAutoresizingMaskIntoConstraints:NO];
        _textCpf.floatLabel.font = [layout fontWithSize:[layout miniFontSize]];
        _textCpf.font  = [layout fontWithSize:[layout regularFontSize]];
        _textCpf.floatLabelActiveColor = [layout darkFontColor];
        [_textCpf setBottomBorderWithColor:[layout lightGray]];
        _textCpf.clearButtonMode = UITextFieldViewModeNever;
        _textCpf.keyboardType = UIKeyboardTypeNumberPad;
        _labelFirstLettersSizeConstraint.constant = 0;
    } else {
        [_textCpf setHidden:YES];
        _textCpfHeightConstraint.constant = -8;
        [_labelParaBottomLineView setHidden:YES];
        _labelParaBottomLineViewHeightConstraint.constant = -7;
    }
    
    //Action to dismiss keyboard
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    _labelID.text   = [self getFormattedPhoneNumber];
    
    if (![_name isEqualToString:@""]) {
        _labelName.text = _name;
        _name = [_name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSArray<NSString *> *firstLetters = [_name componentsSeparatedByString:@" "];
        
        if (firstLetters.count >= 2) {
            _labelFirstLetters.text = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0],[firstLetters[firstLetters.count-1] characterAtIndex:0]];
        }else{
            if (firstLetters[0].length > 1) {
                _labelFirstLetters.text = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0],[firstLetters[0] characterAtIndex:1]];
            } else {
                _labelFirstLetters.text = [NSString stringWithFormat:@"%c",[firstLetters[0] characterAtIndex:0]];
            }
        }
    } else {
        _labelFirstLetters.text = @"";
        _labelName.text = @"";
    }
    
    _textMessage.delegate = self;
}

-(NSString *)getAmount:(NSMutableString *)text appendString:(NSString *)string{
    
    NSString *newString = [[[text stringByReplacingOccurrencesOfString:@"R$" withString:@""]
                            stringByReplacingOccurrencesOfString:@"," withString:@""]
                           stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    newString = [newString stringByAppendingString:string];
    
    
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:newString];
    
    [f setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    [f setLocale:locale];
    NSString *output = [f stringFromNumber:[NSNumber numberWithDouble:(myNumber.doubleValue/100)]];
    
    return output;
}   

-(NSString *)getFormattedCpf {
    NSString *cpfArray = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.textCpf.text];
    return cpfArray;
}

-(NSString *)getFormattedPhoneNumber{
    //Format phone number
    
    NSString *phoneNumber = [NSStringMask maskString:[_rawId substringFromIndex:2] withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    if (phoneNumber != nil) {
        
        phoneNumber = [@"+55" stringByAppendingString:phoneNumber];
        return phoneNumber;
    }else{
        return _rawId;
    }
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)transferAction:(id)sender {
    
    if(!_userHasAccount && ![CpfCnpjUtil isValidCpfNumber:[[self getFormattedCpf] toNumberArray]]) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        [alert show:self title:@"Atenção" description:@"Por favor, digite um cpf válido." imageMode:Error buttonAction:nil];
    } else if ([_textAmount.text isEqualToString:@""] || [_textAmount isEqual:@"R$0,00"]) {
            PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
            
            [alert show:self title:@"Atenção" description:@"Por favor, digite um valor a ser transferido." imageMode:Error buttonAction:nil];
    } else {
        
        NSString *rawMoney = [[[_textAmount.text stringByReplacingOccurrencesOfString:@"R$" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@"."];
        double amount = [rawMoney doubleValue];
        
        void (^transferBlock)(void) = ^{
            
            [AnalyticsUtil logEventWithName:@"definicao_valor" andParameters:nil];
            
            PPTransferConfirmationViewController *destinationViewController = [[UIStoryboard storyboardWithName:@"PrePaid" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"PPTransferConfirmationViewController"];
            destinationViewController.userHasAccount = _userHasAccount;
            destinationViewController.name = _name;
            destinationViewController.cpf = [self getFormattedCpf];
            destinationViewController.phoneNumber = _rawId;
            if(![self.textMessage.text isEqualToString:self.textMessage.placeholder]) {
                destinationViewController.descriptionMessage = self.textMessage.text;
            }
            
            destinationViewController.amount = amount;
            [self.navigationController pushViewController:destinationViewController animated:YES];
        };
        
        
        if(fmod(amount, 10) > 0) {
            //Se nao for multiplo de 10
            PopUpWithOptionViewController *popUpWithOptionViewController = [[PopUpWithOptionViewController alloc] init];
            
            NSString *titleText = [NSString stringWithFormat:@"%@,", [[User sharedUser].fullName componentsSeparatedByString:@" "][0]];
            NSString *descriptionText = @"A pessoa que receberá o dinheiro poderá sacar somente múltiplos de R$ 10,00 nos caixas eletrônicos.";
            NSString *firstOptionButtonTitle = @"Ajustar o valor";
            NSString *secondOptionButtonTitle = [NSString stringWithFormat:@"Enviar %@", _textAmount.text];
            
            popUpWithOptionViewController.secondOptionBlock = ^{
                transferBlock();
            };
            
            [popUpWithOptionViewController show:self title:titleText description:descriptionText firstButtonTitle:firstOptionButtonTitle secondButtonTitle:secondOptionButtonTitle];
        } else {
            transferBlock();
        }
    }
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _textAmount) {
        
    
        if ([string isEqualToString:@""] && textField.text.length > 0) {
            textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
            NSString *finalText = [textField.text substringToIndex:textField.text.length-1];
            finalText = [self getAmount:[finalText mutableCopy] appendString:@""];
            
            if ([finalText isEqualToString:@"R$0,00"]) {
                finalText = @"";
            }
            
            textField.text = finalText;
            return NO;
        }

        
        NSString *finalString = [self getAmount:[textField.text mutableCopy] appendString:string];
        
        
        if ([textField.text isEqualToString:@"R$"] || [finalString isEqualToString:@"R$0,00"]) {
            textField.text = @"";
        }else{
            textField.text = finalString;
        }
        return NO;
    }
    
    if (textField == _textCpf) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Permite backspace apenas com cursor no último caractere
        if (range.length == 1 && string.length == 0 && range.location != newString.length) {
            textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
            return NO;
        }
        
        newString = [CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:newString];
        
        if (newString.length <= 11) {
            textField.text = [newString stringByApplyingMask:@"###.###.###-##" maskCharacter:'#'];
        }
        
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
    _constraintMessageTextField.constant = sizeThatShouldFitTheContent.height;
    [_textMessage setBottomBorderWithColor:[[LayoutManager sharedManager] lightGray]];
    [_textMessage layoutIfNeeded];

    [self scrollToCursorPositionUnderKeyboard];

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)textFieldShouldReturn:(id)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}


// Called when the UIKeyboardDidShowNotification is received
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    // keyboard frame is in window coordinates
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // get the height of the keyboard by taking into account the orientation of the device too
    CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
    CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
    _keyboardFrame = keyboardFrame;

    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 2 +  keyboardInfoFrame.size.height;
        [self.view updateConstraints];
    }];
    
}

-(void)scrollToCursorPositionUnderKeyboard{
    CGRect caret = [_textMessage caretRectForPosition:_textMessage.selectedTextRange.end];
    CGFloat keyboardTopBorder = _textMessage.bounds.size.height - _keyboardFrame.size.height;
    
    
    if (caret.origin.y < (keyboardTopBorder - 60)) {
        CGRect newCarret = CGRectMake(caret.origin.x, caret.origin.y, caret.size.width, caret.size.height + 60);
        [_scrollView scrollRectToVisible:newCarret animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardDidHide:(NSNotification *)aNotification
{
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 22;
        [self.view updateConstraints];
    }];
}

@end
