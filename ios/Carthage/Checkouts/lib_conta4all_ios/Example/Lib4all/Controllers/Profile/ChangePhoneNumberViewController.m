//
//  ChangePhoneNumberViewController.m
//  Example
//
//  Created by Cristiano Matte on 01/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ChangePhoneNumberViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "AnalyticsUtil.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "NSStringMask.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LoadingViewController.h"
#import "User.h"
#import "UIImage+Color.h"

@interface ChangePhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIView *challengeView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *challengeTextField;
@property (weak, nonatomic) IBOutlet UILabel *challengeNotReceivedLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendChallengeButton;
@property (strong, nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSString* phoneChangeToken;

@end

@implementation ChangePhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.phoneNumberTextField.delegate = self;
    self.challengeTextField.delegate = self;
    
    [self configureLayout];
}

#pragma mark - Actions
- (IBAction)sendChallengeAgain {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
        
        self.resendChallengeButton.enabled = YES;
    };
    
    service.successCase = ^(NSDictionary *response) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        [alert show:self title:@"Atenção!" description:@"Código reenviado por SMS!" imageMode:Success buttonAction:nil];

        self.resendChallengeButton.enabled = YES;
    };
    
    self.resendChallengeButton.enabled = NO;
    [service resendSMSChallengeForPhoneChangeToken:self.phoneChangeToken];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)isPhoneValid {
    NSString *cleanText = [self getCleanPhoneNumberFromFormattedPhoneNumber: self.phoneNumberTextField.text];
    NSString *regex = @"^\\d{11}$";
    if([cleanText length]==0) {
        return NO;
    }else{
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:cleanText options:0 range:NSMakeRange(0, [cleanText length])];
        
        if (regExMatches == 0) {
           return NO;
        } else {
           return YES;
        }
    }
    
}

- (void)saveButtonTouched {
    [self.view endEditing:YES];
    [self.phoneNumberTextField showFieldWithError:NO];
    if ([self isPhoneValid]) {
        NSString *cleanPhoneNumber = [NSString stringWithFormat:@"%@%@", @"55", [self getCleanPhoneNumberFromFormattedPhoneNumber:self.phoneNumberTextField.text]];
        
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg) {
            PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
            [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
            
            self.phoneNumberTextField.userInteractionEnabled = YES;
            self.saveButton.enabled = YES;
        };
        
        service.successCase = ^(NSDictionary *response) {
            self.phoneChangeToken = response[PhoneChangeTokenKey];
            
            [AnalyticsUtil logEventWithName:@"confirmacao_edicao_telefone_usuario" andParameters:nil];
            
            self.navigationItem.rightBarButtonItem = nil;
            
            // Formata o número de telefone para exibir na label
            NSString *formattedPhone = [self getCleanPhoneNumberFromFormattedPhoneNumber:self.phoneNumberTextField.text];
            formattedPhone = (NSString *)[NSStringMask maskString:formattedPhone withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
            
            NSString *maskedPhone;
            maskedPhone = [formattedPhone substringToIndex:4];
            maskedPhone = [maskedPhone stringByAppendingString:@"******"];
            maskedPhone = [maskedPhone stringByAppendingString:[formattedPhone substringWithRange:NSMakeRange(formattedPhone.length-2, 2)]];
            
            self.phoneNumberLabel.text = [self.phoneNumberLabel.text stringByReplacingOccurrencesOfString:@"<phone>"
                                                                                               withString:maskedPhone];
            
            // Exibe a view do challenge
            [UIView transitionWithView:self.challengeView
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{ self.challengeView.hidden = NO; }
                            completion:NULL];
        };
        
        self.saveButton.enabled = NO;
        self.phoneNumberTextField.userInteractionEnabled = NO;
        [service setPhoneNumber:cleanPhoneNumber];
    } else {
        [self.phoneNumberTextField showFieldWithError:YES];
    }
}

- (void)checkChallenge:(NSString *)challenge {
    NSString *cleanPhoneNumber = [NSString stringWithFormat:@"%@%@", @"55", [self getCleanPhoneNumberFromFormattedPhoneNumber:self.phoneNumberTextField.text]];
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    [loading startLoading:self title:@"Aguarde..."];
    
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        
        [loading finishLoading:^{
            [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
            
            [self.challengeTextField showFieldWithError:YES];
        }];
    };
    
    service.successCase = ^(NSDictionary *response) {
        [loading finishLoading:^{
            NSString *cleanPhoneNumber = [NSString stringWithFormat:@"%@%@", @"55", [self getCleanPhoneNumberFromFormattedPhoneNumber:self.phoneNumberTextField.text]];
            User *user = [User sharedUser];
            user.phoneNumber = cleanPhoneNumber;
            [self.navigationController popViewControllerAnimated:NO];
        }];
    };
    
    [service confirmPhoneNumber:cleanPhoneNumber withChallenge:challenge phoneChangeToken:self.phoneChangeToken];
}

#pragma mark - Text field delegate
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
    } else if (textField == self.challengeTextField) {
        [self.challengeTextField showFieldWithError:NO];
        
        NSString* challenge = [textField text];
        challenge = [challenge stringByReplacingCharactersInRange:range withString:string];
        
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^[0-9]{0,6}$" options:0 error:nil];
        int numberOfMatches = (int)[regex numberOfMatchesInString:challenge options:0 range:NSMakeRange(0, challenge.length)];
        
        if (![challenge isEqualToString:@""] && numberOfMatches == 0) {
            return NO;
        }
        
        if (challenge.length == 6) {
            [textField resignFirstResponder];
            [self checkChallenge:challenge];
            self.challengeTextField.text = challenge;
        }
        
        return challenge.length < 6 ? YES : NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.phoneNumberTextField) {
        [self isPhoneValid];
    }
}

- (NSString *)getCleanPhoneNumberFromFormattedPhoneNumber:(NSString *)formattedPhoneNumber {
    NSString *cleanNumber = [[[[formattedPhoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""]
                             stringByReplacingOccurrencesOfString:@")" withString:@""]
                             stringByReplacingOccurrencesOfString:@"-" withString:@""]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];

    return cleanNumber;
}

#pragma mark - Layout
- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Telefone";
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Salvar" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTouched)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layout backgroundColor];
    
    // Configura o text field do telefone
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.phoneNumberTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.phoneNumberTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.phoneNumberTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.phoneNumberTextField setBottomBorderWithColor:layout.lightGray];
    self.phoneNumberTextField.clearButtonMode = UITextFieldViewModeNever;
    
    self.phoneNumberTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.phoneNumberTextField.textColor = layout.darkFontColor;
    self.phoneNumberTextField.text = self.currentPhoneNumber;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.challengeView.hidden = YES;
    
    // Configura label do código enviado
    self.phoneNumberLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.phoneNumberLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    self.challengeNotReceivedLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.challengeNotReceivedLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    // Configura o text field do desafio
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.challengeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.challengeTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.challengeTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.challengeTextField setBottomBorderWithColor:layout.lightGray];
    self.challengeTextField.clearButtonMode = UITextFieldViewModeNever;
    self.challengeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.challengeTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.challengeTextField.textColor = layout.darkFontColor;
    
    self.resendChallengeButton.titleLabel.font = [layout fontWithSize:layout.regularFontSize];
}

@end
