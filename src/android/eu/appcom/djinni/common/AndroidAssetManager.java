//
//  AndroidAssetManager.java
//
//  Created by Ralph-Gordon Paul on 21.09.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

package eu.appcom.djinni.common;

import android.content.Context;
import android.content.ContextWrapper;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class AndroidAssetManager extends AssetManager {
    private Context _ctx;

    public AndroidAssetManager(Context ctx) {
        _ctx = ctx;
    }

    @Override
    public byte[] getAssetData(String path) {
        ContextWrapper ctxWrapper = new ContextWrapper(_ctx);

        byte[] fileBytes = null;

        try {
            InputStream is = ctxWrapper.getAssets().open(path);
            fileBytes = toByteArray(is);
            is.close();
        } catch (IOException e) {
            Log.e("PlacesSdk", "Error reading file " + path + ": " + e.getMessage());
        }

        return fileBytes;
    }

    //! reads all data from an InputStream into a byte array
    public byte[] toByteArray(InputStream in) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        int read = 0;
        byte[] buffer = new byte[1024];
        while (read != -1) {
            read = in.read(buffer);
            if (read != -1)
                out.write(buffer,0,read);
        }
        out.close();
        return out.toByteArray();
    }
}
