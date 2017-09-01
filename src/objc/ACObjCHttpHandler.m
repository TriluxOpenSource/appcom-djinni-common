//
//  ACObjCHttpHandler.h
//
//  Created by Ralph-Gordon Paul on 30.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#import "ACObjCHttpHandler.h"
#import "ACHttpResponse.h"

@implementation ACObjCHttpHandler

- (void)sendHttpRequest:(nonnull ACHttpRequest *)request delegate:(nullable ACHttpListener *)delegate
{
    NSLog(@"Send HttpRequst... %@", request);

    // convert the uri endpoint to a NSURL
    NSURL *url = [NSURL URLWithString:request.uri];

    // create the url request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    // apply GET/POST/PUT/DELETE 
    [urlRequest setHTTPMethod:request.type];
    // apply content type
    [urlRequest setValue:request.mediaType forHTTPHeaderField:@"Content-Type"];
    // apply body
    urlRequest.HTTPBody = request.body;

    // apply all headers
    for (NSString* header in request.headers)
    {
        [urlRequest setValue:request.headers[header] forHTTPHeaderField:header];
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest 
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) 
    {
        if (error) {
            if (delegate) 
            {
                [delegate errorOnSend:error.debugDescription];
            }
        } else {

            NSDictionary *headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
            ACHttpResponse *httpResponse = [[ACHttpResponse alloc] initWithHeaders:headers body:data status:statusCode];

            if (delegate) 
            {
                [delegate receivedHttpResponse:httpResponse];
            }
        }
    }];
    [task resume];
}

@end