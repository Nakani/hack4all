//
//  UIAlertView+Error.m
//  Example
//
//  Created by Adriano Soares on 03/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UIAlertView+Error.h"

@implementation UIAlertView (Error)

+ (UIAlertView *) alertViewForErrorCode: (NSString *)cod andMessage:(NSString *) message {
    NSString *cancelButtonTitle = cod ? @"Entendi" : @"OK";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção!"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    return alert;
}

@end
