//
//  WebViewController.h
//  Example
//
//  Created by Cristiano Matte on 13/07/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSURL *url;
@property (copy) void (^paymentCompletion)(BOOL success);

@end
