//
//  CardTypeSelectorViewController.m
//  Example
//
//  Created by Adriano Soares on 25/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CardTypeSelectorViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "LayoutManager.h"
#import "UIView+Gradient.h"
#import "CardUtil.h"
#import "ComponentViewController.h"
#import "AnalyticsUtil.h"

@interface CardTypeSelectorViewController ()
@property NSArray * acceptedPaymentTypes;
@property NSArray * acceptedBrands;

@property CardType selectedType;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dataTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageDisclosure;

@end

@implementation CardTypeSelectorViewController

static NSString* const kNavigationTitle = @"Cadastro";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedType = 0;
    self.dataTextField.text = @"Selecione";
    
    //muda cor da down disclosure pra cinza
    _imageDisclosure.image = [_imageDisclosure.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imageDisclosure setTintColor:[UIColor lightGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.title = kNavigationTitle;
    self.navigationItem.title = kNavigationTitle;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.title = @"";
    self.navigationItem.title = @"";
    
}

- (IBAction)nextButtonTouched:(id)sender {
    
    if (self.selectedType) {
        [AnalyticsUtil logEventWithName:@"cadastro_tipo_cartao" andParameters:nil];
        
        self.flowController.selectedType = self.selectedType;
        [self.flowController viewControllerDidFinish:self];
    }else{
        PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
        [modal show:self title:@"Atenção!"
        description:@"Você precisa escolher um tipo de cartão para continuar."
          imageMode:Error
       buttonAction:nil];
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *creditAndDebit = [UIAlertAction actionWithTitle:@"Crédito e Débito"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               textField.text = action.title;
                                                               self.selectedType = CardTypeCreditAndDebit;
                                                                                                                          }];
    UIAlertAction *debit = [UIAlertAction actionWithTitle:@"Débito"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      textField.text = action.title;
                                                      self.selectedType = CardTypeDebit;
                                                      
                                                  }];
    UIAlertAction *credit = [UIAlertAction actionWithTitle:@"Crédito"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       textField.text = action.title;
                                                       self.selectedType = CardTypeCredit;

                                                   }];
    UIAlertAction *patAlimentacao = [UIAlertAction actionWithTitle:@"PAT Alimentação"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               textField.text = action.title;
                                                               self.selectedType = CardTypePatAlimentacao;
                                                           }];
    UIAlertAction *patRefeicao = [UIAlertAction actionWithTitle:@"PAT Refeição"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               textField.text = action.title;
                                                               self.selectedType = CardTypePatRefeicao;
                                                           }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       /*
                                                       if (self.selectedType == 0) {
                                                           [self.cardTypeTextField showFieldWithError:NO];
                                                           [self.cardView bringSubviewToFront:self.cardTypeTextField];
                                                       }
                                                       */
                                                   }];
    
    [actionSheet addAction:creditAndDebit];
    
    if ([self.acceptedPaymentTypes containsObject:@(Credit)])
        [actionSheet addAction:credit];
    
    if ([self.acceptedPaymentTypes containsObject:@(Debit)])
        [actionSheet addAction:debit];
    
    if ([self.acceptedPaymentTypes containsObject:@(PatRefeicao)])
        [actionSheet addAction:patRefeicao];
    
    if ([self.acceptedPaymentTypes containsObject:@(PatAlimentacao)])
        [actionSheet addAction:patAlimentacao];
    
    [actionSheet addAction:cancel];
    
    [self.view endEditing:YES];
    [self presentViewController:actionSheet animated:YES completion:nil];
    return NO;
}


- (void)setAccceptedPaymentTypes: (NSArray *) paymentTypes andAcceptedBrands: (NSArray *) brands {
    self.acceptedPaymentTypes = paymentTypes;
    self.acceptedBrands = brands;
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(closeButtonTouched:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    self.descriptionLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    self.descriptionLabel.numberOfLines = 5;
    self.descriptionLabel.textColor = layout.lightFontColor;
    
    
    // Configura o text field
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor clearColor]];
    [self.dataTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.dataTextField.floatLabelFont = [layout fontWithSize:11.0];
    self.dataTextField.floatLabelActiveColor = layout.darkFontColor;
    [self.dataTextField setBottomBorderWithColor: layout.lightGray];
    self.dataTextField.clearButtonMode = UITextFieldViewModeNever;
    self.dataTextField.delegate = self;
    
    self.dataTextField.font = [layout fontWithSize:layout.regularFontSize];
    self.dataTextField.textColor = layout.darkFontColor;
    [self.dataTextField setPlaceholder:@""];
    
    UIView *box = [self.view viewWithTag:77];
    [box setGradientFromColor:layout.primaryColor toColor:layout.gradientColor];


}

@end
