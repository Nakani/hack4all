//
//  SocialContainerViewController.m
//  Example
//
//  Created by Luciano Bohrer on 30/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "SocialContainerViewController.h"
#import <SafariServices/SafariServices.h>
#import "Lib4allPreferences.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "LayoutManager.h"
#import "AnalyticsUtil.h"
#import "NSBundle+Lib4allBundle.h"

@interface SocialContainerViewController () <SFSafariViewControllerDelegate>

@property SFSafariViewController *webView;
@property (weak, nonatomic) IBOutlet UILabel *labelOr;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UIButton *buttonGoogle;
@property AFHTTPRequestOperationManager *tunnelManager;
@property BOOL nativeSDK;
@property (weak, nonatomic) IBOutlet UIView *socialContainerView;

@end

@implementation SocialContainerViewController

- (id)init {
    
    self = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"SocialComponent"];
    
    return self;
    
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupController];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupController{
    LayoutManager *layout = [LayoutManager sharedManager];
    [_labelOr setFont:[layout fontWithSize:layout.regularFontSize]];
    
    _buttonFacebook.layer.cornerRadius = 4;
    _buttonFacebook.layer.borderWidth = 0.5;
    [_buttonFacebook setBackgroundColor:[UIColor colorWithRed:59/255.f green:89/255.f blue:152/255.f alpha:1.0]];
    [_buttonFacebook setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _buttonFacebook.layer.borderColor = layout.darkGray.CGColor;
    _buttonGoogle.layer.cornerRadius = 4;
    _buttonGoogle.layer.borderWidth = 0.5;
    _buttonGoogle.layer.borderColor = layout.darkGray.CGColor;
    [_buttonGoogle setTitleColor:layout.darkGray forState:UIControlStateNormal];
    
}

//mark: - IBActions

-(IBAction)googleClick:(id)sender{
    NSString *action = _isLogin ? @"login" : @"account";
    
    [AnalyticsUtil createEventWithCategory:@"account" action:action label:@"google login " andValue:nil];
    
    [self openTunnelForSite:SocialMediaGoogle];
    
    
}

-(IBAction)facebookClick:(id)sender{
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    NSString *action = _isLogin ? @"login" : @"account";
    
    [AnalyticsUtil createEventWithCategory:@"account" action:action label:@"facebook login " andValue:nil];
    
    [self openTunnelForSite:SocialMediaFacebook];

}

//MARK: - Webview
- (void) openTunnelForSite:(SocialMedia)site {
    Services *services = [[Services alloc] init];
    LoadingViewController *loadingView = [[LoadingViewController alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        [loadingView finishLoading:^{
            
        }];
    };
    
    services.successCase = ^(NSDictionary *response) {
        [loadingView finishLoading:^{
            NSString *tunnelToken = [response objectForKey:TunnelTokenKey] ;
            [self openWebviewWithToken:tunnelToken forSite:site];
        }];
    };

    [services openTunnel];
    [loadingView startLoading:self title:@"Aguarde..."];
    
}

- (void) waitForTunnel: (NSString *) tunnelToken withSocialMedia:(SocialMedia)socialMedia {
    Services *services = [[Services alloc] init];
    
    services.failureCase = ^(NSString *cod, NSString *msg) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self waitForTunnel:tunnelToken withSocialMedia:socialMedia];
        });
    };
    
    services.successCase = ^(NSDictionary *response) {
        BOOL isOpen = [[response objectForKey:StatusKey] boolValue];
        if (isOpen) {
            [self waitForTunnel:tunnelToken withSocialMedia:socialMedia];
        } else {
            NSString *tunnelData = [response objectForKey:DataKey];
            [self.webView dismissViewControllerAnimated:YES completion:^{
                [self.delegate socialLoginDidFinishWithToken:tunnelData fromSocialMedia:socialMedia nativeSDK:NO];
            }];
        
        }
    };
    
    self.tunnelManager = [services waitForTunnel:tunnelToken];

}

- (void) openWebviewWithToken:(NSString *)tunnelToken forSite:(SocialMedia)site  {
    NSString *url = @"https://services.4all.com/thirdPartyLogin/index.html?tunnelToken=@token&type=@site&e=@env&app=@app";
    
    NSCharacterSet *urlBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"/+=\n"] invertedSet];
    
    // URL-codifica o sessionToken
    NSString *encodedTunelToken = [tunnelToken stringByAddingPercentEncodingWithAllowedCharacters:urlBase64CharacterSet];
    
    url = [url stringByReplacingOccurrencesOfString:@"@token" withString: encodedTunelToken];
    
    NSString *appName = Lib4allPreferences.sharedInstance.thirdPartyLoginAppName;
    
    url = [url stringByReplacingOccurrencesOfString:@"@app" withString:appName];
    
    switch (site) {
        case SocialMediaFacebook:
            url = [url stringByReplacingOccurrencesOfString:@"@site" withString:@"facebook"];
            break;
        case SocialMediaGoogle:
            url = [url stringByReplacingOccurrencesOfString:@"@site" withString:@"google"];
            break;
        default:
            break;
    }
    
    switch (Lib4allPreferences.sharedInstance.environment) {
        case EnvironmentProduction:
            url = [url stringByReplacingOccurrencesOfString:@"@env" withString:@"prod"];
            break;
            
        default:
            url = [url stringByReplacingOccurrencesOfString:@"@env" withString:@"homolog-interna"];
            break;
    }
    
    self.webView = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    self.webView.delegate = self;
    [self waitForTunnel:tunnelToken withSocialMedia:site];
    [self presentViewController:self.webView animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    if (self.tunnelManager) {
        [self.tunnelManager.operationQueue cancelAllOperations];
    }
}

@end
