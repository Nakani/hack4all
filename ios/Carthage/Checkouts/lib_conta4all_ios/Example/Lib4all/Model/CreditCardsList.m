//
//  CreditCardsList.m
//  Example
//
//  Created by Cristiano Matte on 03/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CreditCardsList.h"
#import "PersistenceHelper.h"


@implementation CreditCardsList

NSString * const CreditCardsFileName = @"creditcard.json";
NSString * const SharingCreditCardsFileName = @"sharingCreditcard.json";
NSString * const CardTypeKey = @"type";
NSString * const CardIDKey = @"cardId";
NSString * const BrandIDKey = @"brandId";
NSString * const LastDigitsKey = @"lastDigits";
NSString * const StatusKey = @"status";
NSString * const IsDefaultKey = @"default";
NSString * const IsSharedKey = @"shared";
NSString * const SharedDetailsKey = @"sharedDetails";
NSString * const isProviderKey = @"sharedProvider";
NSString * const identifierKey = @"identifier";
NSString * const BinKey = @"bin";

+ (id)sharedList {
    static CreditCardsList *sharedList = nil;
    
    @synchronized(self) {
        if (sharedList == nil) {
            sharedList = [[CreditCardsList alloc] init];
            [sharedList load];
            [[PersistenceHelper sharedHelper] registerEntity:sharedList];
        }
    }
    
    return sharedList;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.creditCards = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (CreditCard *)getCardWithID:(NSString *)cardID {
    NSArray *cardWithID = [self.creditCards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cardId = %@", cardID]];
    
    if (cardWithID.count > 0) {
        return cardWithID[0];
    } else {
        return nil;
    }
}

- (void)setDefaultCardWithCardID:(NSString *)cardID {
    CreditCard *currentDefaultCard = [self getDefaultCard];
    if (currentDefaultCard != nil) {
        currentDefaultCard.isDefault = NO;
    }
    
    CreditCard *newDefaultCard = [self getCardWithID:cardID];
    if (newDefaultCard != nil) {
        newDefaultCard.isDefault = YES;
    }
}

- (CreditCard *)getDefaultCard {
    NSArray *currentDefaultCard = [self.creditCards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault = YES"]];
    
    if (currentDefaultCard.count > 0) {
        return currentDefaultCard[0];
    } else {
        return nil;
    }
}

- (NSArray *)getSharedCards {
    NSArray *sharedCards = [self.creditCards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"shared = YES"]];
    
    if (sharedCards.count > 0) {
        return sharedCards;
    } else {
        return nil;
    }
}

- (NSArray *)getOwnedCards {
    NSMutableArray *ownedCards = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.creditCards.count; i++) {
        CreditCard *card = self.creditCards[i];
        if (card.type == CardTypeDebit) {
            continue;
        }
            
        if (card.isShared) {
            if ([[card.sharedDetails[0] objectForKey:@"provider"] boolValue]) {
                [ownedCards addObject:card];
            }
        } else {
            [ownedCards addObject:card];
        }
    }
    return ownedCards;
}

- (NSArray *)getValidCards {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        CreditCard *card = (CreditCard *)evaluatedObject;
        if(!card.isShared) {
            return YES;
        } else  {
            if ([[card.sharedDetails[0] valueForKey:@"provider"] boolValue]) {
                return YES;
            } else if ([[card.sharedDetails[0] objectForKey:@"status"] integerValue] == 1) {
                return YES;
            }
        }
        return NO;
    }];
    
    NSArray *validCards = [self.creditCards filteredArrayUsingPredicate:filter];
    return validCards;
}


