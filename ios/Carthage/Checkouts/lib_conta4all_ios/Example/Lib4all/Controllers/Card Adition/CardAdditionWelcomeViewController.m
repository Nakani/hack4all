//
//  CardAdditionWelcomeViewController.m
//  Example
//
//  Created by Cristiano Matte on 07/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CardAdditionWelcomeViewController.h"
#import "LayoutManager.h"
#import "User.h"
#import "BaseNavigationController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"
#import "AnalyticsUtil.h"
#import "Lib4allPreferences.h"

@interface CardAdditionWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CardAdditionWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AnalyticsUtil createScreenViewWithName:@"permissao_cadastro_cartao"];
    
    [self configureLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureLayout];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Cartão";
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
}

- (IBAction)continueButtonTouched {
    [AnalyticsUtil createEventWithCategory:@"account" action:@"add card" label:@"add first card" andValue:nil];
    [_flowController viewControllerDidFinish:self];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureLayout {
    
    // Configura navigation bar
    self.navigationItem.title = @"Cartão";
    
    // Configura view
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    self.view.backgroundColor = [layoutManager backgroundColor];
    
    self.titleLabel.font = [layoutManager fontWithSize:[layoutManager subTitleFontSize]];
    self.titleLabel.textColor = layoutManager.lightFontColor;
    
    NSString *firstName = [[User sharedUser].fullName componentsSeparatedByString:@" "][0];
    if (firstName == nil) {
        firstName = @"";
    }
    self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"<name>" withString:firstName];
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:_titleLabel.text];
    
    NSRange range = [_titleLabel.text rangeOfString:@"cadastre um cartão"];
    
    [attrTitle addAttribute: NSFontAttributeName value:[layoutManager boldFontWithSize:layoutManager.subTitleFontSize] range:range];
    [_titleLabel setAttributedText:attrTitle];
    

}

@end
