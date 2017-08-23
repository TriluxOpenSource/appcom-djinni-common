//
//  ACObjCPlatformThreads.m
//
//  Created by Ralph-Gordon Paul on 23.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#include "ACObjCPlatformThreads.h"
#include "ACThreadFunc.h"


@interface ACObjCPlatformThreadsInternalFunc : ACThreadFunc
- (instancetype)initWithBlock:(ACThreadFuncBlock)block;
- (void)run;
@end


@implementation ACObjCPlatformThreadsInternalFunc {
    ACThreadFuncBlock _runBlock;
}

- (instancetype)initWithBlock:(ACThreadFuncBlock)block {
    if (self = [super init]) {
        _runBlock = [block copy];
    }
    return self;
}

- (void)run {
    _runBlock();
}

@end


@implementation ACObjCPlatformThreads {
    ACObjCPlatformThreadsConfigBlock _cfgBlock;
}

- (id) init __attribute__((unavailable)) {
    return nil;
}

- (nullable instancetype)initWithConfigBlock:(ACObjCPlatformThreadsConfigBlock)block {
    if (self = [super init]) {
        _cfgBlock = [block copy];
    }
    return self;
}

+ (nullable ACObjCPlatformThreads *)platformThreads {
    return [ACObjCPlatformThreads platformThreadsWithConfigBlock:nil];
}

+ (nullable ACObjCPlatformThreads *)
    platformThreadsWithConfigBlock:(ACObjCPlatformThreadsConfigBlock)block {
    return [[ACObjCPlatformThreads alloc] initWithConfigBlock:block];
}

- (void)createThread:(nonnull NSString *)name
                func:(nonnull ACThreadFunc *)func {
    NSThread * thread = [[NSThread alloc] initWithTarget:func selector:@selector(run) object:nil];
    thread.name = name;
    if (_cfgBlock) {
        _cfgBlock(thread);
    }
    [thread start];
}

- (void)createThread:(nonnull NSString *)name
               block:(ACThreadFuncBlock)block {
    [self createThread:name func:[[ACObjCPlatformThreadsInternalFunc alloc] initWithBlock:block]];
}

- (nonnull NSNumber *)isMainThread {
    return @(NSThread.isMainThread);
}

@end
