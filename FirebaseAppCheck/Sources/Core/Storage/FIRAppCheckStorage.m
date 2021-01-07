/*
 * Copyright 2020 Google LLC
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

#import "FirebaseAppCheck/Sources/Core/Storage/FIRAppCheckStorage.h"

#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif

#import <GoogleUtilities/GULKeychainStorage.h>

#import "FirebaseAppCheck/Sources/Core/Storage/FIRAppCheckStoredToken+FIRAppCheckToken.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kKeychainService = @"com.firebase.app_check.token_storage";

@interface FIRAppCheckStorage ()

@property(nonatomic, readonly) NSString *appName;
@property(nonatomic, readonly) GULKeychainStorage *keychainStorage;
@property(nonatomic, readonly, nullable) NSString *accessGroup;

@end

@implementation FIRAppCheckStorage

- (instancetype)initWithAppName:(NSString *)appName
                keychainStorage:(GULKeychainStorage *)keychainStorage
                    accessGroup:(nullable NSString *)accessGroup {
  self = [super init];
  if (self) {
    _appName = [appName copy];
    _keychainStorage = keychainStorage;
    _accessGroup = [accessGroup copy];
  }
  return self;
}

- (instancetype)initWithAppName:(NSString *)appName accessGroup:(nullable NSString *)accessGroup {
  GULKeychainStorage *keychainStorage =
      [[GULKeychainStorage alloc] initWithService:kKeychainService];
  return [self initWithAppName:appName keychainStorage:keychainStorage accessGroup:accessGroup];
}

- (FBLPromise<FIRAppCheckToken *> *)getToken {
  return [self.keychainStorage getObjectForKey:[self tokenKey]
                                   objectClass:[FIRAppCheckStoredToken class]
                                   accessGroup:self.accessGroup]
      .then(^FIRAppCheckToken *(id<NSSecureCoding> storedToken) {
        if ([(NSObject *)storedToken isKindOfClass:[FIRAppCheckStoredToken class]]) {
          return [(FIRAppCheckStoredToken *)storedToken appCheckToken];
        } else {
          return nil;
        }
      });
}

- (FBLPromise<NSNull *> *)setToken:(nullable FIRAppCheckToken *)token {
  if (token) {
    FIRAppCheckStoredToken *storedToken = [[FIRAppCheckStoredToken alloc] init];
    [storedToken updateWithToken:token];
    return [self.keychainStorage setObject:storedToken
                                    forKey:[self tokenKey]
                               accessGroup:self.accessGroup]
        .then(^id _Nullable(NSNull *_Nullable value) {
          return token;
        });
  } else {
    return
        [self.keychainStorage removeObjectForKey:[self tokenKey] accessGroup:self.accessGroup].then(
            ^id _Nullable(NSNull *_Nullable value) {
              return nil;
            });
  }
}

- (NSString *)tokenKey {
  return [[self class] tokenKeyForAppName:self.appName];
}

+ (NSString *)tokenKeyForAppName:(NSString *)appName {
  return [NSString stringWithFormat:@"app_check_token.%@", appName];
}

@end

NS_ASSUME_NONNULL_END
