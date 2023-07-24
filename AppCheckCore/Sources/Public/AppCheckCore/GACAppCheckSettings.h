/*
 * Copyright 2023 Google LLC
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

/// A collection of App Check-wide settings and parameters.
NS_SWIFT_NAME(AppCheckCoreSettingsProtocol)
@protocol GACAppCheckSettingsProtocol <NSObject>

/// If App Check token auto-refresh is enabled.
@property(nonatomic, readonly) BOOL isTokenAutoRefreshEnabled;

@end

@interface GACAppCheckSettings : NSObject <GACAppCheckSettingsProtocol>

- (instancetype)initWithTokenAutoRefreshEnabled:(BOOL)tokenAutoRefreshEnabled;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
