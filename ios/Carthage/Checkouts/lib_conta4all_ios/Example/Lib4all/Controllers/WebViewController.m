//
//  WebViewController.m
//  Example
//
//  Created by Cristiano Matte on 13/07/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "WebViewController.h"
#import "Services.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
}


- (void)setUrl:(NSURL *)url {
    _url = url;
    
    // Carrega a url no web view toda vez que ela for atribuída
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (NSURL *)getUrl {
    return _url;
}

- (IBAction)webButtonTouched {
    self.paymentCompletion(false);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.paymentCompletion == nil) {
        return;
    }
        
    /*
     * Chama o bloco de pagamento finalizado, com sucesso ou não, de acordo com a URL para
     * que o web view foi redirecionado
     */
    Services *service = [[Services alloc] init];
    NSString *url = webView.request.URL.absoluteString;
    if ([url isEqualToString:[service.baseURL.absoluteString stringByAppendingString:@"/debit/paymentOk"]]) {
        self.paymentCompletion(true);
    } else if ([url isEqualToString:[service.baseURL.absoluteString stringByAppendingString:@"/debit/paymentNotOk"]]) {
        self.paymentCompletion(false);
    }
}

@end
