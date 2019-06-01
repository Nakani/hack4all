//
//  SISUPasswordDataField.h
//  Example
//
//  Created by 4all on 18/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataFieldProtocol.h"


@interface SISUPasswordDataField : NSObject < DataFieldProtocol >
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *cpf;
@end
