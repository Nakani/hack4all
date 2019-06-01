//
//  UIAlertView+Error.h
//  Example
//
//  Created by Adriano Soares on 03/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertView (Error)

+ (UIAlertView *) alertViewForErrorCode: (NSString *)cod andMessage:(NSString *) message;

@end
