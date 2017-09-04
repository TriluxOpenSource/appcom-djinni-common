//
//  ACObjCFilesystemHandler.h
//
//  Created by Ralph-Gordon Paul on 04.09.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#import <ACFilesystemHandler.h>

@interface ACObjCFilesystemHandler : NSObject <ACFilesystemHandler>

- (nonnull NSString *)getDirectory:(ACFilesystemDirectory)directory;

@end
