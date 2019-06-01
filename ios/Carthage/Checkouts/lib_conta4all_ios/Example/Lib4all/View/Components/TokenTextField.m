//
//  TokenTextField.m
//  Example
//
//  Created by 4all on 02/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "TokenTextField.h"

@implementation TokenTextField


-(void)deleteBackward{
    [super deleteBackward];
    
    if ([self.text isEqualToString:@""] && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
    }
}

@end
