//
//  CardFieldViewController.m
//  Example
//
//  Created by Adriano Soares on 25/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardFieldViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "UIView+Gradient.h"
#import "CardSecurityCodeProtocol.h"
#import "NSStringMask.h"
#import "CardNumberProtocol.h"
#import "CardNameProtocol.h"
#import "CardExpirationProtocol.h"
#import "CardSecurityCodeProtocol.h"
#import "AnalyticsUtil.h"

@interface CardFieldViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *mainButton;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dataTextField;

@property (weak, nonatomic) IBOutlet UIView *cardFrontView;
@property (weak, nonatomic) IBOutlet UIView *cardBackView;

@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardExpirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *cardCVVLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dontHaveFieldLabel;

@end



@implementation CardFieldViewController

static NSString* const kNavigationTitle = @"Cadastro";
static CGFloat const kBottomConstraintMin = 22.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isShowingCardFront = ![_dataProtocol isKindOfClass:[CardSecurityCodeProtocol class]];
    if(isShowingCardFront) {
        [_cardFrontView setHidden:NO];
        [_cardBackView setHidden:YES];
    } else {
        [_cardFrontView setHidden:YES];
        [_cardBackView setHidden:NO];
    }
    // Do any additional setup after loading the view from its nib.
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    [self configureLayout];
    
    if (_dataProtocol) {
        __weak CardFieldViewController *weakSelf = self;
        _dataProtocol.onUpdateField = ^(NSString *number, NSString *name, NSString *date, NSString *cvv) {
            [weakSelf formatDataToCard:number
                                  name:name
                            expiration:date
                                   cvv:cvv];
        };
        _dataProtocol.flowController = self.flowController;
    }
    
    if(_dataProtocol.optional) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ignoreFieldRequest:)];
        [_dontHaveFieldLabel addGestureRecognizer:gesture];
        _dontHaveFieldLabel.userInteractionEnabled = YES;
    } else {
        [_dontHaveFieldLabel setHidden:true];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLayout];
    
    [self formatDataToCard:self.flowController.cardNumber
                      name:self.flowController.cardName
                expiration:self.flowController.expirationDate
                       cvv:self.flowController.CVV];
    
    if (_forceShowError) {
        [_dataTextField showFieldWithError:YES];
        _forceShowError = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self resetSizeHeader];
    
    [_dataTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
    self.navigationController.title = @"";
    self.navigationItem.title = @"";

}

- (void)dismissKeyboard:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)ignoreFieldRequest:(UITapGestureRecognizer *)sender {
    [self dismissKeyboard];
    [_dataProtocol saveData:self
                       data:nil withCompletion:^(NSString *savedData) {
                           [self.flowController viewControllerDidFinish:self];
                       }];
}

