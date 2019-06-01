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
#import <UIKit/UIKit.h>

@implementation DetailsManager

-(UIView *)getConfiguredViewByType:(ReceiptType)receiptType withDataToFill:(NSDictionary *)data{

    switch (receiptType) {
        case ReceiptTypeTransaction:
            return [self configureReceiptTransactionModeWithDataToFill:data];
            
        case ReceiptTypeDeposit:
            return [self configureReceiptDepositModeWithDataToFill:data];
        
        case ReceiptTypeWithdraw:
            return [self configureReceiptWithdrawModeWithDataToFill:data];
            
        case ReceiptTypeTransfer:
            return [self configureReceiptTransferModeWithDataToFill:data];
          
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
    
    
    labelECName.text = ecName;
    labelDate.text   = date;
    
    labelAmountPaid.text = [NSString stringWithFormat:@"Você pagou %@", [self currencyFormatter: amount]];
    
    
    
    
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
            labelPaymentType.text = @"Via cartão de crédito";
            break;
        case 2:
            icon.image = [UIImage lib4allImageNamed:@"pagamento-cartao"];
            labelPaymentType.text = @"Via cartão de débito";
            break;
        case 3:
            icon.image = [UIImage lib4allImageNamed:@"boleto"];
            labelPaymentType.text = @"Via boleto";
            break;
        case 4:
            labelPaymentType.text = @"Via débito automático";
            break;
        case 5:
            icon.image = [UIImage lib4allImageNamed:@"pagamento-saldo-conta"];
            labelPaymentType.text = @"Via saldo da Carteira 4all";
            break;
    }
    //1 - Cartão de Crédito, 2 - Cartão de Débito, 3 - Boleto, 4 - Débito automático, 5 - Saldo da conta pré paga
    
    NSArray *labelsRegular = @[labelDate, labelAddressTitle, labelCodeTitle, labelPaymentTypeTitle];
    
    NSArray *labelsBold = @[labelAmountPaid, labelAddress, labelCode, labelPaymentType];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:13];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:15];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    labelECName.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelECName.textColor = [[LayoutManager sharedManager] primaryColor];
    
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
        label.font = [[LayoutManager sharedManager] fontWithSize:13];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:15];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelTitle.textColor = [[LayoutManager sharedManager] primaryColor];
    
    return contentView;
}

-(UIView *)configureReceiptWithdrawModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPWithdrawDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *date = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount  = ABS([[data objectForKey:@"amount"] doubleValue]);
    double fee     = ABS([[data objectForKey:@"feeAmount"] doubleValue]);
    double total   = amount-fee;
    
    
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelWithdrawTitle    = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelWithdraw         = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelFeeTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelFee              = (UILabel *)[contentView viewWithTag:8];
    
    
    labelDate.text     = date;
    labelAmount.text   = [NSString stringWithFormat:@"Valor sacou %@", [self currencyFormatter:total]];
    labelWithdraw.text = [self currencyFormatter:amount];
    labelFee.text      = [self currencyFormatter:fee];
    
    NSArray *labelsRegular = @[labelDate, labelWithdrawTitle, labelFeeTitle];
    
    NSArray *labelsBold = @[labelAmount, labelWithdraw, labelFee];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:13];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:15];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    labelTitle.textColor = [[LayoutManager sharedManager] darkGray];
    
    return contentView;
}

