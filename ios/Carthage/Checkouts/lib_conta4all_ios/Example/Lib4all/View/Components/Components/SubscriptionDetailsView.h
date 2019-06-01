//
//  SubscriptionDetailsView.h
//  Example
//
//  Created by Cristiano Matte on 04/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionDetailsView : UIView

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSArray *values;

- (instancetype)initWithValues:(NSArray *)values;

@end
