//
//  PopUpBoxViewController.h
//  Example
//
//  Created by 4all on 10/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopUpImageMode) {
    Success = 1,
    Error = 2,
    Info = 3
};

@interface PopUpBoxViewController : UIViewController

-(void) show:(UIViewController *)rootView
       title:(NSString *)title
 description:(NSString *)description
   imageMode:(PopUpImageMode)imageMode
buttonAction:(void (^)())buttonAction;


@end
