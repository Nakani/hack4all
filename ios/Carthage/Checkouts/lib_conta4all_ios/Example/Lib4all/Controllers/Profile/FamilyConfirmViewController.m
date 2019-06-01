//
//  FamilyConfirmViewController.m
//  Example
//
//  Created by Adriano Soares on 19/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "FamilyConfirmViewController.h"
#import "BaseNavigationController.h"
#import "LayoutManager.h"
#import "CreditCard.h"
#import "CreditCardsList.h"
#import "NSStringMask.h"
#import "FamilyProfileTableViewController.h"
#import "FamilyAdvancedTableViewController.h"

#import "User.h"
#import "Services.h"
#import "LoadingViewController.h"
#import "UIImageView+WebCache.h"

@interface FamilyConfirmViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *cardLabel;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *cardHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardBrandImageView;

@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitNumberLabel;


@end

@implementation FamilyConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.ownerNameLabel.text = [[User sharedUser] fullName];
        
    self.phoneNumberLabel.text = (NSString *)[NSStringMask maskString:self.phoneNumber withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
    
    self.sharedDetails = @{
                           @"recurringBalance"       : [NSNumber numberWithDouble:self.amount],
                           @"transactionPriceLimit"  : [NSNull null],
                           @"totalTransactionsLimit" : [NSNull null],
                           @"expirationDate"         : [NSNull null],
                           @"weekdays"               :@[ @0, @1, @2, @3, @4, @5, @6 ],
                           @"schedules"              :@[ @{ @"start": @"00:00:00", @"end": @"23:59:59" }]
                          };
    
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CreditCard *card = [[CreditCardsList sharedList] getCardWithID: self.cardID];
    self.cardNumberLabel.text = [card getMaskedPan];
    [self.cardBrandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]] placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
    
    switch (card.type) {
        case CardTypeDebit:
            self.cardHolderLabel.text = @"DÉBITO";
            break;
        case CardTypeCredit:
            self.cardHolderLabel.text = @"CRÉDITO";
            break;
        case CardTypeCreditAndDebit:
            self.cardHolderLabel.text = @"CRÉDITO E DÉBITO";
            break;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.limitNumberLabel.text = [[formatter stringFromNumber: [NSNumber numberWithFloat:self.amount/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CreditCard *card = [[CreditCardsList sharedList] getCardWithID: self.cardID];
    self.cardNumberLabel.text = [card getMaskedPan];
    [self.cardBrandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]] placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
    
    switch (card.type) {
        case CardTypeDebit:
            self.cardHolderLabel.text = @"DÉBITO";
            break;
        case CardTypeCredit:
            self.cardHolderLabel.text = @"CRÉDITO";
            break;
        case CardTypeCreditAndDebit:
            self.cardHolderLabel.text = @"CRÉDITO E DÉBITO";
            break;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.limitNumberLabel.text = [[formatter stringFromNumber: [NSNumber numberWithFloat:self.amount/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    self.navigationItem.title = @"Confirmar";
    
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    self.titleLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.titleLabel.textColor = [layoutManager darkFontColor];

    self.ownerLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.ownerLabel.textColor = [layoutManager darkFontColor];
    self.ownerNameLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.ownerNameLabel.textColor = [layoutManager darkFontColor];

    
    self.phoneLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.phoneLabel.textColor = [layoutManager darkFontColor];
    self.phoneNumberLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.phoneNumberLabel.textColor = [layoutManager darkFontColor];

    self.cardLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.cardLabel.textColor = [layoutManager darkFontColor];
    
    self.limitLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.limitLabel.textColor = [layoutManager darkFontColor];
    self.limitNumberLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.limitNumberLabel.textColor = [layoutManager darkFontColor];

    
    self.cardView.layer.cornerRadius        = 5;
    self.cardView.layer.shadowOffset        = CGSizeMake(0, 1);
    self.cardView.layer.shadowRadius        = 2;
    self.cardView.layer.shadowColor         = [layoutManager darkGray].CGColor;
    self.cardView.layer.shadowOpacity       = 0.5;
    
    self.cardHolderLabel.font = [layoutManager fontWithSize:layoutManager.midFontSize];
    self.cardNumberLabel.font = [layoutManager fontWithSize:layoutManager.midFontSize];
    
}

- (IBAction)cancelClicked:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:@"Realmente deseja cancelar?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sim"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Não"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


- (IBAction)confirmClicked:(id)sender {
    Services *service = [[Services alloc] init];
    
    LoadingViewController *loader = [[LoadingViewController alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [loader finishLoading:^{
            [self presentViewController:alert animated:YES completion:nil];
        }];

    };
    
    service.successCase = ^(NSDictionary *response) {
        [loader finishLoading:^{
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[FamilyProfileTableViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
        }];
        
    };
    
    NSString *phoneNumber = [NSString stringWithFormat:@"55%@", self.phoneNumber];
    
    [service addSharedCard:self.cardID
               phoneNumber:phoneNumber
               withData:self.sharedDetails
              intervalType:@2
             intervalValue:@1];
    
    [loader startLoading:self title:@"Aguarde..."];
}

- (IBAction)advancedOptionsClicked:(id)sender {
    FamilyAdvancedTableViewController *vc = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                                  instantiateViewControllerWithIdentifier:@"FamilyAdvancedTableViewController"];
    
    vc.sharedDetails = [[NSMutableDictionary alloc] initWithDictionary:self.sharedDetails];
    
    vc.cardID = self.cardID;
    vc.isCreation = YES;

    vc.completion = ^(NSString *cardID, NSDictionary *sharedDetails) {
        self.cardID = cardID;
        self.sharedDetails = sharedDetails;
        self.amount = [sharedDetails[@"recurringBalance"] doubleValue];
    };
    
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:YES completion:nil];
}


@end