- (BOOL)load {
    NSString *filePath = [PersistenceHelper pathForFilename:CreditCardsFileName];
    NSArray *creditCardsArray = (NSArray *)[PersistenceHelper loadJSONObjectFromFile:filePath];
    
    if (creditCardsArray == nil) {
        return NO;
    }
    
    for (NSDictionary *creditCardDictionary in creditCardsArray) {
        CreditCard *creditCard = [[CreditCard alloc] init];
        
        if ([creditCardDictionary valueForKey:CardTypeKey] != nil) {
            creditCard.type = [((NSNumber *)[creditCardDictionary valueForKey:CardTypeKey]) integerValue];
        }
        if ([creditCardDictionary valueForKey:CardIDKey] != nil) {
            creditCard.cardId = [creditCardDictionary valueForKey:CardIDKey];
        }
        if ([creditCardDictionary valueForKey:BrandIDKey] != nil) {
            creditCard.brandId = [creditCardDictionary valueForKey:BrandIDKey];
        }
        if ([creditCardDictionary valueForKey:LastDigitsKey] != nil) {
            creditCard.lastDigits = [creditCardDictionary valueForKey:LastDigitsKey];
        }
        if ([creditCardDictionary valueForKey:StatusKey] != nil) {
            creditCard.status = [creditCardDictionary valueForKey:StatusKey];
        }
        if ([creditCardDictionary valueForKey:BinKey] != nil) {
            creditCard.bin = [creditCardDictionary valueForKey:BinKey];
        }
        if ([creditCardDictionary valueForKey:IsDefaultKey] != nil) {
            creditCard.isDefault = [((NSNumber *)[creditCardDictionary valueForKey:IsDefaultKey]) boolValue];
        }
        if ([creditCardDictionary valueForKey:IsSharedKey] != nil) {
            creditCard.isShared = [((NSNumber *)[creditCardDictionary valueForKey:IsSharedKey]) boolValue];
        }
        if (creditCard.isShared || [creditCardDictionary valueForKey:SharedDetailsKey] != nil) {
            creditCard.sharedDetails = [creditCardDictionary valueForKey:SharedDetailsKey];
        }
        [self.creditCards addObject:creditCard];
    }

    return YES;
}

- (BOOL)save {
    NSString *filePath = [PersistenceHelper pathForFilename:CreditCardsFileName];
    NSMutableArray *creditCardsArray = [[NSMutableArray alloc] initWithCapacity:self.creditCards.count];
    
    for (CreditCard *creditCard in self.creditCards) {
        NSMutableDictionary *creditCardDictionary = [[NSMutableDictionary alloc] init];
        [creditCardDictionary addEntriesFromDictionary:@{  CardTypeKey: [NSNumber numberWithInteger:creditCard.type],
                                                           CardIDKey: creditCard.cardId,
                                                           BrandIDKey: creditCard.brandId,
                                                           LastDigitsKey: creditCard.lastDigits,
                                                           StatusKey: creditCard.status,
                                                           IsDefaultKey: [NSNumber numberWithBool:creditCard.isDefault],
                                                           IsSharedKey: [NSNumber numberWithBool:creditCard.isShared],
                                                           BinKey: creditCard.bin
                                                           }];
        
        
        [creditCardDictionary setValue:creditCard.sharedDetails forKey:SharedDetailsKey];
        
        [creditCardsArray addObject:creditCardDictionary];
    }
    
    return [PersistenceHelper saveJSONObject:creditCardsArray toFile:filePath];
}

- (BOOL)saveSharingCards {
    NSString *filePath = [PersistenceHelper pathForFilename:SharingCreditCardsFileName];
    NSMutableArray *creditCardsArray = [[NSMutableArray alloc] initWithCapacity:self.creditCards.count];
    
    for (CreditCard *creditCard in self.creditCards) {
        if (!creditCard.isShared) {
            continue;
        }
        NSMutableDictionary *creditCardDictionary = [[NSMutableDictionary alloc] init];
        [creditCardDictionary addEntriesFromDictionary:@{  CardTypeKey: [NSNumber numberWithInteger:creditCard.type],
                                                           CardIDKey: creditCard.cardId,
                                                           BrandIDKey: creditCard.brandId,
                                                           LastDigitsKey: creditCard.lastDigits,
                                                           StatusKey: creditCard.status,
                                                           IsDefaultKey: [NSNumber numberWithBool:creditCard.isDefault],
                                                           IsSharedKey: [NSNumber numberWithBool:creditCard.isShared]
                                                           }];
        
        
        [creditCardDictionary setValue:creditCard.sharedDetails forKey:SharedDetailsKey];
        
        [creditCardsArray addObject:creditCardDictionary];
    }
    
    return [PersistenceHelper saveJSONObject:creditCardsArray toFile:filePath];

}

