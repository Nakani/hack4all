//
//  DetailsManager.m
//  Example
//
//  Created by Luciano Acosta on 12/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "DetailsManager.h"
#import "LayoutManager.h"
#import "User.h"
#import "PrePaidServices.h"
#import "Services.h"
#import "UIImage+Color.h"
#import "Lib4allPreferences.h"

#import <UIKit/UIKit.h>
#import "DateUtil.h"
#import "AMPopTip.h"

@interface DetailsManager ()

@property NSString *barCode;
@property NSString *paymentId;
@property UIView *contentView;

@end

@implementation DetailsManager


+ (instancetype)sharedManager {
    static DetailsManager *sharedInstance = nil;
    
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}


-(UIView *)getConfiguredViewByType:(ReceiptType)receiptType withDataToFill:(NSDictionary *)data withCardCashInFees: (NSArray *)fees{

    switch (receiptType) {
        case ReceiptTypeTransaction:
            return [self configureReceiptTransactionModeWithDataToFill:data];
            
        case ReceiptTypeDeposit:
            return [self configureReceiptDepositModeWithDataToFill:data];
        
        case ReceiptTypeWithdraw:
            return [self configureReceiptWithdrawModeWithDataToFill:data];
            
        case ReceiptTypeTransfer:
            return [self configureReceiptTransferModeWithDataToFill:data withFees: fees];
          
        case ReceiptTypeCashInPaymentSlip:
            return [self configureReceiptCashInPaymentSlipModeWithDataToFill:data];
        default:
            break;
    }
    
    return nil;
}


-(UIView *)configureReceiptTransactionModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPTransactionDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *date    = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount     = ABS([[data objectForKey:@"amount"] doubleValue]);
    
    NSInteger paymentMode = [[data objectForKey:@"paymentMode"] integerValue];
    
    NSString *code    = [data objectForKey:@"paymentId"];
    
    NSDictionary *merchantInfo = [data objectForKey:@"merchantInfo"];
    NSString *ecName           = [merchantInfo objectForKey:@"name"];
    NSString *streetAddress    = [merchantInfo objectForKey:@"streetAddress"];
    NSString *city             = [merchantInfo objectForKey:@"city"];
    NSString *state            = [merchantInfo objectForKey:@"state"];
    
    
    UIImageView *icon              = (UIImageView *)[contentView viewWithTag:1];
    UILabel *labelECName           = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmountPaid       = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelAddressTitle     = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelAddress          = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelCodeTitle        = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelCode             = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelPaymentTypeTitle = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelPaymentType      = (UILabel *)[contentView viewWithTag:10];
    UILabel *labelStatus           = (UILabel *)[contentView viewWithTag:11];
    UILabel *labelReason           = (UILabel *)[contentView viewWithTag:12];
    
    
    
    
    labelECName.text = ecName;
    labelDate.text   = date;
    
    labelAmountPaid.text = [NSString stringWithFormat:@"Você gastou %@", [self currencyFormatter: amount]];
    
    
    
    
    if (streetAddress) {
        labelAddress.text = [NSString stringWithFormat:@"%@ - %@/%@", streetAddress, city, state];
    } else {
        [labelAddressTitle setHidden:YES];
        [labelAddress setHidden:YES];
    
    }
    
    labelCode.text = code;
    
    
    switch (paymentMode) {
        case 1:
            icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
            labelPaymentType.text = @"Cartão de crédito";
            break;
        case 2:
            icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
            labelPaymentType.text = @"Cartão de débito";
            break;
        case 3:
            icon.image = [UIImage lib4allImageNamed:@"boleto"];
            icon.image = [icon.image withColor:[UIColor blackColor]];
            labelPaymentType.text = @"Boleto";
            break;
        case 4:
            labelPaymentType.text = @"Débito automático";
            break;
        case 5:
            icon.image = [UIImage lib4allImageNamed:@"pagamento-saldo-conta"];
            labelPaymentType.text = [NSString stringWithFormat:@"Via saldo da Carteira %@", [Lib4allPreferences sharedInstance].balanceTypeFriendlyName];
            break;
    }
    //1 - Cartão de Crédito, 2 - Cartão de Débito, 3 - Boleto, 4 - Débito automático, 5 - Saldo da conta pré paga
    
    
    // 28/07/2017 - Mudança feita a pedido do Bruno para tratar os estados de não aprovado
    NSInteger status = [[data objectForKey:@"status"] integerValue];
    if (status == 2) {
        labelStatus.text = @"Cancelado";
        labelReason.text = [data objectForKey:@"reasonMessage"];
    
    } else {
        labelStatus.text = [data objectForKey:@"reasonMessage"];
        [labelReason setHidden:YES];
    }
    

    
    NSArray *labelsRegular = @[labelDate, labelAddressTitle, labelCodeTitle, labelPaymentTypeTitle, labelStatus, labelReason];
    
    NSArray *labelsBold = @[labelAmountPaid, labelAddress, labelCode, labelPaymentType];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    labelECName.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelECName.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    id familyProfileInfo = [data objectForKey:@"familyProfileInfo"];
    if (familyProfileInfo && familyProfileInfo != [NSNull null]) {
        icon.image = [UIImage lib4allImageNamed:@"pagamento-saldo-conta"];
        labelPaymentType.text = [NSString stringWithFormat:@"Perfil família - cartão compartilhado com %@", [familyProfileInfo objectForKey: @"dependentName"]];
        labelPaymentType.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        
        
        NSMutableAttributedString *att = [[labelPaymentType attributedText] mutableCopy];
        
        [att addAttribute:NSFontAttributeName
                    value:[[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]]
                    range:[labelPaymentType.text rangeOfString:@"Perfil família"]];
        
        labelPaymentType.attributedText = att;
    }
    
    
    if (status == 2 || status == 5 || status == 7) {
        NSMutableAttributedString *att = [[labelAmountPaid attributedText] mutableCopy];
        
        [att addAttribute:NSStrikethroughStyleAttributeName
                    value:@1
                    range:NSMakeRange(0, att.length)];
        
        labelAmountPaid.attributedText = att;
    
    }
    
    return contentView;
}


