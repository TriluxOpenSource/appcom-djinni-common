//
//  ACObjCDependencyManager.h
//
//  Created by Ralph-Gordon Paul on 20.02.2018
//  Copyright (c) 2018 Ralph-Gordon Paul. All rights reserved.
//

#import "ACDependencyManager.h"

#import "ACAssetManager.h"
#import "ACObjCHttpHandler.h"
#import "ACObjCFilesystemHandler.h"
#import "ACObjCPlatformThreads.h"

@interface ACObjCDependencyManager : NSObject <ACDependencyManager>

/** the platform specific asset manager - currently only android, ios will return nil */
- (nullable ACAssetManager *)getAssetManager;

/** the platform specific http handler */
- (nullable id<ACHttpHandler>)getHttpHandler;

/** the platform specific filesystem handler */
- (nullable id<ACFilesystemHandler>)getFilesystemHandler;

/** the platform specific thread handler */
- (nullable id<ACPlatformThreads>)getPlatformThreads;

@end
