//
//  PersistenceHelper.m
//  Example
//
//  Created by 4all on 4/11/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "PersistenceHelper.h"

@interface PersistenceHelper ()

@property NSMutableArray *registeredEntities;

@end


@implementation PersistenceHelper

+ (id)sharedHelper {
    static PersistenceHelper *sharedHelper = nil;
    
    @synchronized(self) {
        if (sharedHelper == nil) {
            sharedHelper = [[PersistenceHelper alloc] init];
        }
    }
    
    return sharedHelper;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.registeredEntities = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveEntities)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)registerEntity:(id<PersistentEntityProtocol>)entity {
    [self.registeredEntities addObject:entity];
}

- (void)unregisterEntity:(id<PersistentEntityProtocol>)entity {
    [self.registeredEntities removeObject:entity];
}

- (void)loadEntities {
    for (id<PersistentEntityProtocol> entity in self.registeredEntities) {
        [entity load];
    }
}

- (void)saveEntities {
    for (id<PersistentEntityProtocol> entity in self.registeredEntities) {
        [entity save];
    }
}

- (void)removeEntities {
    for (id<PersistentEntityProtocol> entity in self.registeredEntities) {
        [entity remove];
    }
}

+ (BOOL)saveJSONObject:(id)object toFile:(NSString *)filePath {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error || (jsonData == nil)) {
        return NO;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [jsonString writeToFile:filePath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:&error];
    
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (id)loadJSONObjectFromFile:(NSString *)filePath {
    NSError *error;
    NSString *jsonData = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    if (error || (jsonData == nil)) {
        return nil;
    }
    
    id object = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding]
                                                options:kNilOptions
                                                  error:&error];
    if (error) {
        return nil;
    }
    
    return object;
}

+ (BOOL)removeContentOfFile:(NSString *)filePath {
    NSError *error;
    [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSString *)pathForFilename:(NSString *)fileName {
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    return fileAtPath;
}

@end
