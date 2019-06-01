//
//  PPTransferContactViewController.m
//  Example
//
//  Created by Adriano Soares on 19/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPTransferContactViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "MainActionButton.h"
#import "User.h"
#import "LoadingViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "NSStringMask.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import "Services.h"
#import "ServicesConstants.h"
#import "UIImage+Color.h"
#import "PPTransferContactConfirmationViewController.h"
#import "AnalyticsUtil.h"

@interface PPTransferContactViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property NSMutableArray *contacts;
@property NSMutableArray *allContacts;

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *contactField;
@property (weak, nonatomic) IBOutlet UILabel *selectContactLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MainActionButton *confirmButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomConstraint;

@property (strong, nonatomic) NSMutableString *rawId;
@end

@implementation PPTransferContactViewController

static NSString* const kNavigationTitle = @"Transferir";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.contacts    = [[NSMutableArray alloc] init];
    self.allContacts = [[NSMutableArray alloc] init];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Action to dismiss keyboard
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    self.rawId = [[NSMutableString alloc] init];
    
    self.contactField.delegate = self;
    
    self.bottomConstraint.constant = 20;
    
    [self.selectContactLabel setHidden:YES];
    [self configureLayout];
    [self getContacts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationItem.title = @"";
}

- (void) getContacts {
    if (NSClassFromString(@"CNContactStore")) {
        CNContactStore *store = [[CNContactStore alloc] init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    [self retrieveContactsWithStore:store];
                }
            }];
            
        } else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
            [self retrieveContactsWithStore:store];
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        __block BOOL accessGranted = NO;
        
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(semaphore);
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (accessGranted) {
            [self getContactsWithAddressBook:addressBook];
        }
    }
    
}

- (void) retrieveContactsWithStore:(CNContactStore *) store {
    NSArray *keysToFetch   = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey];
    NSArray *contacts      = [store unifiedContactsMatchingPredicate:nil keysToFetch:keysToFetch error:nil];
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    
    for (int i = 0; i < [contacts count]; i++) {
        CNContact *contact = contacts[i];
        NSString *name     = [formatter stringFromContact:contact];
        NSArray *phones    = contact.phoneNumbers;
        for (int j = 0; j < [phones count]; j++) {
            CNPhoneNumber *phone = [phones[j] valueForKey:@"value"];
            
            if (name && phone) {
                NSDictionary *dict = @{
                                       @"name" : name,
                                       @"phone": [phone valueForKey:@"digits"]
                                       };
                
                [self.allContacts addObject:dict];
            }
            
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self filterAndSortContacts];
    });
    
}


- (void) getContactsWithAddressBook:(ABAddressBookRef) addressBook {
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        NSString *name = @"";
        if (firstName) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@"%@", firstName]];
            
        }
        if (lastName) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lastName]];
            
        }
        
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
            
            if (name && phone) {
                NSDictionary *dict = @{
                                       @"name" : name,
                                       @"phone": phone
                                       };
                [self.allContacts addObject:dict];
            }
            
        }
        
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self filterAndSortContacts];
    });
    
    
}


- (void) filterAndSortContacts {
    self.contacts = [self.allContacts mutableCopy];
    
    [self.contacts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *name1 = [(NSDictionary *)obj1 valueForKey:@"name"];
        NSString *name2 = [(NSDictionary *)obj2 valueForKey:@"name"];
        
        return  [name1 compare:name2 options:NSCaseInsensitiveSearch];
    }];
    
    [self.contacts filterUsingPredicate:[NSPredicate  predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (_contactField.text == nil || [_contactField.text isEqualToString:@""]) {
            return YES;
        }
        
        NSString *contactPhone = [self cleanPhoneString:[evaluatedObject objectForKey:@"phone"]];
        if ([contactPhone containsString:[self cleanPhoneString:_contactField.text]]) {
            return YES;
        }
        
        NSString *contactName = [self cleanNameString:[evaluatedObject objectForKey:@"name"]];
        if ([contactName containsString:[self cleanNameString:_contactField.text]]) {
            return YES;
        }
        
        return NO;
        
    }]];
    if ([self.contacts count] == 0) {
        [self.selectContactLabel setHidden:YES];
        [self.confirmButton setHidden:NO];
    } else {
        [self.selectContactLabel setHidden:NO];
        [self.confirmButton setHidden:YES];
    }
    [self.tableView reloadData];
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

