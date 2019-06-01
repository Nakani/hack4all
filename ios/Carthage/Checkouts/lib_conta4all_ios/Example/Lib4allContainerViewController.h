//
//  Lib4allContainerViewController.h
//  Example
//
//  Created by 4all on 5/4/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComponentViewController.h"

@interface Lib4allContainerViewController : UIViewController <CallbacksDelegate>

@property (nonatomic, strong) ComponentViewController *vc;


-(void) resetComponentView;

@end
