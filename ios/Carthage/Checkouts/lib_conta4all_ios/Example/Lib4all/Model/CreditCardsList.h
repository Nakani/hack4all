//
//  CreditCardsList.h
//  Example
//
//  Created by Cristiano Matte on 03/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersistentEntityProtocol.h"
#import "CreditCard.h"

@interface CreditCardsList : NSObject <PersistentEntityProtocol>

@property (strong, nonatomic) NSMutableArray *creditCards;

+ (id)sharedList;
- (CreditCard *)getCardWithID:(NSString *)cardID;
- (void)setDefaultCardWithCardID:(NSString *)cardID;
- (CreditCard *)getDefaultCard;
- (NSArray *)getSharedCards;
- (NSArray *)getOwnedCards;
- (NSArray *)getValidCards;

- (BOOL) saveSharingCards;
- (NSArray *) loadSharingCards;
- (NSArray *) checkSharingModifications;

@end
