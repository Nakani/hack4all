//
//  UIImage.m
//  Example
//
//  Created by Luciano Bohrer on 11/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "UIImage+Lib4all.h"

@implementation UIImage (Lib4all)

+ (UIImage*)lib4allImageNamed:(NSString*)name {
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    
    UIImage *imageFromMyLibraryBundle = [UIImage imageWithContentsOfFile:[[[NSBundle getLibBundle] resourcePath] stringByAppendingPathComponent:name]];
    
    return imageFromMyLibraryBundle;
}


@end
