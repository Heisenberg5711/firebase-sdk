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

NS_ASSUME_NONNULL_BEGIN

/** The diagnostics logging notification name. */
static NSString *const kFIRDiagnosticsNotification = @"FIRAppDiagnosticsNotificationKey";

/** The key mapping to the id<FIRCoreDiagnosticsData> object in an NSNotification. */
static NSString *const kFIRDiagnosticsDataNotifKey = @"kFIRDiagnosticsDataNotifKey";

/** If present, is a BOOL wrapped in an NSNumber. */
static NSString *const kFIRCDIsDataCollectionDefaultEnabledKey =
    @"FIRCDIsDataCollectionDefaultEnabledKey";

/** If present, is an int32_t wrapped in an NSNumber. */
static NSString *const kFIRCDConfigurationTypeKey = @"FIRCDConfigurationTypeKey";

/** If present, is an NSString. */
static NSString *const kFIRCDSdkNameKey = @"FIRCDSdkNameKey";

/** If present, is an NSString. */
static NSString *const kFIRCDSdkVersionKey = @"FIRCDSdkVersionKey";

/** If present, is an int32_t wrapped in an NSNumber. */
static NSString *const kFIRCDllAppsCountKey = @"FIRCDllAppsCountKey";

/** If present, is an NSString. */
static NSString *const kFIRCDGoogleAppIDKey = @"FIRCDGoogleAppIDKey";

/** If present, is an NSString. */
static NSString *const kFIRCDBundleIDKey = @"FIRCDBundleID";

/** If present, is a BOOL wrapped in an NSNumber. */
static NSString *const kFIRCDUsingOptionsFromDefaultPlistKey =
    @"FIRCDUsingOptionsFromDefaultPlistKey";

/** If present, is an NSString. */
static NSString *const kFIRCDLibraryVersionIDKey = @"FIRCDLibraryVersionIDKey";

/** If present, is an NSString. */
static NSString *const kFIRCDFirebaseUserAgentKey = @"FIRCDFirebaseUserAgentKey";

/** Defines the interface of a data object needed to log diagnostics data. */
@protocol FIRCoreDiagnosticsData <NSObject>

@required

/** A dictionary containing data (non-exhaustive) to be logged in diagnostics. */
@property(nonatomic) NSDictionary<NSString *, id> *diagnosticObjects;

@end

NS_ASSUME_NONNULL_END
