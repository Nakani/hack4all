//
//  FamilySetBalanceViewController.m
//  Example
//
//  Created by Adriano Soares on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "FamilySetBalanceViewController.h"
#import "BaseNavigationController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"
#import "NSStringMask.h"
#import "FamilyConfirmViewController.h"

@interface FamilySetBalanceViewController ()
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *balanceTextField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) NSString *balanceImageName;

@end

@implementation FamilySetBalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.balanceImageName = @"iconMensalLimit";
    self.balanceTextField.delegate = self;
    
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Limite";
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        textField.text = [formatter stringFromNumber: [NSNumber numberWithFloat:[newString doubleValue]/100]];
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    } else {
        textField.text = @"";
    
    }
        return NO;
}

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Limite";
    
    LayoutManager *layout = [LayoutManager sharedManager];
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.balanceTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.balanceTextField.floatLabelFont = [layout fontWithSize:layout.miniFontSize];
    self.balanceTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.balanceTextField setBottomBorderWithColor:layout.lightGray];
    self.balanceTextField.clearButtonMode = UITextFieldViewModeNever;
    
    [self.balanceTextField setFont:[layout fontWithSize:layout.regularFontSize]];
    self.balanceTextField.textColor = [layout darkFontColor];

    
    self.descriptionLabel.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] titleFontSize]];
    self.descriptionLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    
    self.subTitleLabel.font = [layout fontWithSize:[layout subTitleFontSize]];
    self.subTitleLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
}
- (IBAction)continueClicked:(id)sender {
    if(![self isDataValid:_balanceTextField.text]) {
        [self.balanceTextField showFieldWithError:YES];
        return;
    }
    
    double amount = [[[_balanceTextField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] doubleValue];
    self.completion(amount);
}

- (BOOL)isDataValid:(NSString *)data {
    NSString *cleanedData = [[data componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"%@", cleanedData);
    if (cleanedData.length >= 3) {
        return YES;
    }
    return NO;
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
