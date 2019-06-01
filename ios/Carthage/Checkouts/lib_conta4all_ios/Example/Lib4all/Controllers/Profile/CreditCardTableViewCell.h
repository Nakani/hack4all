//
//  CreditCardTableViewCell.h
//  Example
//
//  Created by Luciano Bohrer on 21/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface CreditCardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageCardIcon;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkBoxDefault;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UILabel *labelTypeCard;
@property (weak, nonatomic) IBOutlet UILabel *labelMaskedPan;
@property (weak, nonatomic) IBOutlet UILabel *labelCardAvailableAmount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLabelCardAvailableAmountConstraint;
@property (weak, nonatomic) IBOutlet UIButton *buttonClickDefault;
@property (copy) void (^didClickDelete)();
@property (copy) void (^didClickDefault)();
@end
