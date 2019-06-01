//
//  PasswordModalViewController.h
//  Example
//
//  Created by Luciano Bohrer on 16/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordModalViewController : UIViewController
@property (copy) void (^didEnterPassword)(NSString *password);
@end
