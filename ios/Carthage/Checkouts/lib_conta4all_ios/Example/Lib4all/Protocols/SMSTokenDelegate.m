//
//  SMSTokenDelegate.m
//  Example
//
//  Created by 4all on 18/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SMSTokenDelegate.h"

@implementation SMSTokenDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{

    if (textField.text.length == 0) {
        [textField setText:@" "];
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextField *nextTextField;
    NSInteger fieldIndex = textField.tag;
    BOOL isBackspace = NO;
    
    //Check if is backspace
    if ([string isEqualToString:@""]) {
        textField.text = @"";
        isBackspace = YES;
        if (fieldIndex > 1) {
            fieldIndex = (textField.tag - 1);
        }
        
    }else{
        
        if (textField.text.length == 0 || (textField.text.length == 1 && [textField.text isEqualToString:@" "])) {
            textField.text = string;
        }
        
        if (fieldIndex < 7) {
            fieldIndex = (textField.tag + 1);
        }
    }
    
    if (fieldIndex == 7) {
        [textField resignFirstResponder];
    }else{
        nextTextField = [[_rootController view] viewWithTag:fieldIndex];
        [nextTextField becomeFirstResponder];
    }
    
    return NO;
}


@end
