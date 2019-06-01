//
//  QRCodeMerchantOfflineViewController.m
//  Example
//
//  Created by 4all on 20/02/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "QRCodeMerchantOfflineViewController.h"
#import "LayoutManager.h"

@interface QRCodeMerchantOfflineViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;

@end

@implementation QRCodeMerchantOfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LayoutManager *layout = [LayoutManager sharedManager];
    
    _labelMessage.font = [layout fontWithSize:layout.regularFontSize];
    _labelMessage.textColor = layout.darkFontColor;
    
    NSData *data = [_contentQRCode dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    CIFilter *filter = 	[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCodeImage = [filter outputImage];
    
    CGFloat scaleX = 250 / qrCodeImage.extent.size.width;
    CGFloat scaleY = 250 / qrCodeImage.extent.size.height;
    
    CIImage *transformedImage = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    _qrCodeImageView.image = [UIImage imageWithCIImage:transformedImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
