//
//  ACObjCFilesystemHandler.m
//
//  Created by Ralph-Gordon Paul on 04.09.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#import "ACObjCFilesystemHandler.h"

@implementation ACObjCFilesystemHandler

- (nonnull NSString *)getDirectory:(ACFilesystemDirectory)directory
{
    switch (directory)
    {
        case ACFilesystemDirectoryDocuments: {
            NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                                             NSUserDomainMask, 
                                                                             YES);
            return paths[0];
        } break;

        case ACFilesystemDirectoryTemp: {
            NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                            NSUserDomainMask, 
                                                                            YES);
            return paths[0];
        } break;
        default:
            break;
    }

    return @"";
}

@end
