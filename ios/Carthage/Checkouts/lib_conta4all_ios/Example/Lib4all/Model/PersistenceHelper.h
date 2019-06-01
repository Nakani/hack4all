//
//  PersistenceHelper.h
//  Example
//
//  Created by 4all on 4/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersistentEntityProtocol.h"

@interface PersistenceHelper : NSObject

+ (id)sharedHelper;
- (void)registerEntity:(id<PersistentEntityProtocol>)entity;
- (void)unregisterEntity:(id<PersistentEntityProtocol>)entity;
- (void)loadEntities;
- (void)saveEntities;
- (void)removeEntities;

+ (NSString *)pathForFilename:(NSString *)fileName;
+ (BOOL)saveJSONObject:(id)object toFile:(NSString *)filePath;
+ (id)loadJSONObjectFromFile:(NSString *)filePath;
+ (BOOL)removeContentOfFile:(NSString *)filePath;

@end