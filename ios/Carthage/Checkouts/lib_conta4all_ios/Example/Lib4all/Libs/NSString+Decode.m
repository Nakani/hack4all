//
//  NSString+Decode.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 10/01/18.
//  Copyright © 2018 4all. All rights reserved.
//

#import "NSString+Decode.h"

@implementation NSString (Decode)

- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
