//
//  AndroidHttpHandler.java
//
//  Created by Ralph-Gordon Paul on 15.09.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

package eu.appcom.djinni.common;

import android.util.Log;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class AndroidHttpHandler extends HttpHandler {

    private OkHttpClient _client;

    public AndroidHttpHandler(OkHttpClient client) {
        _client = client;
    }

    @Override
    public void sendHttpRequest(HttpRequest request, HttpListener delegate) {

        _client.newCall(transformHttpRequest(request)).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                delegate.errorOnSend(e.getMessage());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                delegate.receivedHttpResponse(transformResponse(response));
            }
        });
    }

    private Request transformHttpRequest(HttpRequest request) {

        Request.Builder builder = new Request.Builder();
        builder.url(request.getUri());

        switch (request.getType()) {
            case "GET":
                builder.get();
                break;
            case "PUT":
                builder.put(RequestBody.create(MediaType.parse(request.getMediaType()), request.getBody()));
                break;
            case "POST":
                builder.post(RequestBody.create(MediaType.parse(request.getMediaType()), request.getBody()));
                break;
            case "DELETE":
                builder.delete(RequestBody.create(MediaType.parse(request.getMediaType()), request.getBody()));
                break;
        }

        for (Map.Entry<String, String> entry : request.getHeaders().entrySet()) {
            builder.addHeader(entry.getKey(), entry.getValue());
        }

        return builder.build();
    }

    private HttpResponse transformResponse(Response response) {

        HashMap<String, String> headers = new HashMap<>();

        // create headers from request multimap
        for (Map.Entry<String, List<String>> entry : response.headers().toMultimap().entrySet()) {
            List<String> values = entry.getValue();

            String value = "";

            for (String v : values) {
                if (value.length() > 0)
                    value += " " + v;
                else
                    value = v;
            }

            headers.put(entry.getKey(), value);
        }

        byte[] body = new byte[0];

        try {
            body = response.body().bytes();
        } catch (IOException e) {
            Log.e("AC MS Common SDK", "Error getting body from Resposne: " + e.getMessage());
        }

        return new HttpResponse(headers, body, (short) response.code());
    }
}
