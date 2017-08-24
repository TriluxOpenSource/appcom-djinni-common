//
// Copyright 2015 Dropbox, Inc.
// Modified work Copyright (c) 2017 appcom interactive GmbH.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
