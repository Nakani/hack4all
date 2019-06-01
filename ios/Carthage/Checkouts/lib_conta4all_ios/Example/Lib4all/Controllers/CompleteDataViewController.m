//
//  CompleteDataViewController.m
//  Example
//
//  Created by Cristiano Matte on 12/08/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CompleteDataViewController.h"
#import "ErrorTextField.h"
#import "MainActionButton.h"
#import "LayoutManager.h"
#import "Services.h"
#import "ChallengeViewController.h"
#import "LoadingViewController.h"
#import "User.h"
#import "CreditCard.h"
#import "CreditCardsList.h"
#import "ServicesConstants.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "DateUtil.h"
#import "CpfCnpjUtil.h"
#import "UITextFieldMask.h"
#import "NSStringMask.h"
#import "UIImage+Color.h"
#import "AnalyticsUtil.h"

@interface CompleteDataViewController () < UITextFieldDelegate >

@property (strong, nonatomic) ErrorTextField *fullNameTextField;
@property (strong, nonatomic) ErrorTextField *cpfOrCnpjTextField;
@property (strong, nonatomic) UITextFieldMask *birthdateTextField;
@property (strong, nonatomic) MainActionButton *continueButton;

@end

@implementation CompleteDataViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [self configureLayout];
}

// MARK: - Actions

- (void)continueButtonTouched {
    if (![self allFieldsValid]) {
        return;
    }
    
    [self.view endEditing:YES];
    
    /*
     * Se é o root do navigationController, foi exibido quando o usuário já está logado
     * e tentou fazer um pagamento com algum dado faltante.
     * Caso contrário, esta tela foi apresentada no fluxo de login e deve prosseguir
     * para o challenge.
     */
    if (self.navigationController.viewControllers[0] == self) {
        // Atualiza os dados do usuário no servidor
        [self updateUserDataWithCompletionBlock:^{
            // Em caso de sucesso, fecha a tela e chama o callback pré-venda
            CreditCard *card = [[CreditCardsList sharedList] getDefaultCard];
            if(card.askCvv) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pagamento"
                                                                                         message:@"Informe o código de segurança (CVV) localizado na parte de trás do seu cartão"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"CVV";
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                }];
                [alertController addAction:[UIAlertAction
                                            actionWithTitle:@"Pagar"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [self dismissViewControllerAnimated:YES completion:^{
                                                    
                                                }];
                                                
                                                NSArray *textFields = alertController.textFields;
                                                UITextField *cvvField = textFields[0];
                                                _signFlowController.loginWithPaymentCompletion([[User sharedUser] token], [card cardId], cvvField.text);
                                            }]];
                [alertController addAction:[UIAlertAction
                                            actionWithTitle:@"Cancelar"
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                [self dismissViewControllerAnimated:YES completion:^{
                                                    
                                                }];
                                            }]];
                
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    _signFlowController.loginWithPaymentCompletion([[User sharedUser] token], [card cardId], nil);
                }];
            }
            
        }];
    } else {
        _signFlowController.accountData = [self getDataDictionary];
        [self performSegueWithIdentifier:@"segueChallenge" sender:nil];
    }
}

- (IBAction)closeButtonTouched:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

// MARK: - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.cpfOrCnpjTextField) {
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
    }
    
    return YES;
}

// MARK: - Fields validation

- (BOOL)allFieldsValid {
    BOOL allFieldsValid = YES;

    if (_signFlowController.requireFullName) {
        BOOL fieldValid = [self.fullNameTextField.text componentsSeparatedByString:@""].count > 1;
        allFieldsValid = allFieldsValid && fieldValid;
        [self showTextFieldValidationOnTextField:self.fullNameTextField valid:fieldValid];
    }

    if (_signFlowController.requireCpfOrCnpj) {
        NSArray *cpfOrCnpj = [[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.cpfOrCnpjTextField.text] toNumberArray];
        BOOL fieldValid = [CpfCnpjUtil isValidCpfOrCnpj:cpfOrCnpj];
        
        allFieldsValid = allFieldsValid && fieldValid;
        [self showTextFieldValidationOnTextField:self.cpfOrCnpjTextField valid:fieldValid];
    }
    
    if (_signFlowController.requireBirthdate) {
        BOOL fieldValid = [DateUtil isValidBirthdateString:self.birthdateTextField.text];
        
        allFieldsValid = allFieldsValid && fieldValid;
        [self showTextFieldValidationOnTextField:self.birthdateTextField valid:fieldValid];
    }

    return allFieldsValid;
}

- (void)showTextFieldValidationOnTextField:(ErrorTextField *)textField valid:(BOOL)valid {
    [textField showFieldWithError:valid];

    if (valid) {
        [self.view sendSubviewToBack:textField];
    } else {
        [self.view bringSubviewToFront:textField];
    }
}

// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueChallenge"]) {
        ChallengeViewController *nextViewController = segue.destinationViewController;
        nextViewController.signFlowController = _signFlowController;
    }
}

// MARK: - Auxiliar methods

