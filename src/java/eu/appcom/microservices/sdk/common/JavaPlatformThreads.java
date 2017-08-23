//
//  JavaPlatformThreads.java
//
//  Created by Ralph-Gordon Paul on 23.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

package eu.appcom.microservices.sdk.common;

import javax.annotation.CheckForNull;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

public class JavaPlatformThreads extends PlatformThreads {

    public JavaPlatformThreads() {}

    @Override
    public void createThread(@Nonnull String name, @Nonnull ThreadFunc func) {
        final ThreadFunc passFunc = func;
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                passFunc.run();
            }
        }, name);
        thread.setDaemon(true);
        configureThread(thread);
        thread.start();
    }

    @Override
    @CheckForNull
    public Boolean isMainThread() {
        return null;
    }

    protected void configureThread(Thread thread) {}
}
