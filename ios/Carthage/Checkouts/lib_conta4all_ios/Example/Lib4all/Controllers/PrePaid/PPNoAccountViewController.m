//
//  PPNoAccountViewController.m
//  Example
//
//  Created by Adriano Soares on 06/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPNoAccountViewController.h"
#import "LayoutManager.h"
#import "Lib4allPreferences.h"

@interface PPNoAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;

@end

@implementation PPNoAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self configureLayout];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButtonTouched:(id)sender {
    NSString *link = @"http://4all.com/download_4all_app/";
    NSString *text = [NSString stringWithFormat:@"Oi, gostaria de compartilhar um crédito (em R$) para você usar como quiser no app 4all. Dá para pedir delivery, comprar Ingressos, pagar o estacionamento, recarregar o cartão de transporte e fazer recargas de celular. Baixe o app 4all e aproveite – <LINK>"];
    text = [text stringByReplacingOccurrencesOfString:@"<LINK>" withString:link];
    
    NSArray *message = @[text];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:message applicationActivities:nil];
    
    
    //Somente mail e Message liberados
    NSArray *excludeActivities = @[UIActivityTypePostToFacebook,
                                   UIActivityTypePostToTwitter,
                                   UIActivityTypePostToWeibo,
                                   //UIActivityTypeMessage,
                                   //UIActivityTypeMail,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeAirDrop];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void) configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.noAccountLabel.textColor = [layout darkFontColor];
    self.noAccountLabel.font      = [layout boldFontWithSize:layout.subTitleFontSize];
    
    self.shareLabel.textColor = [layout darkFontColor];
    self.shareLabel.font      = [layout fontWithSize:layout.regularFontSize];
    
    [self.shareLabel setText:[NSString stringWithFormat:@"Aproveite e convide o seu amigo(a) para experimentar a Carteira %@", [Lib4allPreferences sharedInstance].balanceTypeFriendlyName]];

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
