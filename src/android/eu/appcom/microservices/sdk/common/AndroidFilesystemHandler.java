//
//  AndroidFilesystemHandler.java
//
//  Created by Ralph-Gordon Paul on 14.09.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

package eu.appcom.microservices.sdk.common;

import android.content.Context;
import android.content.ContextWrapper;


public class AndroidFilesystemHandler extends FilesystemHandler
{
    private Context _ctx;

    public AndroidFilesystemHandler(Context ctx) {
        _ctx = ctx;
    }

    @Override
    public String getDirectory(FilesystemDirectory directory)
    {
        String dir = "";
        ContextWrapper ctxWrapper = new ContextWrapper(_ctx);

        switch (directory) {
            case DOCUMENTS:
                dir = ctxWrapper.getFilesDir().getAbsolutePath();
                break;

            case TEMP:
                dir = ctxWrapper.getCacheDir().getAbsolutePath();
                break;
        }

        return dir;
    }
}
