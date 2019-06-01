//
//  PopUpWithOptionViewController.h
//  Lib4all
//
//  Created by Gabriel Miranda Silveira on 07/05/18.
//  Copyright © 2018 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpWithOptionViewController : UIViewController

@property NSString *titleText;
@property NSString *descriptionText;
@property NSString *firstOptionButtonTitle;
@property NSString *secondOptionButtonTitle;

@property void (^firstOptionBlock)();
@property void (^secondOptionBlock)();

-(void)show:(UIViewController *)rootView title:(NSString *)title description:(NSString *)description firstButtonTitle:(NSString *)firstButtonTitle secondButtonTitle:(NSString *)secondButtonTitle;

@end
