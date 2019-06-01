//
//  StatementItem.h
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatementItemProtocol.h"


@interface StatementItem : NSObject <StatementItemProtocol>

@property double amount;
@property double createdAt;
@property NSInteger status;

@end
