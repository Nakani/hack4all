//
//  StatementItemProtocol.h
//  Example
//
//  Created by Adriano Soares on 11/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StatementItemProtocol

- (instancetype) initWithJson:(NSDictionary *) json;
- (UIImage *)icon;

- (BOOL) isIncoming;

- (NSString *)statementTitle;

- (NSString *)amountStr;
- (NSString *)statusStr;
- (NSString *)dateStr;

@end
