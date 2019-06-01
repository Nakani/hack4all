//
//  PPCashInViewController.m
//  Example
//
//  Created by Natanael Ribeiro on 27/11/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPCashInViewController.h"
#import "PrePaidServices.h"
#import "LayoutManager.h"
#import "UIImage+Color.h"
#import "Lib4allPreferences.h"
#import "BaseNavigationController.h"
#import "AnalyticsUtil.h"

@interface PPCashInViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PPCashInViewController

static NSString* const kNavigationTitle = @"Adicionar dinheiro";

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @""  ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}

- (void)configureLayout{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    self.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    NSString *titleLabelString = @"Escolha uma forma para adicionar dinheiro a sua Conta 4all";
    
    NSString *balanceTypeFriendlyName = [Lib4allPreferences sharedInstance].balanceTypeFriendlyName;
    titleLabelString = [titleLabelString stringByReplacingOccurrencesOfString:@"4all" withString:balanceTypeFriendlyName];
    
    NSMutableAttributedString *titleLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Escolha uma forma para adicionar dinheiro a sua Conta %@", balanceTypeFriendlyName]];
    [titleLabelAttributedString addAttribute:NSFontAttributeName value:[layout boldFontWithSize:layout.subTitleFontSize] range:[titleLabelString rangeOfString:[NSString stringWithFormat:@"Conta %@", balanceTypeFriendlyName]]];
    self.titleLabel.attributedText = titleLabelAttributedString;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView reloadData];
    _tableView.scrollEnabled = NO;
}

- (void)configureNavigationBar {

     [((BaseNavigationController *) self.navigationController) configureLayout];
    
    self.navigationItem.title = kNavigationTitle;
    
    if(self.navigationController.viewControllers[0] == self) {
        UIImage *closeButtonImage = [UIImage lib4allImageNamed:@"x"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[closeButtonImage withColor:[LayoutManager sharedManager].lightFontColor]  style:UIBarButtonItemStylePlain target:self action:@selector(didPressCloseButton)];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    UIImageView *imageView = [(UIImageView *) cell viewWithTag:1];
    UILabel *cellTitle = [(UILabel *) cell viewWithTag:2];
    UILabel *description = [(UILabel *) cell viewWithTag:3];
    UIImageView *clickableArrow = [(UIImageView *) cell viewWithTag:4];

    LayoutManager *layout = [LayoutManager sharedManager];
    cellTitle.font = [layout boldFontWithSize:layout.subTitleFontSize];
    description.font = [layout fontWithSize:layout.regularFontSize];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    clickableArrow.image = [clickableArrow.image withColor:layout.darkGray];
    
    if(indexPath.row == 0) {
        imageView.image = [[UIImage lib4allImageNamed:@"payment_slip_barcode"] withColor:layout.secondaryColor];
        [cellTitle setText:@"Boleto"];
        [description setText:@"Saldo disponível em até 2 dias úteis depois do pagamento do boleto."];
        [clickableArrow setHidden:NO];
    } else {
        imageView.image = [[UIImage lib4allImageNamed:@"iconPin"] withColor:layout.secondaryColor];
        [cellTitle setText:@"Depósito"];
        NSString *descrString = @"Você também pode adicionar dinheiro em um dos caixas eletrônicos da Saque e Pague.";
        NSMutableAttributedString *descrAttributedString = [[NSMutableAttributedString alloc] initWithString:descrString];
        [descrAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[descrString rangeOfString:@"Saque e Pague"]];
        [description setAttributedText:descrAttributedString];
        [clickableArrow setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0) {
        
        [AnalyticsUtil logEventWithName:@"cashIn_boleto" andParameters:nil];
        
        UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPCashInPaymentSlips"];
        [self.navigationController pushViewController:destination animated:YES];
    }
//    } else {
//        UIViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"PPCashInMap"];
//        [self.navigationController pushViewController:destination animated:YES];
//    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return YES;
    }
    return NO;
}

- (void)didPressCloseButton {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
