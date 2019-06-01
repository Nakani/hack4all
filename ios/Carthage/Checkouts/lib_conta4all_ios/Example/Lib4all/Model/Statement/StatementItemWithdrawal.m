//
//  StatementItemWithdrawal.m
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "StatementItemWithdrawal.h"
#import "CurrencyUtil.h"

@implementation StatementItemWithdrawal

@synthesize amount    = _amount;
@synthesize createdAt = _createdAt;
@synthesize status    = _status;

- (instancetype) initWithJson:(NSDictionary *) json {
    self = [super init];
    if (self) {
        _amount      = [json[@"amount"] doubleValue];
        _createdAt   = [json[@"createdAt"] doubleValue];
        
        _status      = json[@"status"];
        
    }
    

    return self;
}


- (UIImage *)icon {
    UIImage *icon = [UIImage lib4allImageNamed:@"pagamento-cartao"];
    
    return icon;
}

- (NSString *)statementTitle {
    return @"Saque";
}

- (NSString *) amountStr {
    return [CurrencyUtil currencyFormatter:ABS(_amount)];
}



@end