-(NSString *)cleanNameString: (NSString *)name {
    // Removing accents
    name = [[NSString alloc] initWithData:[name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    
    // Making it lower case
    name = [name lowercaseString];
    
    return name;
}

- (NSString *) nameToInitials: (NSString *) name {
    NSMutableArray<NSString *> *firstLetters = [[name componentsSeparatedByString:@" "] mutableCopy];
    [firstLetters removeObject:@""];
    NSString *initials;
    if (firstLetters.count >= 2) {
        initials = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0], [firstLetters[firstLetters.count-1] characterAtIndex:0]];
    }else{
        if (firstLetters[0].length > 1) {
            initials = [NSString stringWithFormat:@"%c%c",[firstLetters[0] characterAtIndex:0],[firstLetters[0] characterAtIndex:1]];
        }else{
            initials = [NSString stringWithFormat:@"%c",[firstLetters[0] characterAtIndex:0]];
        }
    }
    
    return initials;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *newRawId = [[NSMutableString alloc] initWithString:self.rawId];
    
    // Se for backspace, remove último caractere, caso contrário, anexa nova string ao fim da string atual
    if ((string == nil || [string isEqualToString:@""]) && newRawId.length > 0) {
        [newRawId deleteCharactersInRange:NSMakeRange(self.rawId.length-1, 1)];
    } else {
        [newRawId appendString:string];
    }
    
    // Verifica se string atual é número de telefone
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                           options:0
                                                                             error:nil];
    unsigned long regexMatches = [regex numberOfMatchesInString:newRawId
                                                        options:0
                                                          range:NSMakeRange(0, newRawId.length)];
    
    /*
     * Se foi digitado backspace, apaga último caractere. Caso contrário, adiciona
     * caractere ao final da string se for e-mail ou telefone quando ainda não foi
     * adicionado o número máximo de caracteres.
     */
    if ((string == nil || [string isEqualToString:@""]) && self.rawId.length > 0) {
        [self.rawId deleteCharactersInRange:NSMakeRange(self.rawId.length-1, 1)];
    } else if (regexMatches == 0 || (regexMatches > 0 && self.rawId.length < 11)) {
        [self.rawId appendString:string];
    }
    
    // Aplica máscara se for número de telefone
    if (regexMatches > 0) {
        textField.text = (NSString *)[NSStringMask maskString:self.rawId withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    } else {
        textField.text = self.rawId;
    }
    [self filterAndSortContacts];
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    LayoutManager *layout = [LayoutManager sharedManager];
    
    
    UILabel *initialsLabel = [cell viewWithTag:1];
    
    UILabel *nameLabel  = [cell viewWithTag:2];
    nameLabel.text      = [self.contacts[indexPath.row] objectForKey:@"name"];
    nameLabel.textColor = layout.darkFontColor;
    nameLabel.font = [layout boldFontWithSize:layout.regularFontSize];
    
    
    UILabel *phoneLabel = [cell viewWithTag:3];
    phoneLabel.text     = [self.contacts[indexPath.row] objectForKey:@"phone"];
    phoneLabel.textColor = layout.darkFontColor;
    phoneLabel.font = [layout fontWithSize:layout.regularFontSize];
    
    
    initialsLabel.text  = [self nameToInitials:nameLabel.text];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    UILabel *labelFirstLetters  = [cell viewWithTag:1];
    
    labelFirstLetters.clipsToBounds = YES;
    labelFirstLetters.textAlignment = NSTextAlignmentCenter;
    labelFirstLetters.layer.cornerRadius = labelFirstLetters.frame.size.height/2;
    labelFirstLetters.layer.borderColor  = [layout primaryColor].CGColor;
    labelFirstLetters.layer.borderWidth  = 1.0f;
    labelFirstLetters.textColor          = layout.primaryColor;
    labelFirstLetters.font               = [layout fontWithSize:layout.subTitleFontSize];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contact = self.contacts[indexPath.row];
    
    NSString *phone = [self formatNumber:[self cleanPhoneString:[contact objectForKey:@"phone"]]];
    if (phone) {
        [self verifyAccountData:phone];
    } else {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        [alert show:self title:@"Atenção" description:@"Telefone inválido" imageMode:Error buttonAction:nil];
    }
    
}

- (IBAction)confirmButtomTouched:(id)sender {
    if ([self loginIdValid:_rawId]) {
        NSString *phone = [self formatNumber:_rawId];
        if (phone != nil) {
            [self verifyAccountData:phone];
            return;
        }
    }
    PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
    [alert show:self title:@"Atenção" description:@"Telefone inválido" imageMode:Error buttonAction:nil];
}


