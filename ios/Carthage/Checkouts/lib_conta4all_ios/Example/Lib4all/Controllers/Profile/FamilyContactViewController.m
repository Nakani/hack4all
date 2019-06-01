//
//  FamilyContactViewController.m
//  Example
//
//  Created by Adriano Soares on 15/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "FamilyContactViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "User.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"

#import "UIImage+Color.h"
#import "NSStringMask.h"
#import "CardsTableViewController.h"
#import "FamilySetBalanceViewController.h"
#import "FamilyConfirmViewController.h"


@interface FamilyContactViewController ()

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneTextField;

@property (strong, nonatomic) NSString *phoneTextImage;

@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldLabel;

@property (strong, nonatomic) NSMutableString *rawId;

@end

@implementation FamilyContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    _rawId = [[NSMutableString alloc] init];
    
    self.phoneTextImage = @"iconPhone";
    
    self.phoneTextField.delegate = self;
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    
    [self configureLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.navigationItem.title = @"Membro";
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (IBAction)selectContact:(id)sender {
    if (NSClassFromString(@"CNContactPickerViewController")) {
        // iOS 9, 10, use CNContactPickerViewController
        CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    // Get the multivalue number property.
    CFTypeRef multivalue = ABRecordCopyValue(person, property);
    
    // Get the index of the selected number. Remember that the number multi-value property is being returned as an array.
    CFIndex index = ABMultiValueGetIndexForIdentifier(multivalue, identifier);
    
    // Copy the number value into a string.
    NSString *number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multivalue, index);
    
    number = [self cleanPhoneString:number];
    
    [self setNumber: number];
}


- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    if ([contactProperty.key isEqualToString:@"phoneNumbers"]) {
        [self setNumber:[[contactProperty valueForKey:@"value"] valueForKey:@"digits"]];
    }
}


- (void) setNumber: (NSString *)number {
    User *user = [User sharedUser];
    NSString *ddd = [user.phoneNumber substringWithRange:NSMakeRange(2, 2)];
    //Numero invalido
    if (number.length < 8) return;
    
    NSString *baseNumber = [number substringFromIndex:number.length-8];
    if (number.length > 8) {
        number = [number substringToIndex:number.length-8];
        if ([number characterAtIndex:number.length-1] == '9') {
            number = [number substringToIndex:number.length-1];
        }
        //Contem DDD
        if (number.length > 2) {
            ddd = [number substringFromIndex:number.length-2];
        }
    }
    NSString *phoneNumber = [NSString stringWithFormat:@"55%@9%@", ddd, baseNumber];
    _phoneTextField.text = (NSString *)[NSStringMask maskString:[phoneNumber substringFromIndex:2] withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    
}

- (NSString *) cleanPhoneString: (NSString *)phone {
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"[\\(\\)-]"
                                               withString:@""
                                                  options:NSRegularExpressionSearch
                                                    range:NSMakeRange(0, phone.length)];
    
    
    phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];


    return phone;
}

- (IBAction)continueClick:(id)sender {
    if (![self isDataValid:[self cleanPhoneString:self.phoneTextField.text]]) {
        [_phoneTextField showFieldWithError:YES];
        return;
    }
    
    CardsTableViewController* cardPickerViewController = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                         instantiateViewControllerWithIdentifier:@"CardsTableViewController"];

    
    // Exibe o viewController se foi possível obte-lo da storyboard e se há navigationController
    if (cardPickerViewController && self.navigationController) {
        cardPickerViewController.onSelectCardAction = OnSelectCardShowNextVC;
        cardPickerViewController.didSelectCardBlock = ^(NSString *cardID) {
            [self setBalance: cardID];
        };
        [self.navigationController pushViewController:cardPickerViewController animated:YES];
    }
}

- (void) setBalance:(NSString *)cardID {
    FamilySetBalanceViewController *balanceVC = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                                 instantiateViewControllerWithIdentifier:@"FamilySetBalanceViewController"];
    
    balanceVC.cardID = cardID;
    balanceVC.phoneNumber = [self cleanPhoneString:self.phoneTextField.text];
    
    balanceVC.completion = ^(double amount) {
        FamilyConfirmViewController *vc = [[UIStoryboard storyboardWithName: @"Lib4all" bundle: [NSBundle getLibBundle]]
                                           instantiateViewControllerWithIdentifier:@"FamilyConfirmViewController"];
        
        vc.cardID = cardID;
        vc.phoneNumber = [self cleanPhoneString:self.phoneTextField.text];
        vc.amount = amount;
        
        [self.navigationController pushViewController:vc animated:YES];
    
    };
    
    [self.navigationController pushViewController:balanceVC animated:YES];

}

- (BOOL)isDataValid:(NSString *)data {
    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                                options:0
                                                                                  error:nil];
    NSString *cleanedPhone = [self cleanPhoneString:data];
    if ([phoneRegex numberOfMatchesInString:data options:0 range:NSMakeRange(0, data.length)] > 0 && cleanedPhone.length == 11) {
        return YES;
    }
    return NO;
}


// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Permite backspace apenas com cursor no último caractere
    if (range.length == 1 && string.length == 0 && range.location != newString.length) {
        textField.selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
        return NO;
    }
    
    newString = [self cleanPhoneString:newString];
    textField.text = (NSString *)[NSStringMask maskString:newString withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    
    return NO;
}

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Membro";
    
    LayoutManager *layout = [LayoutManager sharedManager] ;
    
    self.view.backgroundColor = [layout backgroundColor];
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.phoneTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.phoneTextField.floatLabelFont = [layout fontWithSize:0];
    self.phoneTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.phoneTextField setBottomBorderWithColor:layout.lightGray];
    self.phoneTextField.clearButtonMode = UITextFieldViewModeNever;
    [self.phoneTextField setFont:[layout fontWithSize:layout.regularFontSize]];
    self.phoneTextField.textColor = [layout darkFontColor];


    self.orLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.orLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    self.fieldLabel.font = [[LayoutManager sharedManager] fontWithSize:[LayoutManager sharedManager].regularFontSize];
    self.fieldLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    
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
