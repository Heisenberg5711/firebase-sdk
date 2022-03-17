/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "FirebaseStorage/Sources/Public/FirebaseStorage/FIRStorageDownloadTask.h"

@class FIRIMPLStorageReference;
@class GTMSessionFetcherService;

NS_ASSUME_NONNULL_BEGIN

@interface FIRIMPLStorageDownloadTask ()

/**
 * Bytes which have been downloaded so far.
 */
@property(readonly, nonatomic) NSData *downloadData;

/**
 * The file on disk to write to.
 */
@property(copy, nonatomic) NSURL *fileURL;

/**
 * Initializes a download task with a base FIRIMPLStorageReference and GTMSessionFetcherService.
 * @param reference The base FIRIMPLStorageReference which fetchers use for configuration.
 * @param service The GTMSessionFetcherService which will create fetchers.
 * @param queue The shared queue to use for all Storage operations.
 * @param fileURL The system URL to download to. If nil, download in memory as bytes.
 * @return Returns an instance of FIRIMPLStorageDownloadTask
 */
- (instancetype)initWithReference:(FIRIMPLStorageReference *)reference
                   fetcherService:(GTMSessionFetcherService *)service
                    dispatchQueue:(dispatch_queue_t)queue
                             file:(nullable NSURL *)fileURL;

/**
 * Cancels the download task and passes an appropriate error to the developer.
 * @param error NSError to propegate to the developer.
 */
- (void)cancelWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
