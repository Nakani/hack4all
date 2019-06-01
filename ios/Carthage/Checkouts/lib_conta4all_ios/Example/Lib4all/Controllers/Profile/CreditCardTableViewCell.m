//
//  CreditCardTableViewCell.m
//  Example
//
//  Created by Luciano Bohrer on 21/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "CreditCardTableViewCell.h"

@implementation CreditCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)callDeleteEvent:(id)sender{
    _didClickDelete();
}

-(IBAction)callDefaultEvent:(id)sender{
    _didClickDefault();
}

@end
