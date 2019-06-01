//
//  ChangeNameViewController.m
//  Example
//
//  Created by Adriano Soares on 05/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "ChangeNameViewController.h"
#import "LayoutManager.h"
#import "BaseNavigationController.h"
#import "User.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "UIView+Gradient.h"
#import "AnalyticsUtil.h"

@interface ChangeNameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nameField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightGradientView;

@end

@implementation ChangeNameViewController

static CGFloat const kBottomConstraintMin = 22.0;
static NSString* const kNavigationTitle = @"Meus dados";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    User* user = [User sharedUser];
    
    self.nameField.text = user.fullName;
    
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self configureLayout];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self dismissKeyboard];
}


- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        _heightGradientView.constant = _heightGradientView.constant - 40;

        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.4 animations:^{
        _heightGradientView.constant = 222;

        self.bottomConstraint.constant = kBottomConstraintMin;

        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
    
}


- (BOOL) isvalid {
    [self.nameField showFieldWithError:NO];
    NSArray *parts = [self.nameField.text componentsSeparatedByString:@" "];
    NSString *regex = @"^\\p{L}+$";
    if ([self.nameField.text isEqualToString:@""] || parts.count <= 1) {
        [self.nameField showFieldWithError:YES];
        return NO;
    }

    for (int i = 0; i < parts.count; i++) {
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:parts[i]
                                                         options:0
                                                           range:NSMakeRange(0, [parts[i] length])];
        if (regExMatches == 0) {
            [self.nameField showFieldWithError:YES];
            return NO;
        }
    }

    return YES;

}

- (IBAction)saveButtonTouched:(id)sender {
    // Envia o dado alterado ao servidor
    if (![self isvalid]) return;
        
        
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    Services *service = [[Services alloc] init];
    service.successCase = ^(NSDictionary *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AnalyticsUtil logEventWithName:@"confirmacao_edicao_nome_usuario" andParameters:nil];
            
            User* user = [User sharedUser];
            user.fullName = self.nameField.text;
            [loadingViewController finishLoading:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        // Em caso de erro ao alterar o dado, exibe alerta para o usuário
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingViewController finishLoading:^{
                PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
                [alert show:self title:@"Atenção!" description:msg imageMode:Error buttonAction:nil];
            }];
        });
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[FullNameKey] = self.nameField.text;
    
    [service setAccountData:data];
}

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    // Configura view
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura navigation bar
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.titleLabel.textColor = layout.lightFontColor;
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.nameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.nameField.floatLabelFont = [layout fontWithSize:11.0];
    self.nameField.floatLabelActiveColor = layout.darkFontColor;
    [self.nameField setBottomBorderWithColor:layout.lightGray];
    self.nameField.clearButtonMode = UITextFieldViewModeNever;
    
    self.nameField.font = [layout fontWithSize:layout.regularFontSize];
    self.nameField.textColor = layout.darkFontColor;
    //[self.nameField setPlaceholder:@"Nome Completo"];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    box.clipsToBounds = YES;

}

@end