- (NSArray *)loadSharingCards {
    NSString *filePath = [PersistenceHelper pathForFilename:SharingCreditCardsFileName];
    NSArray *creditCardsArray = (NSArray *)[PersistenceHelper loadJSONObjectFromFile:filePath];
    
    NSMutableArray *sharedCardArray = [[NSMutableArray alloc] init];
    
    if (creditCardsArray == nil) {
        return sharedCardArray;
    }
    
    
    for (NSDictionary *creditCardDictionary in creditCardsArray) {
        CreditCard *creditCard = [[CreditCard alloc] init];
        
        if ([creditCardDictionary valueForKey:CardTypeKey] != nil) {
            creditCard.type = [((NSNumber *)[creditCardDictionary valueForKey:CardTypeKey]) integerValue];
        }
        if ([creditCardDictionary valueForKey:CardIDKey] != nil) {
            creditCard.cardId = [creditCardDictionary valueForKey:CardIDKey];
        }
        if ([creditCardDictionary valueForKey:BrandIDKey] != nil) {
            creditCard.brandId = [creditCardDictionary valueForKey:BrandIDKey];
        }
        if ([creditCardDictionary valueForKey:LastDigitsKey] != nil) {
            creditCard.lastDigits = [creditCardDictionary valueForKey:LastDigitsKey];
        }
        if ([creditCardDictionary valueForKey:StatusKey] != nil) {
            creditCard.status = [creditCardDictionary valueForKey:StatusKey];
        }
        if ([creditCardDictionary valueForKey:IsDefaultKey] != nil) {
            creditCard.isDefault = [((NSNumber *)[creditCardDictionary valueForKey:IsDefaultKey]) boolValue];
        }
        if ([creditCardDictionary valueForKey:IsSharedKey] != nil) {
            creditCard.isShared = [((NSNumber *)[creditCardDictionary valueForKey:IsSharedKey]) boolValue];
        }
        if (creditCard.isShared || [creditCardDictionary valueForKey:SharedDetailsKey] != nil) {
            creditCard.sharedDetails = [creditCardDictionary valueForKey:SharedDetailsKey];
        }
        [sharedCardArray addObject:creditCard];
    }
    
    return sharedCardArray;
}

- (NSArray *) checkSharingModifications {
    NSMutableArray *modifications = [[NSMutableArray alloc] init];
    NSArray *sharedCardArray = [self getSharedCards];
    
    NSArray *creditCardsArray = [[CreditCardsList sharedList] loadSharingCards];
    
    //Teste para ver se o dono deletou o cartão
    if (creditCardsArray.count > sharedCardArray.count) {
        for (int i = 0; i < creditCardsArray.count; i++) {
            CreditCard *card = creditCardsArray[i];
            if([[card.sharedDetails[0] valueForKey:@"provider"] boolValue]) {
                continue;
            }
            BOOL exist = NO;
            for  (int j = 0; j < sharedCardArray.count; j++) {
                if (card.cardId == ((CreditCard *)sharedCardArray[j]).cardId) {
                    exist = YES;
                }
            
            }
        }
    }
    //Teste para ver alterações no cartão do benificiario
    for (int k = 0; k < creditCardsArray.count; k++) {
        CreditCard *savedCard = creditCardsArray[k];
        CreditCard *card = [[CreditCardsList sharedList] getCardWithID:savedCard.cardId];
 
        if(![[savedCard.sharedDetails[0] valueForKey:@"provider"] boolValue]) {
            continue;
        }
        //Algum benificiario deletou um cartão
        if (savedCard.sharedDetails.count > card.sharedDetails.count) {
            for (int i = 0; i < savedCard.sharedDetails.count; i++) {
                BOOL exist = NO;
                for  (int j = 0; j < card.sharedDetails.count; j++) {
                    if ([savedCard.sharedDetails[i] valueForKey:identifierKey] == [card.sharedDetails[j] valueForKey:identifierKey]) {
                        exist = YES;
                        break;
                    }
                    
                }
            }
        }

        
        //Testa se algum beneficiario aceitou o cartão
        for (int i = 0; i < savedCard.sharedDetails.count; i++) {
            for  (int j = 0; j < card.sharedDetails.count; j++) {
                if ([savedCard.sharedDetails[i] valueForKey:@"customerId"] == [card.sharedDetails[j] valueForKey:@"customerId"]) {
                    if ([[savedCard.sharedDetails[i] valueForKey:StatusKey] boolValue] == NO && [[card.sharedDetails[j] valueForKey:StatusKey] boolValue] == YES ) {
                        NSDictionary *modification = @{ @"type": @"recipientAcceptedCard",
                                                        identifierKey: [savedCard.sharedDetails[i] valueForKey:identifierKey],
                                                        @"balance": [NSNumber numberWithDouble:[[savedCard.sharedDetails[i] valueForKey:@"recurringBalance"] doubleValue]]
                                                        };
                        [modifications addObject:modification];
                    
                    
                    }
                    break;
                }
            }
        
        }
        
    
    }
    
    [self saveSharingCards];
    return modifications;
}



- (BOOL)remove {
    NSString *filePath = [PersistenceHelper pathForFilename:CreditCardsFileName];
    BOOL success = [PersistenceHelper removeContentOfFile:filePath];
    
    // Se arquivo foi removido com sucesso, reinicia a lista de cartões de crédito
    if (success) {
        self.creditCards = [[NSMutableArray alloc] init];
    }
    
    return success;
}

@end
