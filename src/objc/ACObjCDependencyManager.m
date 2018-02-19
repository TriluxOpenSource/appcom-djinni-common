//
//  ACObjCDependencyManager.m
//
//  Created by Ralph-Gordon Paul on 20.02.2018
//  Copyright (c) 2018 Ralph-Gordon Paul. All rights reserved.
//

#import "ACObjCDependencyManager.h"

#import "ACObjCHttpHandler.h"
#import "ACObjCFilesystemHandler.h"
#import "ACObjCPlatformThreads.h"

@interface ACObjCDependencyManager()

@property (nonatomic, strong) ACObjCHttpHandler *httpHandler;
@property (nonatomic, strong) ACObjCFilesystemHandler *filesystemHandler;
@property (nonatomic, strong) ACObjCPlatformThreads *platformThreads;

@end

@implementation ACObjCDependencyManager

- (nullable ACAssetManager *)getAssetManager
{
    return nil;
}

- (nullable id<ACHttpHandler>)getHttpHandler
{
    if (self.httpHandler == nil) 
    {
        self.httpHandler = [[ACObjCHttpHandler alloc] init];
    }
    return self.httpHandler;
}

- (nullable id<ACFilesystemHandler>)getFilesystemHandler
{
    if (self.filesystemHandler == nil) 
    {
        self.filesystemHandler = [[ACObjCFilesystemHandler alloc] init];
    }
    return self.filesystemHandler;
}

- (nullable id<ACPlatformThreads>)getPlatformThreads
{
    if (self.platformThreads == nil) 
    {
        self.platformThreads = [ACObjCPlatformThreads platformThreads];
    }
    return self.platformThreads;
}

@end
