//
//  ACObjCPlatformThreads.h
//
//  Created by Ralph-Gordon Paul on 23.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#include "ACPlatformThreads.h"


typedef void (^ __nullable ACObjCPlatformThreadsConfigBlock)(NSThread * __nonnull thread);
typedef void (^ __nonnull ACThreadFuncBlock)();


@interface ACObjCPlatformThreads : NSObject<ACPlatformThreads>

- (nullable instancetype)init __attribute__((unavailable("Please use factory method instead.")));

+ (nullable ACObjCPlatformThreads *)platformThreads;

+ (nullable ACObjCPlatformThreads *)
    platformThreadsWithConfigBlock:(ACObjCPlatformThreadsConfigBlock)block;

- (void)createThread:(nonnull NSString *)name
                func:(nonnull ACThreadFunc *)func;

- (void)createThread:(nonnull NSString *)name
               block:(ACThreadFuncBlock)block;

- (nonnull NSNumber *)isMainThread;

@end