- (NSString *) formatNumber: (NSString *) number {
    User *user = [User sharedUser];
    NSString *ddd = [user.phoneNumber substringWithRange:NSMakeRange(2, 2)];
    //Numero invalido
    if (number.length < 8) return nil;
    
    if([[number substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0800"]) {
        return nil;
    }
    
    NSString *baseNumber = [number substringFromIndex:number.length-8];
    
    if([number characterAtIndex:0] == '+') {
        number = [number substringFromIndex:1];
    }
    
    if([[number substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"55"] && [number length] > 11) {
        //Número contém 55 e 55 não é o ddd
        number = [number substringFromIndex:2];
    }
    
    if([number characterAtIndex:0] == '0') {
        number = [number substringFromIndex:1];
    }
    
    if([number length] >= 12) {
        //Número contém código da operadora
        number = [number substringFromIndex:2];
    }
    
    if (number.length == 9) {
        //Número está sem ddd e sem 55
        number = [NSString stringWithFormat:@"55%@%@", ddd, number];
    }
    
    if([number length] == 10) {
        //Número está faltando o 55 e só contem os 8 digitos além do ddd
        ddd = [number substringWithRange:NSMakeRange(0, 2)];
    }
    
    if([number length] == 11) {
        //Número está faltando o 55
        number = [NSString stringWithFormat:@"55%@", number];
    }
    
    if([number length] == 12) {
        //Número esta completo, mas sem o 9# digito
        ddd = [number substringWithRange:NSMakeRange(2, 2)];
    }
    
    if([number length] == 13) {
        //Número esta completo
        return number;
    }
    
    
    //Verificar se o telefone é fixo
    if ([baseNumber characterAtIndex:0] == '2' || [baseNumber characterAtIndex:0] == '3' || [baseNumber characterAtIndex:0] == '4' || [baseNumber characterAtIndex:0] == '5') {
        PopUpBoxViewController *alert = [[PopUpBoxViewController alloc] init];
        
        [alert show:self title:@"Atenção" description:@"Não é possível transferir para telefone fixo" imageMode:Error buttonAction:nil];
        return @"";
    }
    
    NSString *phoneNumber = [NSString stringWithFormat:@"55%@9%@", ddd, baseNumber];
    return phoneNumber;
}

- (void) verifyAccountData:(NSString *)data {
    Services *services = [[Services alloc] init];
    
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    PPTransferContactConfirmationViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPTransferContactConfirmationViewController"];
    destination.rawId = data;
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        
        [AnalyticsUtil logEventWithName:@"transferencia_novo_contato" andParameters:nil];
        
        destination.userHasAccount = NO;
        [loading finishLoading:^{
            [self.navigationController pushViewController:destination animated:true];
        }];
    };
    
    services.successCase = ^(NSDictionary *response) {
        
        [AnalyticsUtil logEventWithName:@"transferencia_contato_existente" andParameters:nil];
        
        NSString *name = @"";
        if([response objectForKey:FullNameKey] != [NSNull null] && [response objectForKey:FullNameKey] != nil) {
            name  = [response objectForKey:FullNameKey];
        }
        destination.name = name;
        destination.userHasAccount = YES;
        
        [loading finishLoading:^{
            [self.navigationController pushViewController:destination animated:true];
        }];
    };
    
    [loading startLoading:self title:@"Aguarde ..."];
    
    [services getAccountDataByTerm:data];
    
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.tableviewBottomConstraint.constant = keyboardSize.height;
        self.bottomConstraint.constant = 3 + keyboardSize.height;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.4 animations:^{
        self.tableviewBottomConstraint.constant = 0;
        self.bottomConstraint.constant = 20;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }];
    
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    
    [self.contactField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contactField.floatLabelFont = [layout fontWithSize:[layout miniFontSize]];
    self.contactField.font = [layout fontWithSize:[layout regularFontSize]];
    self.contactField.textColor = [layout darkFontColor];
    self.contactField.floatLabelActiveColor = [layout darkFontColor];
    [self.contactField setBottomBorderWithColor:[layout lightGray]];
    self.contactField.clearButtonMode = UITextFieldViewModeNever;
    self.contactField.horizontalPadding = 0;
    
    self.selectContactLabel.font = [layout fontWithSize:[layout regularFontSize]];
    self.selectContactLabel.textColor = [layout darkFontColor];
}

- (void)configureNavigationBar {
    [(BaseNavigationController *)self.navigationController configureLayout];
    self.navigationItem.title = kNavigationTitle;
    
    if(self.navigationController.viewControllers[0] == self) {
        UIImage *closeButtonImage = [UIImage lib4allImageNamed:@"x"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[closeButtonImage withColor:[LayoutManager sharedManager].lightFontColor]  style:UIBarButtonItemStylePlain target:self action:@selector(didPressCloseButton)];
    }
}

- (BOOL)loginIdValid:(NSString *)idLogin {
    
    if ([idLogin isEqualToString:@""]) {
        return NO;
    }
    
    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d]*$"
                                                                                options:0
                                                                                  error:nil];
    
    if ([phoneRegex numberOfMatchesInString:idLogin options:0 range:NSMakeRange(0, idLogin.length)] > 0) {
        if (idLogin.length == 11) {
            return YES;
        }
        
    }
    
    return NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the segmented control.
    if (([touch.view isKindOfClass:[UIButton class]])) {//change it to your condition
        return NO;
    }
    // Disallow recognition of tap gestures in the table view.
    if([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}

- (void) didPressCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
