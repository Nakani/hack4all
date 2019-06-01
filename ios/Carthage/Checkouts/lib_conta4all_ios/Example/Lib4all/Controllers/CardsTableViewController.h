//
//  CardsTableViewController.h
//  Example
//
//  Created by Cristiano Matte on 10/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OnSelectCard) {
    OnSelectCardMakeDefault,
    OnSelectCardShowActionSheet,
    OnSelectCardReturnCardId,
    OnSelectCardShowNextVC,
    OnSelectCardChangeSubscriptions
};


@interface CardsTableViewController : UITableViewController <UIActionSheetDelegate>

@property (assign) OnSelectCard onSelectCardAction;
@property (copy) void(^didSelectCardBlock)(NSString *cardID);

@property NSArray * acceptedPaymentTypes;
@property NSArray * acceptedBrands;

@property NSArray * filterCardID;

@property BOOL isQrCodePayment;
@end