- (void)ignoreFieldRequest {
    
    [self dismissKeyboard];
    [_dataProtocol saveData:self
                       data:nil withCompletion:^(NSString *savedData) {
                           [self.flowController viewControllerDidFinish:self];
                       }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        if ([[UIScreen mainScreen] bounds].size.height >= 568 ) {
            NSLog(@"App is running on iPhone with screen 4 inch");
            _heightHeader.constant = 199 - 95;
        }else if([[UIScreen mainScreen] bounds].size.height < 568){
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = 170 - 140;
        }
        
        _bottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
  
    
    [UIView animateWithDuration:0.4 animations:^{
        if ([[UIScreen mainScreen] bounds].size.height >= 568 ) {
            NSLog(@"App is running on iPhone with screen 4 inch");
            _heightHeader.constant = 199;
        } else if([[UIScreen mainScreen] bounds].size.height < 568){
            NSLog(@"App is running on iPhone with screen 3.5 inch");
            _heightHeader.constant = 170;
        }

        self.bottomConstraint.constant = kBottomConstraintMin;
        
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
}


- (IBAction)nextButtonTouched:(id)sender {
    
    NSString *data = [_dataProtocol serverFormattedData:self.dataTextField.text];
    if([_dataProtocol isDataValid:data]) {
        [self dismissKeyboard];
        [_dataProtocol saveData:self
                           data:data withCompletion:^(NSString *savedData) {
                               [self.flowController viewControllerDidFinish:self];
                           }];
    }else{
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        [modal show:self
              title:@"Atenção"
        description:@"\nPor favor, revise as informações inseridas."
          imageMode:Error
       buttonAction:nil];
    }
}


- (void) formatDataToCard:(NSString *)number name:(NSString *)name expiration:(NSString *)expiration cvv:(NSString *)cvv {
    NSString *numberText = number;
    if (numberText == nil || [numberText isEqualToString:@""]) {
        numberText = self.flowController.cardNumber ? self.flowController.cardNumber: @"0000000000000000";
    }
    self.cardNumberLabel.text = (NSString *)[NSStringMask maskString:numberText withPattern:@"(\\d{4}) (\\d{4}) (\\d{4}) (\\d{6})"];
    

    NSString *nameText = name;
    if (nameText == nil || [nameText isEqualToString:@""]) {
        nameText = self.flowController.cardName ? self.flowController.cardName: @"Nome do usuário";
    }
    self.cardNameLabel.text = nameText;
    
    NSString *expirationText = expiration;
    if (expirationText == nil || [expirationText isEqualToString:@""]) {
        expirationText = self.flowController.expirationDate ? self.flowController.expirationDate: @"00/00";
    }
    self.cardExpirationDateLabel.text = (NSString *)[NSStringMask maskString:expirationText withPattern:@"(\\d{2})/(\\d{2})"];
    
    NSString *cvvText = cvv;
    if (cvvText == nil || [cvvText isEqualToString:@""]) {
        cvvText = self.flowController.CVV ? self.flowController.CVV: @"000";
    }
    self.cardCVVLabel.text = cvvText;
}

- (void) resetSizeHeader{
    if ([[UIScreen mainScreen] bounds].size.height<=480.0f) {
        NSLog(@"App is running on iPhone with screen 3.5 inch");
        _heightHeader.constant = 170;
    }else{
        _heightHeader.constant = 199;
    }
    
    self.bottomConstraint.constant = kBottomConstraintMin;
    
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    // Configura view
    self.view.backgroundColor = layout.backgroundColor;
    
    // Configura navigation bar
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    

    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    self.descriptionLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = layout.lightFontColor;
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.dataTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.dataTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.dataTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.dataTextField setBottomBorderWithColor: layout.lightGray];
    self.dataTextField.clearButtonMode = UITextFieldViewModeNever;
    //
    
    self.dataTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.dataTextField.textColor = layout.darkFontColor;

    
    if (_dataProtocol) {
        self.descriptionLabel.text = _dataProtocol.title;
        [self.dataTextField setPlaceholder:_dataProtocol.textFieldPlaceHolder];
        self.dataTextField.delegate = _dataProtocol;
        self.dataTextField.keyboardType = _dataProtocol.keyboardType;
    }
    
    NSArray *fields = @[_cardNumberLabel,_cardExpirationDateLabel, _cardNameLabel, _cardCVVLabel];
    for (int i = 0; i< fields.count; i++) {
        UILabel *field = fields[i];
        field.font = [layout fontWithSize:layout.subTitleFontSize];
        field.textColor = layout.darkFontColor;
    }
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];
    
    
    if ([_dataProtocol isKindOfClass:[CardNumberProtocol class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_numero_cartao"];
        _dataTextField.text = (NSString *)[NSStringMask maskString:self.flowController.enteredCardNumber withPattern:@"(\\d{4}) (\\d{4}) (\\d{4}) (\\d{6})"];
    }
    
    if ([_dataProtocol isKindOfClass:[CardNameProtocol class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_nome_cartao"];
        _dataTextField.text = self.flowController.enteredCardName;
    }
    
    if ([_dataProtocol isKindOfClass:[CardExpirationProtocol class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_data_cartao"];
        _dataTextField.text = (NSString *)[NSStringMask maskString:_flowController.enteredExpirationDate withPattern:@"(\\d{2})/(\\d{2})"];
    }
    
    if ([_dataProtocol isKindOfClass:[CardSecurityCodeProtocol class]]) {
        [AnalyticsUtil createScreenViewWithName:@"cadastro_cvv_cartao"];
        _dataTextField.text = self.flowController.enteredCVV;
    }

    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //Evita a necessidade de tocar duas vezes  no botão
    if ([touch.view isDescendantOfView:_mainButton]) {
        return NO;
    }
    
    return YES;
}

@end