-(UIView *)configureReceiptDepositModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPDepositDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *date    = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount     = ABS([[data objectForKey:@"amount"] doubleValue]);
    double fee        = ABS([[data objectForKey:@"feeAmount"] doubleValue]);
    double total      = amount-fee;
    NSString *auth    = [data objectForKey:@"depositId"];
    
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelDepositTitle     = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelDeposit          = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelFeeTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelFee              = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelAuthTitle        = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelAuth             = (UILabel *)[contentView viewWithTag:10];
    
    labelDate.text    = date;
    labelAmount.text  = [NSString stringWithFormat:@"Valor do crédito %@", [self currencyFormatter:total]];
    labelDeposit.text = [self currencyFormatter:amount];
    labelFee.text     = [self currencyFormatter:fee];
    labelAuth.text    = auth;
    
    NSArray *labelsRegular = @[labelDate, labelDepositTitle, labelFeeTitle, labelAuthTitle];
    
    NSArray *labelsBold = @[labelAmount, labelDeposit, labelFee, labelAuth];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelTitle.textColor = [[LayoutManager sharedManager] primaryColor];
    
    return contentView;
}

-(UIView *)configureReceiptWithdrawModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPWithdrawDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *date = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount  = ABS([[data objectForKey:@"amount"] doubleValue]);
    double fee     = ABS([[data objectForKey:@"feeAmount"] doubleValue]);
    double total   = amount+fee;
    
    
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelWithdrawTitle    = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelWithdraw         = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelFeeTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelFee              = (UILabel *)[contentView viewWithTag:8];
    
    
    labelDate.text     = date;
    labelAmount.text   = [NSString stringWithFormat:@"Valor sacou %@", [self currencyFormatter:amount]];
    labelWithdraw.text = [self currencyFormatter:total];
    labelFee.text      = [self currencyFormatter:fee];
    
    NSArray *labelsRegular = @[labelDate, labelWithdrawTitle, labelFeeTitle];
    
    NSArray *labelsBold = @[labelAmount, labelWithdraw, labelFee];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    labelTitle.textColor = [[LayoutManager sharedManager] darkFontColor];
    
    return contentView;
}

