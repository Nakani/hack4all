//
//  CardComponentViewController.h
//  Example
//
//  Created by Cristiano Matte on 20/07/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreditCard.h"

@interface CardComponentViewController : UIViewController

@property (copy) void (^didSelectCardCompletionBlock)(NSString *selectedCardId);

- (id)initWithCardId:(NSString *)cardId;
- (id)initWithCardId:(NSString *)cardId andInvisibleBackground:(BOOL)invisible;
- (void)changeCardId:(NSString *)cardId;
//- (void)setCardTypeWithCard:(CreditCard *)card;
@end
