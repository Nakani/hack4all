//
//  Installment.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 28/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "ServicesConstants.h"
#import "Installment.h"

@implementation Installment

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
//        _brandId = [dictionary valueForKey:BrandIDKey];
//        _debit = [dictionary valueForKey:DebitKey];
//        _credit = [dictionary valueForKey:CreditKey];
//        _patAlimentacao = [dictionary valueForKey:PatAlimentacaoKey];
//        _patRefeicao = [dictionary valueForKey:PatRefeicaoKey];
//        _minInstallments = [dictionary valueForKey:MinInstallmentsKey];
//        _maxInstallments = [dictionary valueForKey:MaxInstallmentsKey];
//        _describedInstallments = [dictionary valueForKey:DescribedInstallmentsKey];
        _numberOfInstallments = [dictionary[NumberOfInstallmentsKey] longValue];
        _installmentAmount = [dictionary[InstallmentAmountKey] longValue];
    }
    
    return self;
}


@end
