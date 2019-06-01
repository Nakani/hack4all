//
//  LoadingViewController.h
//  Example
//
//  Created by 4all on 4/28/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController

@property (assign) BOOL isLoading;

+ (id)sharedManager;

-(void)startLoading:(UIViewController *)rootView title:(NSString *)title completion: (void (^)())completion;
-(void)startLoading:(UIViewController *)rootView title:(NSString *)title;
-(void)finishLoading: (void (^)())completion;

@end
