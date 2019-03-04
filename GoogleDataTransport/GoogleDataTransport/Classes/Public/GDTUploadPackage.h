/*
 * Copyright 2019 Google
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

/** This class is a container that's handed off to uploaders. */
@interface GDTUploadPackage : NSObject

/** The set of event hashes in this upload package. */
@property(nonatomic) NSSet<NSNumber *> *eventHashes;

/** A lazily-determined map of event hashes to their files. */
@property(nonatomic, readonly) NSDictionary<NSNumber *, NSURL *> *eventHashesToFiles;

@end
