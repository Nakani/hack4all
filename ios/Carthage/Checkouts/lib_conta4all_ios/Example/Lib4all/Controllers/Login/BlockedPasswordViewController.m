//
//  BlockedPasswordViewController.m
//  Example
//
//  Created by Cristiano Matte on 15/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "BlockedPasswordViewController.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"
#import "Services.h"
#import "User.h"

@interface BlockedPasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *blockedLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *emailSentLabel;

@end

@implementation BlockedPasswordViewController

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    
    self.emailSentLabel.text = [self.emailSentLabel.text stringByReplacingOccurrencesOfString:@"<email>" withString:_signFlowController.maskedEmailAddress];
}

// MARK: - Actions

- (IBAction)resendEmailButtonTouched {
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
    Services *service = [[Services alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [loadingViewController finishLoading:^{
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };
    
    service.successCase = ^(NSDictionary *response){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"E-mail enviado!"
                                                                       message:@"Confira sua caixa de entrada."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [loadingViewController finishLoading:^{
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };
    
    [loadingViewController startLoading:self title:@"Aguarde..."];
    NSString *identifier = _signFlowController.enteredEmailAddress != nil ? _signFlowController.enteredEmailAddress : _signFlowController.enteredPhoneNumber;
    [service startPasswordRecoveryWithIdentifier:identifier];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Layout

- (void)configureLayout {
    // Configura view
    LayoutManager *layoutManager = [LayoutManager sharedManager];

    self.view.backgroundColor = [layoutManager backgroundColor];
    
    // Configura navigation bar
    self.navigationController.navigationBar.translucent = NO;
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgTitle.image = [UIImage lib4allImageNamed:@"4allwhite"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imgTitle;
    
    self.blockedLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.blockedLabel.textColor = [layoutManager darkFontColor];
    
    self.separatorView.backgroundColor = [layoutManager primaryColor];
    
    self.emailSentLabel.font = [layoutManager fontWithSize:[layoutManager subTitleFontSize]];
    self.emailSentLabel.textColor = [layoutManager darkFontColor];
}

@end
