//
//  ACObjCHttpHandler.h
//
//  Created by Ralph-Gordon Paul on 30.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#import <ACHttpHandler.h>
#import <ACHttpListener.h>

@interface ACObjCHttpHandler : NSObject <ACHttpHandler>

- (void)sendHttpRequest:(nonnull ACHttpRequest *)request
    delegate:(nullable ACHttpListener *)delegate;

@end
