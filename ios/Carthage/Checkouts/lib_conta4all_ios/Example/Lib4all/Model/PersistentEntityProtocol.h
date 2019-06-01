//
//  PersistentEntityProtocol.h
//  Example
//
//  Created by Cristiano Matte on 03/06/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PersistentEntityProtocol <NSObject>

- (BOOL)load;
- (BOOL)save;
- (BOOL)remove;

@end
