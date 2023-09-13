// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// TODO: Enable warning when ready to surface deprecation to customers.
// TODO: When warning is enabled, ensure it is reflected in release note.
// #warning("""
// The FirebaseInAppMessagingSwift module is deprecated and will be removed in
// the future. All of the public API from FirebaseInAppMessagingSwift can now be
// accessed through the FirebaseInAppMessaging module. To migrate, delete imports
// of FirebaseInAppMessagingSwift and remove the module as a dependency to your
// project. If applicable, any APIs namespaced with `FirebaseInAppMessagingSwift`
// can now be namespaced with `FirebaseInAppMessaging`. Additionally, if
// applicable, `@testable import FirebaseInAppMessagingSwift` should be replaced
// with `@testable import FirebaseInAppMessaging`.
// """)

// The `@_exported` is needed to prevent breaking clients that are using
// types prefixed with the `FirebaseInAppMessaingSwift` namepsace. The entire
// FirebaseInAppMessaging module is re-exported since there exists API defined
// in Swift that cannot be selectively re-exported (e.g. extensions).
@_exported import FirebaseInAppMessaging
