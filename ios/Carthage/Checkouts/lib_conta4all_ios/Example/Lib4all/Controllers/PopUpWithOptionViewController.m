//
//  PopUpWithOptionViewController.m
//  Lib4all
//
//  Created by Gabriel Miranda Silveira on 07/05/18.
//  Copyright © 2018 4all. All rights reserved.
//

#import "PopUpWithOptionViewController.h"
#import "MainActionButton.h"
#import "LayoutManager.h"

@interface PopUpWithOptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UILabel *alertDescription;
@property (weak, nonatomic) IBOutlet MainActionButton *firstOptionButton;
@property (weak, nonatomic) IBOutlet UIButton *secondOptionButton;
@property (weak, nonatomic) IBOutlet UIView *boxView;

@end

@implementation PopUpWithOptionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[NSBundle getLibBundle] loadNibNamed:@"PopUpWithOptionViewController" owner:self options:nil][0];
        [self configureLayout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configureLayout {
    LayoutManager *layout = [LayoutManager sharedManager];
    
    _alertTitle.font = [layout fontWithSize:layout.titleFontSize];
    _alertTitle.textColor = layout.primaryColor;
    
    _alertDescription.font = [layout fontWithSize:layout.subTitleFontSize];
    _alertDescription.textColor = layout.darkFontColor;
    
    _firstOptionButton.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    
    _secondOptionButton.titleLabel.font = [layout fontWithSize:layout.subTitleFontSize];
    [_secondOptionButton setTitleColor:layout.primaryColor forState:UIControlStateNormal];
    _secondOptionButton.layer.borderWidth = 0;
    
    _boxView.backgroundColor = [UIColor whiteColor];
    _boxView.layer.cornerRadius = 5;
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:0.8];
    
}

-(void)show:(UIViewController *)rootView title:(NSString *)title description:(NSString *)description firstButtonTitle:(NSString *)firstButtonTitle secondButtonTitle:(NSString *)secondButtonTitle {
    _alertTitle.text = title;
    _alertDescription.text = description;
    [_firstOptionButton setTitle:firstButtonTitle forState:UIControlStateNormal];
    [_secondOptionButton setTitle:secondButtonTitle forState:UIControlStateNormal];
    
    [rootView presentViewController:self animated:YES completion:nil];
}

- (IBAction)didPressFirstOptionButton:(id)sender {
    if (_firstOptionBlock) {
        [self dismissViewControllerAnimated:YES completion: ^{
            _firstOptionBlock();
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didPressSecondOptionButton:(id)sender {
    if (_secondOptionBlock) {
        [self dismissViewControllerAnimated:YES completion: ^{
            _secondOptionBlock();
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
