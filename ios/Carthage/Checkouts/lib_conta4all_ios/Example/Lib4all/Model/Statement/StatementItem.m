//
//  StatementItem.m
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "StatementItem.h"

@implementation StatementItem

- (instancetype) initWithJson:(NSDictionary *) json {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIImage *)icon {
    return [UIImage lib4allImageNamed:@"pagamento-cartao"];
}


- (NSString *)dateStr {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_createdAt];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *dateStr = [format stringFromDate:date];
    return dateStr;
}

- (BOOL) isIncoming {
    return _amount > 0;
}


- (NSString *)statusStr {
    NSString *statusStr;
    if (_status == 0) statusStr = @"Pendente";
    if (_status == 1) statusStr = @"Concluido";
    if (_status == 2) statusStr = @"Cancelado";
    return statusStr;
}
@end
