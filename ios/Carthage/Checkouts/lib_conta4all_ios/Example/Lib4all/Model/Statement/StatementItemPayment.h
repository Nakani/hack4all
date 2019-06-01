//
//  StatementItemPayment.h
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "StatementItem.h"
#import "StatementItemProtocol.h"

@interface StatementItemPayment : StatementItem <StatementItemProtocol>

@property NSString* name;

@property NSInteger paymentMode;


@end
