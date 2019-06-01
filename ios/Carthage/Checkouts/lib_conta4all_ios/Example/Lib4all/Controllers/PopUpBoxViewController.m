//
//  PopUpBoxViewController.m
//  Example
//
//  Created by 4all on 10/04/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PopUpBoxViewController.h"
#import "LayoutManager.h"
#import "UIButton+Color.h"
#import "UIColor+HexString.h"
#import "UIImage+Color.h"

@interface PopUpBoxViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonOk;
@property (weak, nonatomic) IBOutlet UIView *viewBox;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBoxTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBoxBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopToIconViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBoxLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBoxTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;

@property (copy) void (^buttonAction)();
@property (assign) PopUpImageMode imageMode;

@end

@implementation PopUpBoxViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view = [[NSBundle getLibBundle] loadNibNamed:@"PopUpBoxViewController" owner:self options:nil][0];
        //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        
        LayoutManager *layout       = [LayoutManager sharedManager];
        
        self.labelTitle.font                = [layout boldFontWithSize:layout.regularFontSize];
        self.labelDescription.font          = [layout fontWithSize:layout.regularFontSize];
        self.buttonOk.titleLabel.font       = [layout fontWithSize:layout.regularFontSize];
        self.buttonOk.titleLabel.textColor  = layout.lightFontColor;
        self.buttonOk.backgroundColor       = layout.primaryColor;
        
        [self.buttonOk setGradientFromColor:layout.primaryColor
                                    toColor:layout.gradientColor];
        self.viewBox.layer.cornerRadius = 6.0f;
        self.view.backgroundColor       = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        [_closeImageView setUserInteractionEnabled:YES];
        [_closeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)]];
        [_closeImageView setImage:[[UIImage lib4allImageNamed:@"icon-close"] withColor:[LayoutManager sharedManager].darkFontColor]];

        double iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
        if (iOSVersion >= 8.0 && !UIAccessibilityIsReduceTransparencyEnabled()) {
            self.modalPresentationStyle = UIModalPresentationCustom;
        }
        else {
            self.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
-(void)show:(UIViewController *)rootView title:(NSString *)title description:(NSString *)description imageMode:(PopUpImageMode)imageMode buttonAction:(void (^)())buttonAction {
    self.buttonAction   = buttonAction;
    self.imageMode      = imageMode;
    self.labelDescription.text = description;
    self.labelTitle.text = title;
    
    if (imageMode == Success) {
        //set image sucess
        self.imageIcon.image = [UIImage lib4allImageNamed:@"iconSuccessModal"];
        
    }else if (imageMode == Error){
        //set image error
        self.imageIcon.image = [UIImage lib4allImageNamed:@"iconErrorModal"];
    } else if(imageMode == Info) {
        //hide image
        self.imageIcon.hidden = YES;
        
        //make view smaller
        _viewBoxTopConstraint.constant = 200;
        _viewBoxBottomConstraint.constant = 200;
        _viewBoxLeadingConstraint.constant = 35;
        _viewBoxTrailingConstraint.constant = 35;
        [_viewBox removeConstraint:_titleTopToIconViewConstraint];
        
        //unhide close button
        [_closeImageView setHidden:NO];
        
        _labelDescription.textColor = [LayoutManager sharedManager].darkFontColor;
        _labelTitle.textColor = [LayoutManager sharedManager].darkGray;
    }
    
    [rootView presentViewController:self animated:YES completion:nil];
}

#pragma mark - Actions
- (IBAction)mainButtonTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_buttonAction != nil){
            self.buttonAction();
        }
    }];
}

-(void) closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
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