-(UIView *)configureReceiptTransferModeWithDataToFill:(NSDictionary *)data withFees:(NSArray *)fees {
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPTransferDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    BOOL isIncoming         = NO;
    NSString *date          = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount           = [[data objectForKey:@"amount"] doubleValue];
    NSString *peerName      = [data objectForKey:@"peerName"];
    NSString *auth          = [data objectForKey:@"p2pTransferId"];
    NSString *paymentMethod = @"Saldo da conta";
    double currentFee       = -1;
    
    if (amount >= 0) {
        isIncoming = YES;
    }
    
    
    UIImageView *icon = (UIImageView *)[contentView viewWithTag:1];
    UILabel *labelTitle               = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate                = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmountHeader        = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelFromTitle           = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelFrom                = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelAmountTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelAmount              = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelFeeTitle            = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelFee                 = (UILabel *)[contentView viewWithTag:10];
    UILabel *labelAuthTitle           = (UILabel *)[contentView viewWithTag:11];
    UILabel *labelAuth                = (UILabel *)[contentView viewWithTag:12];
    UILabel *labelPaymentMethodTitle  = (UILabel *)[contentView viewWithTag:13];
    UILabel *labelPaymentMethod       = (UILabel *)[contentView viewWithTag:14];
    UIView  *feeDivisor               = (UIView *) [contentView viewWithTag:15];
    
    NSString *verb = @"";
    if (isIncoming) {
        labelFromTitle.text = @"De";
        labelFrom.text = peerName;
        verb = @"recebeu";
    
    } else {
        labelFromTitle.text = @"Para";
        labelFrom.text = peerName;
        verb = @"enviou";
    }
    
    if([data objectForKey:@"paymentId"] != [NSNull null]) {
        paymentMethod =  @"Cartão de crédito";
        
        double absAmount = ABS(amount);
        for(NSDictionary *fee in fees) {
            double minValue = [[fee valueForKey:@"min"] intValue];
            double maxValue = [[fee valueForKey:@"max"] intValue];
            if(absAmount >= minValue && absAmount <= maxValue) {
                currentFee = [[fee valueForKey:@"fee"] intValue];
            }
        }
        if(currentFee >= 0) {
            labelFee.text = [self currencyFormatter:currentFee];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            for(NSLayoutConstraint *constraint in contentView.constraints) {
                if ([constraint.identifier isEqualToString:@"labelFeeTitleTop"]) {
                    constraint.constant = -16;
                }
            }
            for(NSLayoutConstraint *constraint in labelFeeTitle.constraints) {
                if ([constraint.identifier isEqualToString:@"labelFeeTitleHeight"]) {
                    constraint.constant = 0;
                }
            }
            for(NSLayoutConstraint *constraint in labelFee.constraints) {
                if ([constraint.identifier isEqualToString:@"labelFeeHeight"]) {
                    constraint.constant = 0;
                }
            }
        feeDivisor.hidden = YES;
        });
    }
    
    labelDate.text          = date;
    labelAmountHeader.text  = [NSString stringWithFormat:@"Você %@ %@", verb, [self currencyFormatter:ABS(amount)]];
    labelAmount.text        = [self currencyFormatter:ABS(amount)];
    labelAuth.text          = auth;
    labelPaymentMethod.text = paymentMethod;
    
    NSArray *labelsRegular = @[labelDate, labelFromTitle, labelAmountTitle, labelFeeTitle, labelAuthTitle, labelPaymentMethodTitle];
    
    NSArray *labelsBold = @[labelAmount, labelFrom, labelAmount, labelFee, labelAuth, labelPaymentMethod];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    if (isIncoming) {
        labelTitle.textColor = [[LayoutManager sharedManager] lightGreen];
        icon.image = [UIImage lib4allImageNamed:@"transferencia-para-conta-do-usuario"];
    } else {
        labelTitle.textColor = [[LayoutManager sharedManager] darkFontColor];
        icon.image = [UIImage lib4allImageNamed:@"transferencia-para-outro-usuario"];
    }

    
    return contentView;
}

