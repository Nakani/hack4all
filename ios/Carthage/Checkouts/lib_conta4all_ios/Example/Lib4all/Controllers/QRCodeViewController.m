//
//  QRCodeViewController.m
//  Example
//
//  Created by Adriano Soares on 30/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "QRCodeViewController.h"
#import "Lib4all.h"
#import "CreditCard.h"
#import "CreditCardsList.h"
#import "LayoutManager.h"

@interface QRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;


@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self generateQRCode];
}

- (void)generateQRCode {
    
    CreditCard *card = [[CreditCardsList sharedList] getDefaultCard];
    
    NSString *qrCodeString = [[Lib4all sharedInstance] generateOfflinePaymentStringForTransactionID:_transactionId cardID:card.cardId amount:_amount campaignUUID: _campaignUUID couponUUID: _couponUUID ];
    NSData *data = [qrCodeString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    CIFilter *filter = 	[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCodeImage = [filter outputImage];
    
    CGFloat scaleX = 250 / qrCodeImage.extent.size.width;
    CGFloat scaleY = 250 / qrCodeImage.extent.size.height;
    
    CIImage *transformedImage = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    _qrCodeImageView.image = [UIImage imageWithCIImage:transformedImage];
    
    
}

- (IBAction)closeVC:(id)sender {
    [self.view endEditing:true];
    [self dismissViewControllerAnimated:true completion:nil];
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
