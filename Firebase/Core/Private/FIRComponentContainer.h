/*
 * Copyright 2018 Google
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

#import "FIRComponentType.h"

NS_ASSUME_NONNULL_BEGIN

/// Retrieve a component from a container.
#define FIR_COMPONENT(type, container) \
  [FIRComponentType<id<type>> instanceForProtocol:@protocol(type) inContainer:container]

@class FIRApp;

NS_SWIFT_NAME(FirebaseComponentContainer)
@interface FIRComponentContainer : NSObject

/// A weak reference to the app that an instance of the container belongs to.
@property(nonatomic, weak, readonly) FIRApp *app;

- (instancetype)init NS_UNAVAILABLE;

/// TODO(wilsonryan): Rename this, maybe "provideComponents:", registerAsComponentProvider:?
+ (void)registerAsComponentRegistrant:(Class)klass;

@end

NS_ASSUME_NONNULL_END
