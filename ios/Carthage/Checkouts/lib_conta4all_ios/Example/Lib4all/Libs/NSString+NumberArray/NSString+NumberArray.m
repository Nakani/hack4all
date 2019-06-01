//
//  NSString+NumberArray.m
//  Example
//
//  Created by Cristiano Matte on 14/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

@implementation NSString (NumberArray)

- (NSArray *)toNumberArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.length; i++) {
        int value = [self characterAtIndex:i] - '0';
        
        if (0 <= value && value <= 9) {
            [array addObject:[[NSNumber alloc] initWithInt:value]];
        } else {
            return nil;
        }
        
    }
    
    return array;
}

@end
