//
//  ChangeEmailAddressViewController.m
//  Example
//
//  Created by Cristiano Matte on 02/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "ChangeEmailAddressViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "UIImage+Color.h"
#import "AnalyticsUtil.h"

@interface ChangeEmailAddressViewController ()

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UIView *waitingForConfirmationView;
@property (weak, nonatomic) IBOutlet UILabel *waitingForConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessEmailToConfirmLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailNotReceivedLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendEmailButton;
@property (strong, nonatomic) UIBarButtonItem *saveButton;

@end

@implementation ChangeEmailAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.emailAddressTextField.delegate = self;
    
    [self configureLayout];
}

#pragma mark - Actions
- (IBAction)sendEmailAgain {
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
        self.resendEmailButton.enabled = YES;
    };
    
    service.successCase = ^(NSDictionary *response) {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        [alert show:self title:@"Atenção!" description:@"Email reenviado!" imageMode:Success buttonAction:nil];

        self.resendEmailButton.enabled = YES;
    };
    
    self.resendEmailButton.enabled = NO;
    [service requestEmailConfirmation];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


- (BOOL) isEmailValid {
    NSString *cleanText = self.emailAddressTextField.text;
    NSString *regex = @"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$";
    [self.emailAddressTextField showFieldWithError:NO];
    if([cleanText length]==0){
        [self.emailAddressTextField showFieldWithError:YES];
        return NO;
    }else{
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:cleanText options:0 range:NSMakeRange(0, [cleanText length])];
        
        if (regExMatches == 0) {
            [self.emailAddressTextField showFieldWithError:YES];
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)saveButtonTouched {
    [self.view endEditing:YES];
    
    if ([self isEmailValid]) {
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg) {
            PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
            [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
            
            self.emailAddressTextField.userInteractionEnabled = YES;
            self.saveButton.enabled = YES;
        };
        
        service.successCase = ^(NSDictionary *response) {
            self.navigationItem.rightBarButtonItem = nil;
            
            [AnalyticsUtil logEventWithName:@"confirmacao_edicao_email_usuario" andParameters:nil];
            
            // Exibe a view da confirmação
            [UIView transitionWithView:self.waitingForConfirmationView
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{ self.waitingForConfirmationView.hidden = NO; }
                            completion:NULL];
        };
        
        self.saveButton.enabled = NO;
        self.emailAddressTextField.userInteractionEnabled = NO;
        [service changeEmailAddress:self.emailAddressTextField.text];
    }
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailAddressTextField && [self isEmailValid]) {
        [self saveButtonTouched];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.emailAddressTextField) {
        [self isEmailValid];
    }
}

#pragma mark - Layout
- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"E-mail";
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Salvar" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTouched)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.view.backgroundColor = [layout backgroundColor];
    
    // Configura o text field do email
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.emailAddressTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailAddressTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.emailAddressTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.emailAddressTextField setBottomBorderWithColor:layout.lightGray];
    self.emailAddressTextField.clearButtonMode = UITextFieldViewModeNever;
    
    self.emailAddressTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.emailAddressTextField.textColor = layout.darkFontColor;
    self.emailAddressTextField.text = self.currentEmailAddress;
    
    self.waitingForConfirmationView.hidden = YES;

    // Configura as labels de confirmação do email
    self.waitingForConfirmationLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.subTitleFontSize];
    self.waitingForConfirmationLabel.textColor = [[LayoutManager sharedManager] primaryColor];
    
    self.accessEmailToConfirmLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.accessEmailToConfirmLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    self.emailNotReceivedLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.emailNotReceivedLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    self.resendEmailButton.titleLabel.font = [layout fontWithSize:layout.regularFontSize];
}

@end
