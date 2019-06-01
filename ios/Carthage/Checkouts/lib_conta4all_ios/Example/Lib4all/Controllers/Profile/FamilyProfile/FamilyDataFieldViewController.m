//
//  FamilyDataFieldViewController.m
//  Example
//
//  Created by Adriano Soares on 20/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyDataFieldViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"

#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"


@interface FamilyDataFieldViewController ()
@property (strong, nonatomic) LayoutManager *LM;

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dataTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property CGFloat oldBottomConstant;


@end

@implementation FamilyDataFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.LM = [LayoutManager sharedManager];
    // Do any additional setup after loading the view.
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.oldBottomConstant = self.bottomConstraint.constant;
    
    
    [self configureLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.dataTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.dataTextField resignFirstResponder];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    
    if (self.dataFieldProtocol != nil) {
        self.navigationItem.title = [self.dataFieldProtocol navigationTitle];
        self.currentLabel.text    = [self.dataFieldProtocol currentLabel];
        self.titleLabel.text      = [self.dataFieldProtocol title];

        self.dataTextField.placeholder      = _dataFieldProtocol.textFieldPlaceHolder;
        self.dataTextField.keyboardType     = _dataFieldProtocol.keyboardType;
        self.dataTextField.delegate         = _dataFieldProtocol;
        
        if (self.data) {
            self.currentValueLabel.text = [self.dataFieldProtocol currentValueFormatted:self.data];
        } else {
            self.currentValueLabel.text = @"Indefinido";
        }
    }
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.view.backgroundColor = layout.backgroundColor;
    
    self.currentLabel.font = [layout fontWithSize:self.LM.regularFontSize];
    self.currentLabel.textColor = layout.darkFontColor;
    
    self.currentValueLabel.font = [self.LM fontWithSize:self.LM.regularFontSize];
    self.currentValueLabel.textColor = self.LM.primaryColor;
    
    self.titleLabel.font = [self.LM fontWithSize:self.LM.regularFontSize];
    self.titleLabel.textColor = self.LM.darkFontColor;
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.dataTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.dataTextField.floatLabelFont = [layout fontWithSize:0.0];
    self.dataTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.dataTextField setBottomBorderWithColor:layout.lightGray];
    self.dataTextField.clearButtonMode = UITextFieldViewModeNever;
    
    [self.dataTextField setFont:[layout fontWithSize:layout.regularFontSize]];
    self.dataTextField.textColor = [layout darkFontColor];
    
 
}

- (IBAction)saveButton:(id)sender {
    if ([self.dataFieldProtocol isDataValid:self.dataTextField.text]) {
        NSString *formattedData = [self.dataFieldProtocol serverFormattedData:self.dataTextField.text];
        [self.dataTextField showFieldWithError:NO];
        if (self.isCreation) {
            if (self.completion != nil) {
                self.completion(formattedData);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.dataFieldProtocol saveData:self
                                        data:formattedData
                              withCompletion:^(NSString *data) {
                                  
                if (self.completion) {
                    self.completion(data);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        
        
    } else {
        [self.dataTextField showFieldWithError:YES];
    }

}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - keyboard movements

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = self.oldBottomConstant +  keyboardSize.height;
        [self.view updateConstraints];
    }];
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.bottomConstraint.constant = self.oldBottomConstant;
        [self.view updateConstraints];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
