//
//  AndroidPlatformThreads.java
//
//  Created by Ralph-Gordon Paul on 23.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

package eu.appcom.microservices.sdk.common;

import javax.annotation.CheckForNull;
import javax.annotation.Nonnull;

import android.os.Looper;

public class AndroidPlatformThreads extends JavaPlatformThreads {
    private static Looper sMainLooper = Looper.getMainLooper();

    public AndroidPlatformThreads() {}

    @Override
    @Nonnull
    public Boolean isMainThread() {
        return Looper.myLooper() == sMainLooper;
    }
}
