//
//  StatementItemPayment.m
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "StatementItemPayment.h"
#import "CurrencyUtil.h"
#import "UIImage+Color.h"

@implementation StatementItemPayment


@synthesize amount    = _amount;
@synthesize createdAt = _createdAt;
@synthesize status    = _status;

- (instancetype) initWithJson:(NSDictionary *) json {
    self = [super init];
    if (self) {
        _paymentMode = [json[@"paymentMode"] integerValue];
        _name        = json[@"merchantInfo"][@"name"];
        _amount      = [json[@"amount"] doubleValue];
        _status      = [json[@"status"] integerValue];
        _createdAt   = [json[@"createdAt"] doubleValue];
        
    }
    return self;
}


- (UIImage *)icon {
    UIImage *icon;
    switch (_paymentMode) {
        case 1:
            icon = [UIImage lib4allImageNamed:@"pagamento-cartao"];
            
            break;
        case 2:
            icon = [UIImage lib4allImageNamed:@"pagamento-cartao"];
            
            break;
        case 3:
            icon = [UIImage lib4allImageNamed:@"boleto"];
            icon = [icon withColor:[UIColor blackColor]];
            
            break;
        case 5:
            icon = [UIImage lib4allImageNamed:@"icone_cartao_compartilhado"];
            break;
    }
    
    return icon;
}

- (BOOL)isIncoming {
    return NO;
}

- (NSString *)statementTitle {
    return _name;
}

- (NSString *)amountStr {
    return [CurrencyUtil currencyFormatter:ABS(_amount)];
}

- (NSString *)statusStr {
    NSString *statusStr;
    if (_status == 0 || _status == 1) statusStr = @"Pendente";
    if (_status == 3 || _status == 6) statusStr = @"Concluido";
    if (_status == 4 || _status == 5) statusStr = @"Cancelado";
    if (_status == 7 || _status == 8) statusStr = @"Cancelado";
    return statusStr;
}



@end
