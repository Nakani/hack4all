//
//  SocialContainerViewController.h
//  Example
//
//  Created by Luciano Bohrer on 30/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lib4allPreferences.h"
#import "SocialSignInDelegate.h"

@interface SocialContainerViewController : UIViewController
@property (nonatomic, weak) id <SocialSignInDelegate> delegate;
@property (assign) BOOL isLogin;
@end