- (NSDictionary *)getDataDictionary {
    NSMutableDictionary *accountData = self.preSettedData;
    if (accountData == nil) accountData = [[NSMutableDictionary alloc] init];
    
    if (self.fullNameTextField != nil) {
        [accountData setObject:self.fullNameTextField.text forKey:FullNameKey];
    }
    
    if (self.cpfOrCnpjTextField != nil) {
        [accountData setObject:[CpfCnpjUtil getClearCpfOrCnpjNumberFromMaskedNumber:self.cpfOrCnpjTextField.text] forKey:CpfKey];
    }
    
    if (self.birthdateTextField != nil && self.birthdateTextField.text != nil) {
        // Converte a data de nascimento para o formato de data do servidor        
        [accountData setObject:[DateUtil convertDateString:self.birthdateTextField.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"] forKey:BirthdateKey];
    }
    
    return accountData;
}

- (void)updateUserDataWithCompletionBlock:(void (^)())completion {
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    Services *service = [[Services alloc] init];
    
    service.successCase = ^(id response) {
        // Em caso de sucesso, fecha a tela de carregamento e chama o completion
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingViewController finishLoading:^{
                completion();
            }];
        });
    };
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Fechar" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingViewController finishLoading:^{
                [self presentViewController:alert animated:YES completion:nil];
            }];
        });
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    [service setAccountData:[self getDataDictionary]];
}

// MARK: - Layout

- (void)configureLayout {
    // Configura navigation bar
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        imgTitle.image = [UIImage lib4allImageNamed:@"4allwhite"];
        imgTitle.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = imgTitle;
    }
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    // Configura view
    self.view.backgroundColor = [[LayoutManager sharedManager] backgroundColor];
    
    // Configura botão de continuar
    self.continueButton = [[MainActionButton alloc] init];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton setTitle:@"CONTINUAR" forState:UIControlStateNormal];
    
    [self.continueButton addTarget:self
                            action:@selector(continueButtonTouched)
                  forControlEvents:UIControlEventTouchUpInside];

    // Adiciona campos de dados programaticamente
    NSMutableArray *requiredDataTextFields = [[NSMutableArray alloc] init];
    if (_signFlowController.requireFullName) {
        self.fullNameTextField = [[ErrorTextField alloc] init];
        self.fullNameTextField.placeholder = @"Nome completo";
        [self.fullNameTextField setIconsImages:[UIImage lib4allImageNamed:@"iconFullName"]
                                      errorImg:[[UIImage lib4allImageNamed:@"iconFullName"] withColor:[[LayoutManager sharedManager] red]]];
        self.fullNameTextField.regex = @"^[a-zA-Z]*$";
        
        [requiredDataTextFields addObject:self.fullNameTextField];
    }

    if (_signFlowController.requireCpfOrCnpj) {
        self.cpfOrCnpjTextField = [[ErrorTextField alloc] init];
        self.cpfOrCnpjTextField.placeholder = @"CPF ou CNPJ";
        [self.cpfOrCnpjTextField setIconsImages:[UIImage lib4allImageNamed:@"iconCpf"]
                                       errorImg:[[UIImage lib4allImageNamed:@"iconCpf"] withColor:[[LayoutManager sharedManager] red]]];
        self.cpfOrCnpjTextField.keyboardType = UIKeyboardTypeNumberPad;
        [requiredDataTextFields addObject:self.cpfOrCnpjTextField];
        
        [AnalyticsUtil createScreenViewWithName:@"cadastro_cpf"];
    }
    
    if (_signFlowController.requireBirthdate) {
        self.birthdateTextField = [[UITextFieldMask alloc] init];
        self.birthdateTextField.placeholder = @"Data de nascimento";
        [self.birthdateTextField setIconsImages:[UIImage lib4allImageNamed:@"iconStar"]
                                       errorImg:[[UIImage lib4allImageNamed:@"iconStar"] withColor:[[LayoutManager sharedManager] red]]];
        self.birthdateTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.birthdateTextField.regex = @"^[0-9]{2}/[0-9]{2}/[0-9]{4}$";
        self.birthdateTextField.mask = [NSStringMask maskWithPattern:@"(\\d{2})/(\\d{2})/(\\d{4})"];
        
        [requiredDataTextFields addObject:self.birthdateTextField];
    }
    
    id bottomView = self.topLayoutGuide;
    
    // Adiciona as constraints de cada campo
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    for (int i = 0; i < requiredDataTextFields.count; i++) {
        ErrorTextField *textField = requiredDataTextFields[i];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *top = i == 0 ? @"20" : @"(-1)";
        NSString *verticalConstraints = [[@"V:[topView]-" stringByAppendingString:top] stringByAppendingString:@"-[textField(47)]"];
        
        [self.view addSubview:textField];
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"topView":bottomView,
                                                                                            @"textField":textField}]];
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[textField]-20-|"
                                                                                  options:NSLayoutFormatAlignAllBaseline
                                                                                  metrics:nil
                                                                                    views:@{@"textField":textField}]];
        
        bottomView = textField;
    }
    
    // Adiciona as constraints do botão de continuar
    [self.view addSubview:self.continueButton];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-10-[continueButton(47)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"continueButton": self.continueButton,
                                                                                       @"topView": bottomView}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[continueButton]-20-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"continueButton": self.continueButton}]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    // Configura o layout dos campos
    [self.view layoutIfNeeded];
    for (int i = 0; i < requiredDataTextFields.count; i++) {
        ErrorTextField *textField = requiredDataTextFields[i];
        
        if (i == 0 && i == requiredDataTextFields.count - 1) {
            [textField roundCustomCornerRadius:5.0 corners:UIRectCornerAllCorners];
        } else if (i == 0) {
            [textField roundTopCornersRadius:5.0];
        } else if (i == requiredDataTextFields.count - 1) {
            [textField roundBottomCornersRadius:5.0];
        }
        
        textField.backgroundColor = [UIColor whiteColor];
        [textField setBorder:[[LayoutManager sharedManager] lightGray] width:1];
        textField.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        textField.textColor = [[LayoutManager sharedManager] darkFontColor];
        textField.delegate = self;
    }
}

@end
