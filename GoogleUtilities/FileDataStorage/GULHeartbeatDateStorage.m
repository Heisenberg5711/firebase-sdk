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

#import "GULHeartbeatDateStorage.h"
#import <GoogleUtilities/GULLogger.h>
#import <GoogleUtilities/GULSecureCoding.h>

@interface GULHeartbeatDateStorage ()
/** The storage to store the date of the last sent heartbeat. */
@property(nonatomic, readonly) NSFileCoordinator *fileCoordinator;
@end

@implementation GULHeartbeatDateStorage

- (instancetype)initWithFileName:(NSString *)fileName {
  if (fileName == nil) {
    return nil;
  }

  self = [super init];
  if (self) {
    _fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSURL *directoryURL = [[self class] directoryPathURL];
    [[self class] checkAndCreateDirectory:directoryURL:_fileCoordinator];
    _fileURL = [directoryURL URLByAppendingPathComponent:fileName];
  }
  return self;
}

/** Returns the URL path of the Application Support folder.
 * @return the URL path of Application Support.
 */
+ (NSURL *)directoryPathURL {
  NSArray<NSString *> *paths =
      NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSArray<NSString *> *components = @[ paths.lastObject, @"Google/FIRApp" ];
  NSString *directoryString = [NSString pathWithComponents:components];
  NSURL *directoryURL = [NSURL fileURLWithPath:directoryString];
  return directoryURL;
}

/** Checks and creates a directory for the directory specified by the
 * directory url
 * @param directoryPathURL The path to the directory which needs to be created.
 * @param fileCoordinator The fileCoordinator object to coordinate writes to the directory.
 */
+ (void)checkAndCreateDirectory:(NSURL *)directoryPathURL:(NSFileCoordinator *)fileCoordinator {
  NSError *fileCoordinatorError = nil;
  [fileCoordinator
      coordinateWritingItemAtURL:directoryPathURL
                         options:0
                           error:&fileCoordinatorError
                      byAccessor:^(NSURL *writingDirectoryURL) {
                        NSError *error;
                        if (![writingDirectoryURL checkResourceIsReachableAndReturnError:&error]) {
                          // If fail creating the Application Support directory, log warning.
                          NSError *error;
                          GULLoggerService kGULHeartbeatDateStorage = @"GULHeartbeatDateStorage";
                          if (![[NSFileManager defaultManager]
                                         createDirectoryAtURL:writingDirectoryURL
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error]) {
                            GULLogWarning(kGULHeartbeatDateStorage, YES, @"I-COR100001",
                                          @"Unable to create internal state storage: %@", error);
                          }
                        }
                      }];
}

- (nullable NSMutableDictionary *)heartbeatDictionary {
  NSError *fileCoordinatorError = nil;
  __block NSMutableDictionary *dict;
  [self.fileCoordinator
      coordinateReadingItemAtURL:self.fileURL
                         options:0
                           error:&fileCoordinatorError
                      byAccessor:^(NSURL *readingFileUrl) {
                        NSError *error;
                        NSData *objectData = [NSData dataWithContentsOfURL:readingFileUrl
                                                                   options:0
                                                                     error:&error];
                        if (objectData == nil || error != nil) {
                          dict = [NSMutableDictionary dictionary];
                        } else {
                          dict = [GULSecureCoding unarchivedObjectOfClass:NSObject.class
                                                                 fromData:objectData
                                                                    error:&error];
                          if (dict == nil || error != nil) {
                            dict = [NSMutableDictionary dictionary];
                          }
                        }
                      }];
  return dict;
}

- (nullable NSDate *)heartbeatDateForTag:(NSString *)tag {
  NSMutableDictionary *dictionary = [self heartbeatDictionary];
  return dictionary[tag];
}

- (BOOL)setHearbeatDate:(NSDate *)date forTag:(NSString *)tag {
  NSMutableDictionary *dictionary = [self heartbeatDictionary];
  dictionary[tag] = date;
  NSError *error;
  BOOL isSuccess = [self writeDictionary:dictionary error:&error];
  if (isSuccess == false) {
    NSLog(@"Error writing dictionary data %@", error);
  }
  return isSuccess;
}

- (BOOL)writeDictionary:(NSMutableDictionary *)dictionary error:(NSError **)outError {
  NSError *fileCoordinatorError = nil;
  __block bool isWritingSuccess = false;
  [self.fileCoordinator
      coordinateWritingItemAtURL:self.fileURL
                         options:0
                           error:&fileCoordinatorError
                      byAccessor:^(NSURL *writingFileUrl) {
                        NSError *error;
                        NSData *data = [GULSecureCoding archivedDataWithRootObject:dictionary
                                                                             error:&error];
                        if (error != nil) {
                          NSLog(@"Error getting encoded data %@", error);
                        } else {
                          isWritingSuccess = [data writeToURL:writingFileUrl atomically:YES];
                        }
                      }];
  return isWritingSuccess;
}

@end