-(UIView *)configureReceiptTransferModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPTransferDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    BOOL isIncoming    = NO;
    NSString *date     = [self dateFormatter:[[data objectForKey:@"createdAt"] doubleValue]];
    double amount      = [[data objectForKey:@"amount"] doubleValue];
    NSString *peerName = [data objectForKey:@"peerName"];
    NSString *auth     = [data objectForKey:@"p2pTransferId"];
    if (amount >= 0) {
        isIncoming = YES;
    }
    
    
    UIImageView *icon = (UIImageView *)[contentView viewWithTag:1];
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelFromTitle        = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelFrom             = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelToTitle          = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelTo               = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelAuthTitle        = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelAuth             = (UILabel *)[contentView viewWithTag:10];
    
    User *user = [User sharedUser];
    NSString *verb = @"";
    if (isIncoming) {
        labelTo.text = user.fullName;
        labelFrom.text = peerName;
        verb = @"recebeu";
    
    } else {
        labelFrom.text = user.fullName;
        labelTo.text = peerName;
        verb = @"enviou";
    }
    
    labelDate.text   = date;
    labelAmount.text = [NSString stringWithFormat:@"Valor %@ %@", verb, [self currencyFormatter:ABS(amount)]];
    labelAuth.text   = auth;
    
    NSArray *labelsRegular = @[labelDate, labelFromTitle, labelToTitle, labelAuthTitle];
    
    NSArray *labelsBold = @[labelAmount, labelFrom, labelTo, labelAuth];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:13];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:15];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    if (isIncoming) {
        labelTitle.textColor = [[LayoutManager sharedManager] primaryColor];
        icon.image = [UIImage lib4allImageNamed:@"transferencia-para-conta-do-usuario"];
    } else {
        labelTitle.textColor = [[LayoutManager sharedManager] darkGray];
        icon.image = [UIImage lib4allImageNamed:@"transferencia-para-outro-usuario"];
    }

    
    return contentView;
}

-(UIView *)configureReceiptCashInPaymentSlipModeWithDataToFill:(NSDictionary *)data{
    UIView *contentView = [[NSBundle getLibBundle] loadNibNamed:@"PPCashInPaymentSlipDetailsView" owner:self options:nil].firstObject;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSDictionary *payment = [data objectForKey:@"payment"];
    
    NSString *date    = [self dateFormatter:[[payment objectForKey:@"createdAt"] doubleValue]];
    double amount     = ABS([[payment objectForKey:@"amount"] doubleValue]);
    double fee        = ABS([[data objectForKey:@"feeAmount"] doubleValue]);
    double total      = amount-fee;
    
    NSDictionary *paymentSlipData = [payment objectForKey:@"paymentSlipData"];
    
    NSString *barCode    = [paymentSlipData objectForKey:@"typeableLine"];
    
    UILabel *labelTitle            = (UILabel *)[contentView viewWithTag:2];
    UILabel *labelDate             = (UILabel *)[contentView viewWithTag:3];
    UILabel *labelAmount           = (UILabel *)[contentView viewWithTag:4];
    UILabel *labelPaymentTitle     = (UILabel *)[contentView viewWithTag:5];
    UILabel *labelPayment          = (UILabel *)[contentView viewWithTag:6];
    UILabel *labelFeeTitle         = (UILabel *)[contentView viewWithTag:7];
    UILabel *labelFee              = (UILabel *)[contentView viewWithTag:8];
    UILabel *labelBarCodeTitle     = (UILabel *)[contentView viewWithTag:9];
    UILabel *labelBarCode          = (UILabel *)[contentView viewWithTag:10];
    
    labelDate.text    = date;
    labelAmount.text  = [NSString stringWithFormat:@"Valor do crédito %@", [self currencyFormatter:total]];
    labelPayment.text = [self currencyFormatter:amount];
    labelFee.text     = [self currencyFormatter:fee];
    labelBarCode.text = barCode;
    
    NSArray *labelsRegular = @[labelDate, labelPaymentTitle, labelFeeTitle, labelBarCodeTitle];
    
    NSArray *labelsBold = @[labelAmount, labelPayment, labelFee, labelBarCode];
    
    for (UILabel *label in labelsRegular) {
        label.font = [[LayoutManager sharedManager] fontWithSize:13];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    for (UILabel *label in labelsBold) {
        label.font = [[LayoutManager sharedManager] boldFontWithSize:15];
        label.textColor = [[LayoutManager sharedManager] darkGray];
    }
    
    labelTitle.font = [[LayoutManager sharedManager] fontWithSize:[[LayoutManager sharedManager] subTitleFontSize]];
    
    labelTitle.textColor = [[LayoutManager sharedManager] primaryColor];
    
    return contentView;
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

@end
