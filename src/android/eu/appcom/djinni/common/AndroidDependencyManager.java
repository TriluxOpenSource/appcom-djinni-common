//
//  AndroidDependencyManager.java
//
//  Created by Ralph-Gordon Paul on 20.02.2018
//  Copyright (c) 2018 Ralph-Gordon Paul. All rights reserved.
//

package eu.appcom.djinni.common;

import android.content.Context;

import okhttp3.OkHttpClient;

import eu.appcom.djinni.common.AndroidAssetManager;
import eu.appcom.djinni.common.AndroidFilesystemHandler;
import eu.appcom.djinni.common.AndroidHttpHandler;
import eu.appcom.djinni.common.AndroidPlatformThreads;

/**
 * This class manages common known dependencies, so that the user of this library only has to pass an instance of the
 * platform version of this to his library / implementation and the library / implementation can access these
 * dependencies if needed
 */
public class AndroidDependencyManager extends DependencyManager {

    private Context _ctx;

    private AndroidAssetManager _assetManager;
    private AndroidFilesystemHandler _filesystemHandler;
    private AndroidHttpHandler _httpHandler;
    private AndroidPlatformThreads _platformThreads;

    public AndroidDependencyManager(Context ctx) {
        _ctx = ctx;
    }

    /** the platform specific asset manager - currently only android, ios will return nil */
    @Override
    public AssetManager getAssetManager() {
        if (_assetManager == null) {
            _assetManager = new AndroidAssetManager(_ctx);
        }
        return _assetManager;
    }

    /** the platform specific http handler */
    @Override
    public HttpHandler getHttpHandler() {
        if (_httpHandler == null) {
            _httpHandler = new AndroidHttpHandler(new OkHttpClient.Builder().build());
        }
        return _httpHandler;
    }

    /** the platform specific filesystem handler */
    @Override
    public FilesystemHandler getFilesystemHandler() {
        if (_filesystemHandler == null) {
            _filesystemHandler = new AndroidFilesystemHandler(_ctx);
        }
        return _filesystemHandler;
    }

    /** the platform specific thread handler */
    @Override
    public PlatformThreads getPlatformThreads() {
        if (_platformThreads == null) {
            _platformThreads = new AndroidPlatformThreads();
        }
        return _platformThreads;
    }
}
