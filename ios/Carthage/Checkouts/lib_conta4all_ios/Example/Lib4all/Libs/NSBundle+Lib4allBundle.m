//
//  NSBundle.m
//  Example
//
//  Created by Luciano Bohrer on 11/05/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "NSBundle+Lib4allBundle.h"

@implementation NSBundle (Lib4allBundle)

+ (NSBundle*)getLibBundle {
    static dispatch_once_t onceToken;
    static NSBundle *myLibraryResourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        myLibraryResourcesBundle = [NSBundle bundleWithIdentifier:@"com.4all.Lib4all"];
    });
    return myLibraryResourcesBundle;
}
@end