-(UIView *)configureReceiptCashInPaymentSlipModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPCashInPaymentSlipDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSDictionary *payment = [data objectForKey:@"payment"];
    
    NSString *date    = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount     = ABS([[payment objectForKey:@"amount"] doubleValue]);
    double fee        = ABS([[data objectForKey:@"feeAmount"] doubleValue]);
    double total      = amount-fee;
    
    NSDictionary *paymentSlipData = [payment objectForKey:@"paymentSlipData"];
    
    if ([paymentSlipData isEqual:[NSNull null]]) {
        return nil;
    }
    NSString *barCode    = [paymentSlipData objectForKey:@"typeable_line"];
    
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelPaymentTitle     = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelPayment          = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelFeeTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelFee              = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelDueDateTitle     = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelDueDate          = (UILabel *)[contentView viewWithTag:10];
    UILabel *labelBarCodeTitle     = (UILabel *)[contentView viewWithTag:11];
    UILabel *labelBarCode          = (UILabel *)[contentView viewWithTag:12];
    UILabel *labelStatus           = (UILabel *)[contentView viewWithTag:15];
    
    labelDate.text    = date;
    labelAmount.text  = [NSString stringWithFormat:@"Valor do boleto %@", [self currencyFormatter:amount]];
    labelPayment.text = [self currencyFormatter:total];
    labelFee.text     = [NSString stringWithFormat:@"%@ (descontada do valor do boleto)", [self currencyFormatter:fee]];
    labelDueDate.text = [DateUtil convertDateString:[paymentSlipData objectForKey:@"due_date"] fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
    labelBarCode.text = barCode;
    
    NSString *statusStr;
    
    id status = [data objectForKey:@"status"];

    if (status) {
        if([status intValue] == 0) statusStr = @"Pendente";
        if([status intValue] == 1) statusStr = @"Concluido";
        if([status intValue] == 2) statusStr = @"Cancelado";
    }
    
    labelStatus.text = statusStr;
    
    NSArray *labelsRegular = @[labelDate, labelPaymentTitle, labelFeeTitle, labelDueDateTitle, labelBarCodeTitle, labelStatus];
    
    NSArray *labelsBold = @[labelAmount, labelPayment, labelFee, labelDueDate, labelBarCode];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] midFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] regularFontSize]];
        label.textColor = [[LayoutManager sharedManager] darkFontColor];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] boldFontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelTitle.textColor = [[LayoutManager sharedManager] lightGreen];
    
    UIButton *buttonCopy = [contentView viewWithTag:13];
    UIButton *buttonEmail = [contentView viewWithTag:14];
    
    if ([status integerValue] != 0) {
        [buttonCopy removeFromSuperview];
        [buttonEmail removeFromSuperview];
    }
    
    
    [buttonCopy addTarget:self action:@selector(copyTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.barCode = barCode;
    self.paymentId = [payment objectForKey:@"paymentId"];

    [buttonCopy addTarget:self action:@selector(copyTouched:) forControlEvents:UIControlEventTouchUpInside];
    [buttonEmail addTarget:self action:@selector(sendEmailTouched:) forControlEvents:UIControlEventTouchUpInside];

    NSMutableAttributedString *att = [[labelFee attributedText] mutableCopy];
    
    [att addAttribute:NSFontAttributeName
                value:[[LayoutManager sharedManager] fontWithSize:13]
                range:[labelFee.text rangeOfString:@"(descontada do valor do boleto)"]];
    
    labelFee.attributedText = att;

    if([status integerValue] != 0) {
        [labelBarCodeTitle removeFromSuperview];
        [labelBarCode removeFromSuperview];
    
    }
    
    if([status integerValue] == 1) {
        [labelDueDateTitle removeFromSuperview];
        [labelDueDate removeFromSuperview];
        
    }
    
    self.contentView = contentView;
    return contentView;
}

- (void)copyTouched:(id)sender {
    UIPasteboard.generalPasteboard.string = self.barCode;
    [self displayToolTip:sender withMessage:@"Código copiado!"];
}


- (void)sendEmailTouched:(id)sender {
    LoadingViewController *loading = [[LoadingViewController alloc] init];
    
    [loading startLoading:[self topViewController]
                    title:@"Aguarde..." completion:^{
                        Services *services = [[Services alloc] init];
                        
                        services.failureCase = ^(NSString *cod, NSString *msg) {
                            [loading finishLoading:^{
                                PopUpBoxViewController *modal = [[PopUpBoxViewController alloc] init];
                                [modal show:[self topViewController]
                                      title:@"Atenção!"
                                description:msg
                                  imageMode:Error
                               buttonAction:nil];
                            }];
                        };
                        
                        services.successCase = ^(NSDictionary *response) {
                            [loading finishLoading:^{
                                [self displayToolTip:sender withMessage:@"Enviado para o seu e-mail!"];
                            }];
                        };
                        
                        [services resendEmailPaymentSlip:self.paymentId];
                    }];

}


- (void) displayToolTip:(UIView *) parent withMessage:(NSString *) message{
    LayoutManager *layout = [LayoutManager sharedManager];
    
    AMPopTip *appearance = [AMPopTip appearance];
    appearance.textColor = layout.lightFontColor;
    appearance.popoverColor = [layout primaryColor];
    
    AMPopTip *popTip = [AMPopTip popTip];
    
    
    [popTip showText:message direction:AMPopTipDirectionUp maxWidth:200 inView:self.contentView fromFrame:parent.frame];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [popTip hide];
    });
    
    
}

-(NSString *) dateFormatter:(double) date {
    NSDate *createdAt            = [NSDate dateWithTimeIntervalSince1970:date/1000];
    NSDateFormatter *dateFormat  = [[NSDateFormatter alloc] init];
    dateFormat.calendar          = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormat.dateFormat        = @"dd 'de' MMMM 'de' yyyy";
    dateFormat.locale            = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    return [dateFormat stringFromDate:createdAt];
}

-(NSString *) currencyFormatter:(double) amount {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *value = [formatter stringFromNumber: [NSNumber numberWithFloat:amount/100]];
    value = [value stringByReplacingOccurrencesOfString:@"R$" withString:@"R$ "];
    return value;
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
