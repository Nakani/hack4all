//
//  LayoutManager.m
//  Example
//
//  Created by Luciano Acosta on 27/04/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "LayoutManager.h"
#import "UIColor+HexString.h"
#import <CoreText/CoreText.h>

@implementation LayoutManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.primaryColor                 = [UIColor colorWithRed:95.0/255.0 green:183/255.0 blue:63.0/255.0 alpha:1.0];
        self.secondaryColor               = self.primaryColor;
        self.mainButtonColor              = self.primaryColor;
        self.backgroundColor              = [UIColor whiteColor];
        self.darkBackgroundColor          = [UIColor colorWithHexString:@"#EFEFEF"];
        self.red                          = [UIColor colorWithHexString:@"#d33031"];
        self.errorColor                   = [UIColor colorWithHexString:@"#D20300"];
        self.darkerGray                   = [UIColor colorWithHexString:@"#B2B0B0"];
        self.darkGray                     = [UIColor colorWithHexString:@"#3D3D3D"];
        self.mediumGray                   = [UIColor colorWithHexString:@"#808080"];
        self.lightGray                    = [UIColor colorWithHexString:@"#d3d3d3"];
        self.darkGreen                    = [UIColor colorWithHexString:@"#3d8438"];
        self.lightGreen                   = [UIColor colorWithHexString:@"#4fa444"];
        self.gradientColor                = [UIColor colorWithHexString:@"#12B6B6"];
        self.mainButtonGradientColor      = self.gradientColor;
        self.lightFontColor               = [UIColor whiteColor];
        self.darkFontColor                = [UIColor colorWithHexString:@"#3D3D3D"];
        self.debitStatementColor          = [UIColor colorWithHexString:@"#3D3D3D"];
        self.creditStatementColor         = [UIColor colorWithHexString:@"#4fa444"];
        self.paymentMethodHeaderColor     = [UIColor colorWithHexString:@"#f2f2f2"];
        self.receiptColor                 = self.primaryColor;
        self.balanceIconColor             = self.lightFontColor;
        self.transactionsPaymentSlipColor = [UIColor blackColor];
        self.tokenProgressColor           = [UIColor whiteColor];
        self.miniFontSize                 = 11.0;
        self.midFontSize                  = 13.0;
        self.regularFontSize              = 16.0;
        self.titleFontSize                = 24.0;
        self.subTitleFontSize             = 18.0;
        self.navigationTitleFontSize      = 18.0;
        self.barStyle                     = UIBarStyleBlack;
        
        //Subscription status color
        self.status_undefined           = [UIColor colorWithHexString:@"#999999"];
        self.status_paidOut             = [UIColor colorWithHexString:@"#739e73"];
        self.status_awaitingPayment     = [UIColor colorWithHexString:@"#c79121"];
        self.status_paymentDenied       = [UIColor colorWithHexString:@"#E9573E"];
        self.status_canceled            = [UIColor colorWithHexString:@"#D46A6A"];
        self.status_unApprovedPayment   = [UIColor colorWithHexString:@"#a90329"];
        self.status_awaitingReversal    = [UIColor colorWithHexString:@"#AC92ED"];
        self.status_reversal            = [UIColor colorWithHexString:@"#764B8E"];
        self.status_awaitingcontested   = [UIColor colorWithHexString:@"#EC87BF"];
        self.status_contested           = [UIColor colorWithHexString:@"#D86FAF"];
        self.status_processing          = [UIColor colorWithHexString:@"#57889c"];
        self.status_unApprovedReversal  = [UIColor colorWithHexString:@"#482996"];
        
    }
    
    return self;
}

+ (instancetype)sharedManager {
    static LayoutManager *sharedUser = nil;
    
    @synchronized(self) {
        if (sharedUser == nil)
            sharedUser = [[self alloc] init];
    }
    return sharedUser;
}

- (UIFont *)fontWithSize:(CGFloat)size {
    if (self.fontName) {
        return [UIFont fontWithName:self.fontName size:size];
    }
    [self loadCustomFonts];
    return [UIFont fontWithName:@"Dosis-Regular" size:size];
}

- (UIFont *)boldFontWithSize:(CGFloat)size {
    if (self.boldFontName) {
        return [UIFont fontWithName:self.boldFontName size:size];
    }
    [self loadCustomFonts];
    return [UIFont fontWithName:@"Dosis-Bold" size:size];
}

- (void) loadCustomFonts{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSArray* fontNames = @[@"Dosis-Regular_4all", @"Dosis-Bold_4all"];
        for (int i = 0; i < fontNames.count; i++) {
            NSString *fontName = fontNames[i];
            NSString *fontPath = [[NSBundle getLibBundle] pathForResource:fontName ofType:@"ttf"];
            NSData *inData = [NSData dataWithContentsOfFile:fontPath];
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
            if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }
            CFRelease(font);
            CFRelease(provider);
        }
    });
}

@end
