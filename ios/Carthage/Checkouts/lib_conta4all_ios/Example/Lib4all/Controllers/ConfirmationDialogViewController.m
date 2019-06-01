//
//  ConfirmationDialogViewController.m
//  Example
//
//  Created by 4all on 13/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "ConfirmationDialogViewController.h"

@interface ConfirmationDialogViewController ()

@end

@implementation ConfirmationDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
