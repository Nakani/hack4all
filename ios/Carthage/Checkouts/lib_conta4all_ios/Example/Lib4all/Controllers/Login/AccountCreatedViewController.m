//
//  AccountCreatedViewController.m
//  Example
//
//  Created by Cristiano Matte on 30/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "AccountCreatedViewController.h"
#import "LayoutManager.h"
#import "User.h"

@interface AccountCreatedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *readyLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;

@end

@implementation AccountCreatedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
}

- (IBAction)closeButtonTouched {
    [_signFlowController viewControllerDidFinish:self];
}

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
    
    self.readyLabel.font = [layoutManager fontWithSize:[layoutManager titleFontSize]];
    self.readyLabel.textColor = [layoutManager darkFontColor];
    
    self.separatorView.backgroundColor = [layoutManager primaryColor];
    
    self.successLabel.font = [layoutManager fontWithSize:[layoutManager subTitleFontSize]];
    self.successLabel.textColor = [layoutManager darkFontColor];
    
    self.navigationItem.hidesBackButton = YES;
}

@end
