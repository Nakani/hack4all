//
//  Installment.h
//  Example
//
//  Created by Gabriel Miranda Silveira on 28/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Installment : NSObject

//@property (nonatomic, copy) NSNumber *brandId;
//@property BOOL debit;
//@property BOOL credit;
//@property BOOL patAlimentacao;
//@property BOOL patRefeicao;
//@property (nonatomic, copy) NSNumber *minInstallments;
//@property (nonatomic, copy) NSNumber *maxInstallments;
//@property (nonatomic, copy) NSArray *describedInstallments;
@property long numberOfInstallments;
@property long installmentAmount;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
