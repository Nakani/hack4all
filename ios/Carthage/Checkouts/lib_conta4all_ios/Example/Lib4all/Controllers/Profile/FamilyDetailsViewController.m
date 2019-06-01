//
//  FamilyDetailsViewController.m
//  Example
//
//  Created by Adriano Soares on 20/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "FamilyDetailsViewController.h"
#import "FamilySetBalanceViewController.h"
#import "BaseNavigationController.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "User.h"
#import "FamilyProfileTableViewController.h"
#import "FamilyAdvancedTableViewController.h"
#import "CreditCardsList.h"

@interface FamilyDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *organizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *avaliableLabel;
@property (weak, nonatomic) IBOutlet UILabel *avaliableValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *limitDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeLimitButton;

@property double spentAmount;

@end

@implementation FamilyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void) reloadData {
    double balance          = [_sharedDetails[@"balance"] doubleValue];;
    double recurringBalance = [_sharedDetails[@"recurringBalance"] doubleValue];
    
    _spentAmount = 0;
    id lastRecurringDate = [self.sharedDetails valueForKey:@"lastRecurringDate"];
    if (lastRecurringDate &&  lastRecurringDate != [NSNull null]) {
        _spentAmount      = recurringBalance - balance;
    }
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.totalNumberLabel.text    = [[formatter stringFromNumber: [NSNumber numberWithFloat:_spentAmount/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    self.avaliableValueLabel.text = [[formatter stringFromNumber: [NSNumber numberWithFloat:balance/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    self.limitValueLabel.text     = [[formatter stringFromNumber: [NSNumber numberWithFloat:recurringBalance/100]] stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    
    id recurringDate = [self.sharedDetails valueForKey:@"nextRecurringDate"];
    id recurringDay = [self.sharedDetails valueForKey:@"recurrenceDay"];
    self.limitDateLabel.text = @"Limite restabelecido todo dia <day>";
    if (recurringDay && recurringDay  != [NSNull null]) {
        self.limitDateLabel.text      = [self.limitDateLabel.text stringByReplacingOccurrencesOfString:@"<day>" withString:[recurringDay stringValue]];
    } else if (recurringDate && recurringDate  != [NSNull null]) {
        NSString *day = [recurringDate substringFromIndex:((NSString *)recurringDate).length - 2];
        self.limitDateLabel.text      = [self.limitDateLabel.text stringByReplacingOccurrencesOfString:@"<day>" withString:day];
    } else {
        self.limitDateLabel.hidden = YES;
    }
    
    if ([_sharedDetails[@"provider"] boolValue] == YES) {
        self.organizerValueLabel.text = [User sharedUser].fullName;
        self.recipientValueLabel.text = _sharedDetails[@"identifier"];
    } else {
        [self.changeLimitButton removeFromSuperview];
        
        self.organizerValueLabel.text = _sharedDetails[@"identifier"];
        self.recipientValueLabel.text = [User sharedUser].fullName;
    }

}

- (IBAction)changeLimitButtonTouched {
    FamilyAdvancedTableViewController *vc = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                             instantiateViewControllerWithIdentifier:@"FamilyAdvancedTableViewController"];
    
    vc.sharedDetails = [[NSMutableDictionary alloc] initWithDictionary:self.sharedDetails];
    
    vc.cardID = self.cardID;
    vc.isCreation = NO;
    
    
    vc.completion = ^(NSString *cardID, NSDictionary *sharedDetails) {
        self.cardID = cardID;
        self.sharedDetails = [sharedDetails mutableCopy];
        
        double recurringBalance = [_sharedDetails[@"recurringBalance"] doubleValue];
        double balance = (recurringBalance - self.spentAmount);
        [_sharedDetails setValue:[NSNumber numberWithDouble:balance] forKey:@"balance"];
    };
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:YES completion:nil];
    /*
    FamilySetBalanceViewController *viewController = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                                      instantiateViewControllerWithIdentifier:@"FamilySetBalanceViewController"];
    
    
    viewController.completion = ^(double amount) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        NSString *message = [NSString stringWithFormat:@"Confirmar a alteração do limite para %@?", [formatter stringFromNumber: [NSNumber numberWithFloat:amount/100]]] ;
        message = [message stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Sim"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        Services *service = [[Services alloc] init];
                                        LoadingViewController *loader = [[LoadingViewController alloc] init];
                                        
                                        service.failureCase = ^(NSString *cod, NSString *msg){
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
                                        
                                        service.successCase = ^(NSDictionary *response){
                                            [loader finishLoading:^{
                                                for (UIViewController *controller in self.navigationController.viewControllers) {
                                                    if ([controller isKindOfClass:[FamilyProfileTableViewController class]]) {
                                                        [self.navigationController popToViewController:controller animated:YES];
                                                        break;
                                                    }
                                                }
                                            }];
                                        };
                                        
                                        [loader startLoading:self title:@"Aguarde..."];
                                        [service updateSharedCard:_cardID custumerId:_sharedDetails[@"customerId"] withBalance:[[NSNumber alloc] initWithDouble:amount]];
                                        
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Não"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    };
    
    [self.navigationController pushViewController:viewController animated:YES];
    */
}

- (IBAction)excludeShared:(id)sender {
    NSString *message = @"Realmente deseja excluir?";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Sim"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    Services *service = [[Services alloc] init];
                                    LoadingViewController *loader = [[LoadingViewController alloc] init];
                                    
                                    service.failureCase = ^(NSString *cod, NSString *msg) {
                                        [loader finishLoading:nil];
                                    };
                                    
                                    service.successCase = ^(NSDictionary *response) {
                                        Services *listCardService = [[Services alloc] init];
                                        
                                        listCardService.failureCase = ^(NSString *cod, NSString *msg) {
                                            [loader finishLoading:^{
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                                            
                                        };
                                        
                                        listCardService.successCase = ^(NSDictionary *response) {
                                            [loader finishLoading:^{
                                                [[CreditCardsList sharedList] saveSharingCards];
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];

                                        };
                                        
                                        [listCardService listCards];

                                    };
                                    
                                    [service deleteSharedCard:self.cardID custumerId:[self.sharedDetails valueForKey:CustomerIdKey]];
                                    
                                    [loader startLoading:self title:@"Aguarde..."];
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

- (void)configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Detalhes";

    LayoutManager *layoutManager = [LayoutManager sharedManager];
    self.view.backgroundColor = [layoutManager backgroundColor];

    self.organizerLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.organizerValueLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.organizerLabel.textColor = [layoutManager darkFontColor];
    self.organizerValueLabel.textColor = [layoutManager darkFontColor];
    
    self.recipientLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.recipientValueLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.recipientLabel.textColor = [layoutManager darkFontColor];
    self.recipientValueLabel.textColor = [layoutManager darkFontColor];
    
    self.totalLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.totalNumberLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.totalLabel.textColor = [layoutManager darkFontColor];
    self.totalNumberLabel.textColor = [layoutManager darkFontColor];
    
    self.avaliableLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.avaliableValueLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.avaliableLabel.textColor = [layoutManager darkFontColor];
    self.avaliableValueLabel.textColor = [layoutManager darkFontColor];
    
    self.limitLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.limitValueLabel.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.limitLabel.textColor = [layoutManager darkFontColor];
    self.limitValueLabel.textColor = [layoutManager darkFontColor];
    
    self.limitDateLabel.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.limitDateLabel.textColor = [layoutManager darkFontColor];
}

@end
