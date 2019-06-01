//
//  CancellationDetailsViewController.m
//  Example
//
//  Created by Luciano Bohrer on 24/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CancellationDetailsViewController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "ReceiptViewController.h"
#import "UIImage+Color.h"

@interface CancellationDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleAmountToPay;
@property (weak, nonatomic) IBOutlet UILabel *labelAmount;
@property (weak, nonatomic) IBOutlet UILabel *labelMerchantName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@end


@implementation CancellationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureLayout];
}


- (void) configureLayout {
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    self.view.backgroundColor = [UIColor colorWithRed:66.0/255.00 green:66.0/255.00 blue:66.0/255.00 alpha:1.0];
    self.labelTitle.font = [layoutManager fontWithSize:layoutManager.titleFontSize];
    self.labelTitle.textColor = layoutManager.primaryColor;
    
    self.labelTitleAmountToPay.font = [layoutManager fontWithSize:layoutManager.subTitleFontSize];
    self.labelTitleAmountToPay.textColor = layoutManager.lightGray;
    
    self.labelAmount.font = [layoutManager fontWithSize:50];
    self.labelAmount.textColor = layoutManager.primaryColor;
    self.labelAmount.text = [NSString stringWithFormat:@"R$ %.2f", ([[self.transactionInfo amount] doubleValue]/100.0)];
    
    self.labelDate.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelDate.textColor = layoutManager.primaryColor;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    [self.labelDate setText:[formatter stringFromDate:[NSDate new]]];
    
    self.labelMerchantName.font = [layoutManager fontWithSize:layoutManager.regularFontSize];
    self.labelMerchantName.textColor = layoutManager.lightGray;
    self.labelMerchantName.text = [[[self.transactionInfo merchant] name] stringByRemovingPercentEncoding];
    
    self.closeButton.tintColor = layoutManager.lightFontColor;
    
}

- (IBAction)callCancellation:(id)sender {
    
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    Services *client = [[Services alloc] init];
    
    client.successCase = ^(id data) {
        [loading finishLoading:^{
            [self performSegueWithIdentifier:@"segueReceipt" sender:self];
        }];
        
    };
    
    client.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [loading finishLoading:^{
            [[[PopUpBoxViewController alloc] init] show:self
                                           title:@"Atenção"
                                     description:errorMessage
                                       imageMode:Error
                                    buttonAction:nil];
        }];
    };
    
    [loading startLoading:self title:@"Aguarde..."];
    [client refundTransactionWithId:_transactionInfo.transactionID];
}

- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueReceipt"]) {
        ReceiptViewController *destVc = (ReceiptViewController *) segue.destinationViewController;
        destVc.transactionInfo = _transactionInfo;
        destVc.didFinishPayment = _didFinishPayment;
    }
}

@end
