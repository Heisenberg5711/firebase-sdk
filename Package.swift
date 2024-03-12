// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

// Copyright 2020 Google LLC
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

import class Foundation.ProcessInfo
import PackageDescription

let firebaseVersion = "10.23.0"

let package = Package(
  name: "Firebase",
  platforms: [.iOS(.v11), .macCatalyst(.v13), .macOS(.v10_13), .tvOS(.v12), .watchOS(.v7)],
  products: [
    .library(
      name: "FirebaseAnalytics",
      targets: ["FirebaseAnalyticsTarget"]
    ),
    // Adding this library to your project is enough for it to take effect. The module
    // does not need to be imported into any source files.
    .library(
      name: "FirebaseAnalyticsWithoutAdIdSupport",
      targets: ["FirebaseAnalyticsWithoutAdIdSupportTarget"]
    ),
    // Adding this library to your project is enough for it to take effect. The module
    // does not need to be imported into any source files.
    .library(
      name: "FirebaseAnalyticsOnDeviceConversion",
      targets: ["FirebaseAnalyticsOnDeviceConversionTarget"]
    ),
    .library(
      name: "FirebaseAnalyticsSwift",
      targets: ["FirebaseAnalyticsSwiftTarget"]
    ),
    .library(
      name: "FirebaseAuth",
      targets: ["FirebaseAuth"]
    ),
    .library(
      name: "FirebaseAppCheck",
      targets: ["FirebaseAppCheck"]
    ),
    .library(
      name: "FirebaseAppDistribution-Beta",
      targets: ["FirebaseAppDistributionTarget"]
    ),
    .library(
      name: "FirebaseAuthCombine-Community",
      targets: ["FirebaseAuthCombineSwift"]
    ),
    .library(
      name: "FirebaseFirestoreCombine-Community",
      targets: ["FirebaseFirestoreCombineSwift"]
    ),
    .library(
      name: "FirebaseFunctionsCombine-Community",
      targets: ["FirebaseFunctionsCombineSwift"]
    ),
    .library(
      name: "FirebaseStorageCombine-Community",
      targets: ["FirebaseStorageCombineSwift"]
    ),
    .library(
      name: "FirebaseCrashlytics",
      targets: ["FirebaseCrashlytics"]
    ),
    .library(
      name: "FirebaseDatabase",
      targets: ["FirebaseDatabase"]
    ),
    .library(
      name: "FirebaseDatabaseSwift",
      targets: ["FirebaseDatabaseSwift"]
    ),
    .library(
      name: "FirebaseDynamicLinks",
      targets: ["FirebaseDynamicLinksTarget"]
    ),
    .library(
      name: "FirebaseFirestore",
      targets: ["FirebaseFirestoreTarget"]
    ),
    .library(
      name: "FirebaseFirestoreSwift",
      targets: ["FirebaseFirestoreSwiftTarget"]
    ),
    .library(
      name: "FirebaseFunctions",
      targets: ["FirebaseFunctions"]
    ),
    .library(
      name: "FirebaseInAppMessaging-Beta",
      targets: ["FirebaseInAppMessagingTarget"]
    ),
    .library(
      name: "FirebaseInAppMessagingSwift-Beta",
      targets: ["FirebaseInAppMessagingSwift"]
    ),
    .library(
      name: "FirebaseInstallations",
      targets: ["FirebaseInstallations"]
    ),
    .library(
      name: "FirebaseMessaging",
      targets: ["FirebaseMessaging"]
    ),
    .library(
      name: "FirebaseMLModelDownloader",
      targets: ["FirebaseMLModelDownloader"]
    ),
    .library(
      name: "FirebasePerformance",
      targets: ["FirebasePerformanceTarget"]
    ),
    .library(
      name: "FirebaseRemoteConfig",
      targets: ["FirebaseRemoteConfig"]
    ),
    .library(
      name: "FirebaseRemoteConfigSwift",
      targets: ["FirebaseRemoteConfigSwift"]
    ),
    .library(
      name: "FirebaseStorage",
      targets: ["FirebaseStorage"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/promises.git",
      "2.1.0" ..< "3.0.0"
    ),
    .package(
      url: "https://github.com/apple/swift-protobuf.git",
      "1.19.0" ..< "2.0.0"
    ),
    googleAppMeasurementDependency(),
    .package(
      url: "https://github.com/google/GoogleDataTransport.git",
      "9.3.0" ..< "10.0.0"
    ),
    .package(
      url: "https://github.com/google/GoogleUtilities.git",
      "7.12.1" ..< "8.0.0"
    ),
    .package(
      url: "https://github.com/google/gtm-session-fetcher.git",
      "2.1.0" ..< "4.0.0"
    ),
    .package(
      url: "https://github.com/firebase/nanopb.git",
      "2.30909.0" ..< "2.30911.0"
    ),
    abseilDependency(),
    grpcDependency(),
    .package(
      url: "https://github.com/erikdoe/ocmock.git",
      revision: "c5eeaa6dde7c308a5ce48ae4d4530462dd3a1110"
    ),
    .package(
      url: "https://github.com/firebase/leveldb.git",
      "1.22.2" ..< "1.23.0"
    ),
    .package(
      url: "https://github.com/SlaunchaMan/GCDWebServer.git",
      revision: "935e2736044e71e5341663c3cc9a335ba6867a2b"
    ),
    .package(
      url: "https://github.com/google/interop-ios-for-google-sdks.git",
      "100.0.0" ..< "101.0.0"
    ),
    .package(url: "https://github.com/google/app-check.git", "10.18.0" ..< "11.0.0"),
  ],
  targets: [
    .target(
      name: "Firebase",
      path: "CoreOnly/Sources",
      publicHeadersPath: "./"
    ),
    .target(
      name: "FirebaseCore",
      dependencies: [
        "Firebase",
        "FirebaseCoreInternal",
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULLogger", package: "GoogleUtilities"),
      ],
      path: "FirebaseCore/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../.."),
        .define("Firebase_VERSION", to: firebaseVersion),
        // TODO: - Add support for cflags cSetting so that we can set the -fno-autolink option
      ],
      linkerSettings: [
        .linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst, .tvOS])),
        .linkedFramework("AppKit", .when(platforms: [.macOS])),
      ]
    ),
    .testTarget(
      name: "CoreUnit",
      dependencies: [
        "FirebaseCore",
        "SharedTestUtilities",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebaseCore/Tests/Unit",
      exclude: ["Resources/GoogleService-Info.plist"],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),

    // MARK: - Firebase Core Extension

    // Extension of FirebaseCore for consuming by Swift product SDKs.
    // When depending on `FirebaseCoreExtension`, also depend on `FirebaseCore`
    // to avoid potential linker issues.
    .target(
      name: "FirebaseCoreExtension",
      path: "FirebaseCore/Extension",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),

    // MARK: - Firebase Core Internal

    // Shared collection of APIs for internal FirebaseCore usage.
    .target(
      name: "FirebaseCoreInternal",
      dependencies: [
        .product(name: "GULNSData", package: "GoogleUtilities"),
      ],
      path: "FirebaseCore/Internal/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")]
    ),
    .testTarget(
      name: "FirebaseCoreInternalTests",
      dependencies: [
        "FirebaseCoreInternal",
      ],
      path: "FirebaseCore/Internal/Tests"
    ),

    .target(
      name: "FirebaseABTesting",
      dependencies: ["FirebaseCore"],
      path: "FirebaseABTesting/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "ABTestingUnit",
      dependencies: ["FirebaseABTesting", .product(name: "OCMock", package: "ocmock")],
      path: "FirebaseABTesting/Tests/Unit",
      resources: [.process("Resources")],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),

    .target(
      name: "FirebaseAnalyticsTarget",
      dependencies: [.target(name: "FirebaseAnalyticsWrapper",
                             condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseAnalyticsWrap"
    ),

    .target(
      name: "FirebaseAnalyticsWrapper",
      dependencies: [
        .target(
          name: "FirebaseAnalytics",
          condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])
        ),
        .product(name: "GoogleAppMeasurement",
                 package: "GoogleAppMeasurement",
                 condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])),
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
        .product(name: "GULNSData", package: "GoogleUtilities"),
        .product(name: "GULNetwork", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebaseAnalyticsWrapper",
      linkerSettings: [
        .linkedLibrary("sqlite3"),
        .linkedLibrary("c++"),
        .linkedLibrary("z"),
        .linkedFramework("StoreKit"),
      ]
    ),
    .binaryTarget(
      name: "FirebaseAnalytics",
      url: "https://dl.google.com/firebase/ios/swiftpm/10.22.0/FirebaseAnalytics-rc1.zip",
      checksum: "78ce96a59962a8946f5df8dd57c7d0d83fd3cf0e14f3efab65c8c65fbdf03a8a"
    ),
    .target(
      name: "FirebaseAnalyticsSwiftTarget",
      dependencies: [.target(name: "FirebaseAnalyticsSwift",
                             condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseAnalyticsSwiftWrap"
    ),
    .target(
      name: "FirebaseAnalyticsSwift",
      dependencies: ["FirebaseAnalyticsWrapper"],
      path: "FirebaseAnalyticsSwift/Sources"
    ),
    .testTarget(
      name: "AnalyticsSwiftUnit",
      dependencies: ["FirebaseAnalyticsSwift"],
      path: "FirebaseAnalyticsSwift/Tests/SwiftUnit"
    ),
    .testTarget(
      name: "AnalyticsObjCAPI",
      dependencies: ["FirebaseAnalyticsSwift"],
      path: "FirebaseAnalyticsSwift/Tests/ObjCAPI"
    ),

    .target(
      name: "FirebaseAnalyticsWithoutAdIdSupportTarget",
      dependencies: [.target(name: "FirebaseAnalyticsWithoutAdIdSupportWrapper",
                             condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseAnalyticsWithoutAdIdSupportWrap"
    ),
    .target(
      name: "FirebaseAnalyticsWithoutAdIdSupportWrapper",
      dependencies: [
        .target(
          name: "FirebaseAnalytics",
          condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])
        ),
        .product(name: "GoogleAppMeasurementWithoutAdIdSupport",
                 package: "GoogleAppMeasurement",
                 condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])),
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
        .product(name: "GULNSData", package: "GoogleUtilities"),
        .product(name: "GULNetwork", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebaseAnalyticsWithoutAdIdSupportWrapper",
      linkerSettings: [
        .linkedLibrary("sqlite3"),
        .linkedLibrary("c++"),
        .linkedLibrary("z"),
        .linkedFramework("StoreKit"),
      ]
    ),

    .target(
      name: "FirebaseAnalyticsOnDeviceConversionTarget",
      dependencies: [
        .product(name: "GoogleAppMeasurementOnDeviceConversion",
                 package: "GoogleAppMeasurement",
                 condition: .when(platforms: [.iOS])),
      ],
      path: "FirebaseAnalyticsOnDeviceConversionWrapper",
      linkerSettings: [
        .linkedLibrary("c++"),
      ]
    ),

    .target(
      name: "FirebaseAppDistributionTarget",
      dependencies: [.target(name: "FirebaseAppDistribution",
                             condition: .when(platforms: [.iOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseAppDistributionWrap"
    ),
    .target(
      name: "FirebaseAppDistribution",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
      ],
      path: "FirebaseAppDistribution/Sources",
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "AppDistributionUnit",
      dependencies: ["FirebaseAppDistribution", .product(name: "OCMock", package: "ocmock")],
      path: "FirebaseAppDistribution/Tests/Unit",
      exclude: ["Swift/"],
      resources: [.process("Resources")],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .testTarget(
      name: "AppDistributionUnitSwift",
      dependencies: ["FirebaseAppDistribution"],
      path: "FirebaseAppDistribution/Tests/Unit/Swift",
      cSettings: [
        .headerSearchPath("../../../.."),
      ]
    ),

    .target(
      name: "FirebaseAuth",
      dependencies: [
        "FirebaseAppCheckInterop",
        "FirebaseCore",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GTMSessionFetcherCore", package: "gtm-session-fetcher"),
        .product(name: "RecaptchaInterop", package: "interop-ios-for-google-sdks"),
      ],
      path: "FirebaseAuth/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ],
      linkerSettings: [
        .linkedFramework("Security"),
        .linkedFramework("SafariServices", .when(platforms: [.iOS])),
      ]
    ),
    // Internal headers only for consuming from Swift.
    .target(
      name: "FirebaseAuthInterop",
      path: "FirebaseAuth/Interop",
      exclude: [
        "CMakeLists.txt",
      ],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "AuthUnit",
      dependencies: [
        "FirebaseAuth",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebaseAuth/Tests/Unit",
      exclude: [
        "FIRAuthKeychainServicesTests.m", // TODO: figure out SPM keychain testing
        "FIRAuthTests.m",
        "FIRUserTests.m",
        "SwiftAPI.swift", // Only builds via CocoaPods testing until Swift source update.
        "SwiftGlobalTests.swift", // Only builds via CocoaPods testing until Swift source update.
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .target(
      name: "FirebaseAuthCombineSwift",
      dependencies: ["FirebaseAuth"],
      path: "FirebaseCombineSwift/Sources/Auth"
    ),
    .target(
      name: "FirebaseFirestoreCombineSwift",
      dependencies: [
        "FirebaseFirestoreTarget",
        "FirebaseFirestoreSwift",
      ],
      path: "FirebaseCombineSwift/Sources/Firestore"
    ),
    .target(
      name: "FirebaseStorageCombineSwift",
      dependencies: [
        "FirebaseStorage",
      ],
      path: "FirebaseCombineSwift/Sources/Storage"
    ),
    .target(
      name: "FirebaseCrashlytics",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        "FirebaseSessions",
        "FirebaseRemoteConfigInterop",
        "FirebaseCrashlyticsSwift",
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "FBLPromises", package: "Promises"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "Crashlytics",
      exclude: [
        "run",
        "CHANGELOG.md",
        "LICENSE",
        "README.md",
        "ProtoSupport/",
        "UnitTests/",
        "generate_project.sh",
        "upload-symbols",
        "CrashlyticsInputFiles.xcfilelist",
        "third_party/libunwind/LICENSE",
        "Crashlytics/Rollouts/",
      ],
      sources: [
        "Crashlytics/",
        "Protogen/",
        "Shared/",
        "third_party/libunwind/dwarf.h",
      ],
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Crashlytics/Public",
      cSettings: [
        .headerSearchPath(".."),
        .define("DISPLAY_VERSION", to: firebaseVersion),
        .define("CLS_SDK_NAME", to: "Crashlytics iOS SDK", .when(platforms: [.iOS])),
        .define(
          "CLS_SDK_NAME",
          to: "Crashlytics macOS SDK",
          .when(platforms: [.macOS, .macCatalyst])
        ),
        .define("CLS_SDK_NAME", to: "Crashlytics tvOS SDK", .when(platforms: [.tvOS])),
        .define("CLS_SDK_NAME", to: "Crashlytics watchOS SDK", .when(platforms: [.watchOS])),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ],
      linkerSettings: [
        .linkedFramework("Security"),
        .linkedFramework("SystemConfiguration", .when(platforms: [.iOS, .macOS, .tvOS])),
      ]
    ),
    .target(
      name: "FirebaseCrashlyticsSwift",
      dependencies: ["FirebaseRemoteConfigInterop"],
      path: "Crashlytics",
      sources: [
        "Crashlytics/Rollouts/",
      ]
    ),
    .testTarget(
      name: "FirebaseCrashlyticsSwiftUnit",
      dependencies: ["FirebaseCrashlyticsSwift"],
      path: "Crashlytics/UnitTestsSwift/"
    ),
    .testTarget(
      name: "FirebaseCrashlyticsUnit",
      dependencies: ["FirebaseCrashlytics", .product(name: "OCMock", package: "ocmock")],
      path: "Crashlytics/UnitTests",
      resources: [
        .copy("FIRCLSMachO/machO_data"),
        .copy("Data"),
      ],
      cSettings: [
        .headerSearchPath("../.."),
        .define("DISPLAY_VERSION", to: firebaseVersion),
        .define("CLS_SDK_NAME", to: "Crashlytics iOS SDK", .when(platforms: [.iOS])),
        .define(
          "CLS_SDK_NAME",
          to: "Crashlytics macOS SDK",
          .when(platforms: [.macOS, .macCatalyst])
        ),
        .define("CLS_SDK_NAME", to: "Crashlytics tvOS SDK", .when(platforms: [.tvOS])),
        .define("CLS_SDK_NAME", to: "Crashlytics watchOS SDK", .when(platforms: [.watchOS])),
      ]
    ),
    .target(
      name: "FirebaseDatabaseInternal",
      dependencies: [
        "FirebaseAppCheckInterop",
        "FirebaseCore",
        "leveldb",
      ],
      path: "FirebaseDatabase/Sources",
      exclude: [
        "third_party/Wrap-leveldb/LICENSE",
        "third_party/SocketRocket/LICENSE",
        "third_party/FImmutableSortedDictionary/LICENSE",
        "third_party/SocketRocket/aa2297808c225710e267afece4439c256f6efdb3",
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ],
      linkerSettings: [
        .linkedFramework("CFNetwork"),
        .linkedFramework("Security"),
        .linkedFramework("SystemConfiguration", .when(platforms: [.iOS, .macOS, .tvOS])),
        .linkedFramework("WatchKit", .when(platforms: [.watchOS])),
      ]
    ),
    .testTarget(
      name: "DatabaseUnit",
      dependencies: [
        "FirebaseDatabase",
        "SharedTestUtilities",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebaseDatabase/Tests/",
      exclude: [
        // Disable Swift tests as mixed targets are not supported (Xcode 12.4).
        "Unit/Swift",
        "Integration/",
      ],
      resources: [.process("Resources")],
      cSettings: [
        .headerSearchPath("../.."),
      ]
    ),
    .testTarget(
      name: "DatabaseUnitSwift",
      dependencies: ["FirebaseDatabase"],
      path: "FirebaseDatabase/Tests/Unit/Swift",
      cSettings: [
        .headerSearchPath("../.."),
      ]
    ),
    .target(
      name: "FirebaseDatabase",
      dependencies: ["FirebaseDatabaseInternal", "FirebaseSharedSwift"],
      path: "FirebaseDatabase/Swift/Sources"
    ),
    .target(
      name: "FirebaseDatabaseSwift",
      dependencies: ["FirebaseDatabase"],
      path: "FirebaseDatabaseSwift/Sources"
    ),
    .testTarget(
      name: "FirebaseDatabaseSwiftTests",
      dependencies: ["FirebaseDatabase", "FirebaseDatabaseSwift"],
      path: "FirebaseDatabaseSwift/Tests/"
    ),
    .target(
      name: "FirebaseSharedSwift",
      path: "FirebaseSharedSwift/Sources",
      exclude: [
        "third_party/FirebaseDataEncoder/LICENSE",
        "third_party/FirebaseDataEncoder/METADATA",
      ]
    ),
    .testTarget(
      name: "FirebaseSharedSwiftTests",
      dependencies: ["FirebaseSharedSwift"],
      path: "FirebaseSharedSwift/Tests/"
    ),
    .target(
      name: "FirebaseDynamicLinksTarget",
      dependencies: [.target(name: "FirebaseDynamicLinks",
                             condition: .when(platforms: [.iOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseDynamicLinksWrap"
    ),

    .target(
      name: "FirebaseDynamicLinks",
      dependencies: ["FirebaseCore"],
      path: "FirebaseDynamicLinks/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
        .define("FIRDynamicLinks3P", to: "1"),
        .define("GIN_SCION_LOGGING", to: "1"),
      ],
      linkerSettings: [
        .linkedFramework("QuartzCore"),
      ]
    ),
    firestoreWrapperTarget(),
    .target(
      name: "FirebaseFirestoreSwiftTarget",
      dependencies: [.target(name: "FirebaseFirestoreSwift",
                             condition: .when(platforms: [.iOS, .macCatalyst, .tvOS, .macOS,
                                                          .firebaseVisionOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseFirestoreSwiftWrap"
    ),

    .target(
      name: "FirebaseFirestoreSwift",
      dependencies: [
        "FirebaseFirestoreTarget",
      ],
      path: "FirebaseFirestoreSwift/Sources"
    ),

    // MARK: - Firebase Functions

    .target(
      name: "FirebaseFunctions",
      dependencies: [
        "FirebaseAppCheckInterop",
        "FirebaseAuthInterop",
        "FirebaseCore",
        "FirebaseCoreExtension",
        "FirebaseMessagingInterop",
        "FirebaseSharedSwift",
        .product(name: "GTMSessionFetcherCore", package: "gtm-session-fetcher"),
      ],
      path: "FirebaseFunctions/Sources"
    ),
    .testTarget(
      name: "FirebaseFunctionsUnit",
      dependencies: ["FirebaseFunctions",
                     "FirebaseAppCheckInterop",
                     "FirebaseAuthInterop",
                     "FirebaseMessagingInterop",
                     "SharedTestUtilities"],
      path: "FirebaseFunctions/Tests/Unit",
      cSettings: [
        .headerSearchPath("../../../"),
      ]
    ),
    .testTarget(
      name: "FirebaseFunctionsIntegration",
      dependencies: ["FirebaseFunctions",
                     "SharedTestUtilities"],
      path: "FirebaseFunctions/Tests/Integration"
    ),
    .testTarget(
      name: "FirebaseFunctionsObjCIntegration",
      dependencies: ["FirebaseFunctions",
                     "SharedTestUtilities"],
      path: "FirebaseFunctions/Tests/ObjCIntegration",
      // See https://forums.swift.org/t/importing-swift-libraries-from-objective-c/56730
      exclude: [
        "ObjCPPAPITests.mm",
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .target(
      name: "FirebaseFunctionsCombineSwift",
      dependencies: ["FirebaseFunctions"],
      path: "FirebaseCombineSwift/Sources/Functions"
    ),
    .testTarget(
      name: "FunctionsCombineUnit",
      dependencies: ["FirebaseFunctionsCombineSwift",
                     "SharedTestUtilities"],
      path: "FirebaseFunctions/Tests/CombineUnit"
    ),

    // MARK: - Firebase In App Messaging

    .target(
      name: "FirebaseInAppMessagingTarget",
      dependencies: [
        .target(name: "FirebaseInAppMessaging", condition: .when(platforms: [.iOS, .tvOS])),
      ],
      path: "SwiftPM-PlatformExclude/FirebaseInAppMessagingWrap"
    ),

    .target(
      name: "FirebaseInAppMessagingInternal",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        "FirebaseABTesting",
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
        .target(name: "FirebaseInAppMessaging_iOS", condition: .when(platforms: [.iOS])),
      ],
      path: "FirebaseInAppMessaging/Sources",
      exclude: [
        "DefaultUI/CHANGELOG.md",
        "DefaultUI/README.md",
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ]
    ),

    .target(
      name: "FirebaseInAppMessaging_iOS",
      path: "FirebaseInAppMessaging/iOS",
      resources: [.process("Resources")]
    ),

    .target(
      name: "FirebaseInAppMessaging",
      dependencies: ["FirebaseInAppMessagingInternal"],
      path: "FirebaseInAppMessaging/Swift/Source"
    ),

    .target(
      name: "FirebaseInAppMessagingSwift",
      dependencies: ["FirebaseInAppMessaging"],
      path: "FirebaseInAppMessagingSwift/Sources"
    ),

    .target(
      name: "FirebaseInstallations",
      dependencies: [
        "FirebaseCore",
        .product(name: "FBLPromises", package: "Promises"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
      ],
      path: "FirebaseInstallations/Source/Library",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../../"),
      ],
      linkerSettings: [
        .linkedFramework("Security"),
      ]
    ),

    .target(
      name: "FirebaseMLModelDownloader",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "GULLogger", package: "GoogleUtilities"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
      ],
      path: "FirebaseMLModelDownloader/Sources",
      exclude: [
        "proto/firebase_ml_log_sdk.proto",
      ],
      cSettings: [
        .define("FIRMLModelDownloader_VERSION", to: firebaseVersion),
      ]
    ),
    .testTarget(
      name: "FirebaseMLModelDownloaderUnit",
      dependencies: ["FirebaseMLModelDownloader"],
      path: "FirebaseMLModelDownloader/Tests/Unit"
    ),

    .target(
      name: "FirebaseMessaging",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULReachability", package: "GoogleUtilities"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebaseMessaging/Sources",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ],
      linkerSettings: [
        .linkedFramework("SystemConfiguration", .when(platforms: [.iOS, .macOS, .tvOS])),
      ]
    ),
    // Internal headers only for consuming from Swift.
    .target(
      name: "FirebaseMessagingInterop",
      path: "FirebaseMessaging/Interop",
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "MessagingUnit",
      dependencies: [
        "FirebaseMessaging",
        "SharedTestUtilities",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebaseMessaging/Tests/UnitTests",
      exclude: [
        "FIRMessagingContextManagerServiceTest.m", // TODO: Adapt its NSBundle usage to SPM.
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),

    .target(
      name: "FirebasePerformanceTarget",
      dependencies: [.target(name: "FirebasePerformance",
                             condition: .when(platforms: [.iOS, .tvOS, .firebaseVisionOS]))],
      path: "SwiftPM-PlatformExclude/FirebasePerformanceWrap"
    ),
    .target(
      name: "FirebasePerformance",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        // Performance depends on the Obj-C target of FirebaseRemoteConfig to
        // avoid including Swift code from the `FirebaseRemoteConfig` target
        // that is unneeded.
        "FirebaseRemoteConfigInternal",
        "FirebaseSessions",
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULISASwizzler", package: "GoogleUtilities"),
        .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
        .product(name: "GULUserDefaults", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebasePerformance/Sources",
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
        .define("FIRPerformance_LIB_VERSION", to: firebaseVersion),
      ],
      linkerSettings: [
        .linkedFramework("SystemConfiguration", .when(platforms: [.iOS, .tvOS])),
        .linkedFramework("MobileCoreServices", .when(platforms: [.iOS, .tvOS])),
        .linkedFramework("QuartzCore", .when(platforms: [.iOS, .tvOS])),
      ]
    ),
    .testTarget(
      name: "PerformanceUnit",
      dependencies: [
        "FirebasePerformanceTarget",
        "SharedTestUtilities",
        "GCDWebServer",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebasePerformance/Tests/Unit",
      resources: [
        .process("FPRURLFilterTests-Info.plist"),
        .process("Server/smallDownloadFile"),
        .process("Server/bigDownloadFile"),
      ],
      cSettings: [
        .headerSearchPath("../../.."),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ]
    ),

    .target(
      name: "SharedTestUtilities",
      dependencies: ["FirebaseCore",
                     "FirebaseAppCheckInterop",
                     "FirebaseAuthInterop",
                     "FirebaseMessagingInterop",
                     "GoogleDataTransport",
                     .product(name: "OCMock", package: "ocmock")],
      path: "SharedTestUtilities",
      publicHeadersPath: "./",
      cSettings: [
        .headerSearchPath("../"),
      ]
    ),

    // MARK: - Firebase Remote Config

    .target(
      name: "FirebaseRemoteConfigInternal",
      dependencies: [
        "FirebaseCore",
        "FirebaseABTesting",
        "FirebaseInstallations",
        "FirebaseRemoteConfigInterop",
        .product(name: "GULNSData", package: "GoogleUtilities"),
      ],
      path: "FirebaseRemoteConfig/Sources",
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "RemoteConfigUnit",
      dependencies: ["FirebaseRemoteConfigInternal", .product(name: "OCMock", package: "ocmock")],
      path: "FirebaseRemoteConfig/Tests/Unit",
      exclude: [
        // Need to be evaluated/ported to RC V2.
        "RCNConfigAnalyticsTest.m",
        "RCNConfigSettingsTest.m",
        "RCNConfigTest.m",
        "RCNRemoteConfig+FIRAppTest.m",
        "RCNThrottlingTests.m",
      ],
      resources: [
        .process("SecondApp-GoogleService-Info.plist"),
        .process("Defaults-testInfo.plist"),
        .process("TestABTPayload.txt"),
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .testTarget(
      name: "RemoteConfigSwiftUnit",
      dependencies: ["FirebaseRemoteConfigInternal"],
      path: "FirebaseRemoteConfig/Tests/SwiftUnit",
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .target(
      name: "FirebaseRemoteConfig",
      dependencies: [
        "FirebaseRemoteConfigInternal",
        "FirebaseSharedSwift",
      ],
      path: "FirebaseRemoteConfig/Swift",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "FirebaseRemoteConfigSwift",
      dependencies: [
        "FirebaseRemoteConfig",
      ],
      path: "FirebaseRemoteConfigSwift/Sources"
    ),
    .testTarget(
      name: "RemoteConfigFakeConsole",
      dependencies: ["FirebaseRemoteConfig",
                     "FirebaseRemoteConfigSwift",
                     "RemoteConfigFakeConsoleObjC"],
      path: "FirebaseRemoteConfigSwift/Tests",
      exclude: [
        "AccessToken.json",
        "README.md",
        "ObjC/",
      ],
      resources: [
        .process("Defaults-testInfo.plist"),
      ],
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .target(
      name: "RemoteConfigFakeConsoleObjC",
      dependencies: [.product(name: "OCMock", package: "ocmock")],
      path: "FirebaseRemoteConfigSwift/Tests/ObjC",
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../../"),
      ]
    ),
    // Internal headers only for consuming from other SDK.
    .target(
      name: "FirebaseRemoteConfigInterop",
      path: "FirebaseRemoteConfig/Interop",
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),

    // MARK: - Firebase Sessions

    .target(
      name: "FirebaseSessions",
      dependencies: [
        "FirebaseCore",
        "FirebaseInstallations",
        "FirebaseCoreExtension",
        "FirebaseSessionsObjC",
        .product(name: "Promises", package: "Promises"),
        .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
      ],
      path: "FirebaseSessions/Sources",
      cSettings: [
        .headerSearchPath(".."),
        .define("DISPLAY_VERSION", to: firebaseVersion),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ],
      linkerSettings: [
        .linkedFramework("Security"),
        .linkedFramework(
          "SystemConfiguration",
          .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])
        ),
      ]
    ),
    // The Sessions SDK is Swift-first with Objective-C code to support
    // nanopb. Because Swift Package Manager doesn't support mixed
    // language targets, the ObjC code has been extracted out into
    // a separate target.
    .target(
      name: "FirebaseSessionsObjC",
      dependencies: [
        "FirebaseCore",
        "FirebaseCoreExtension",
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebaseSessions",
      exclude: [
        "README.md",
        "Sources/",
        "Tests/",
        "ProtoSupport/",
        "generate_project.sh",
        "generate_protos.sh",
        "generate_testapp.sh",
      ],
      publicHeadersPath: "SourcesObjC",
      cSettings: [
        .headerSearchPath(".."),
        .define("DISPLAY_VERSION", to: firebaseVersion),
        .define("PB_FIELD_32BIT", to: "1"),
        .define("PB_NO_PACKED_STRUCTS", to: "1"),
        .define("PB_ENABLE_MALLOC", to: "1"),
      ],
      linkerSettings: [
        .linkedFramework("Security"),
        .linkedFramework(
          "SystemConfiguration",
          .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])
        ),
      ]
    ),
    .testTarget(
      name: "FirebaseSessionsUnit",
      dependencies: ["FirebaseSessions"],
      path: "FirebaseSessions/Tests/Unit"
    ),

    // MARK: - Firebase Storage

    .target(
      name: "FirebaseStorage",
      dependencies: [
        "FirebaseAppCheckInterop",
        "FirebaseAuthInterop",
        "FirebaseCore",
        "FirebaseCoreExtension",
        .product(name: "GTMSessionFetcherCore", package: "gtm-session-fetcher"),
      ],
      path: "FirebaseStorage/Sources"
    ),
    .testTarget(
      name: "FirebaseStorageUnit",
      dependencies: ["FirebaseStorage",
                     "SharedTestUtilities"],
      path: "FirebaseStorage/Tests/Unit",
      cSettings: [
        .headerSearchPath("../../../"),
      ]
    ),
    .testTarget(
      name: "StorageObjCIntegration",
      dependencies: ["FirebaseStorage"],
      path: "FirebaseStorage/Tests/ObjCIntegration",
      exclude: [
        // See https://forums.swift.org/t/importing-swift-libraries-from-objective-c/56730
        "FIRStorageIntegrationTests.m",
        "ObjCPPAPITests.mm",
        "Credentials.h",
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .testTarget(
      name: "swift-test",
      dependencies: [
        "Firebase",
        "FirebaseAuth",
        "FirebaseAppCheck",
        "FirebaseABTesting",
        "FirebaseAnalytics",
        "FirebaseAnalyticsSwift",
        .target(name: "FirebaseAppDistribution",
                condition: .when(platforms: [.iOS])),
        "FirebaseAuthCombineSwift",
        "FirebaseFirestoreCombineSwift",
        "FirebaseFunctionsCombineSwift",
        "FirebaseStorageCombineSwift",
        "FirebaseCrashlytics",
        "FirebaseCore",
        "FirebaseDatabase",
        "FirebaseDynamicLinks",
        "FirebaseFirestoreTarget",
        "FirebaseFirestoreSwift",
        "FirebaseFunctions",
        .target(name: "FirebaseInAppMessaging",
                condition: .when(platforms: [.iOS, .tvOS])),
        .target(name: "FirebaseInAppMessagingSwift",
                condition: .when(platforms: [.iOS, .tvOS])),
        "FirebaseInstallations",
        "FirebaseMessaging",
        .target(name: "FirebasePerformance",
                condition: .when(platforms: [.iOS, .tvOS])),
        "FirebaseRemoteConfig",
        "FirebaseSessions",
        "FirebaseStorage",
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "SwiftPMTests/swift-test"
    ),
    .testTarget(
      name: "analytics-import-test",
      dependencies: [
        "FirebaseAnalyticsSwiftTarget",
        "FirebaseAnalyticsWrapper",
        "Firebase",
      ],
      path: "SwiftPMTests/analytics-import-test"
    ),
    .testTarget(
      name: "objc-import-test",
      dependencies: [
        "Firebase",
        "FirebaseAuth",
        "FirebaseABTesting",
        "FirebaseAppCheck",
        .target(name: "FirebaseAppDistribution",
                condition: .when(platforms: [.iOS])),
        "FirebaseCrashlytics",
        "FirebaseCore",
        "FirebaseDatabase",
        "FirebaseDynamicLinks",
        "FirebaseFirestoreTarget",
        "FirebaseFunctions",
        .target(name: "FirebaseInAppMessaging",
                condition: .when(platforms: [.iOS, .tvOS])),
        "FirebaseInstallations",
        "FirebaseMessaging",
        .target(name: "FirebasePerformance",
                condition: .when(platforms: [.iOS, .tvOS])),
        "FirebaseRemoteConfig",
        "FirebaseStorage",
      ],
      path: "SwiftPMTests/objc-import-test"
    ),
    .testTarget(
      name: "version-test",
      dependencies: [
        "FirebaseCore",
      ],
      path: "SwiftPMTests/version-test",
      cSettings: [
        .define("FIR_VERSION", to: firebaseVersion),
      ]
    ),

    // MARK: - Firebase App Check

    .target(name: "FirebaseAppCheck",
            dependencies: [
              "FirebaseAppCheckInterop",
              "FirebaseCore",
              .product(name: "AppCheckCore", package: "app-check"),
              .product(name: "FBLPromises", package: "Promises"),
              .product(name: "GULEnvironment", package: "GoogleUtilities"),
            ],
            path: "FirebaseAppCheck/Sources",
            publicHeadersPath: "Public",
            cSettings: [
              .headerSearchPath("../.."),
            ],
            linkerSettings: [
              .linkedFramework(
                "DeviceCheck",
                .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS])
              ),
            ]),
    // Internal headers only for consuming from Swift.
    .target(
      name: "FirebaseAppCheckInterop",
      path: "FirebaseAppCheck/Interop",
      exclude: [
        "CMakeLists.txt",
      ],
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../../"),
      ]
    ),
    .testTarget(
      name: "FirebaseAppCheckUnit",
      dependencies: [
        "FirebaseAppCheck",
        "SharedTestUtilities",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "FirebaseAppCheck/Tests/Unit",
      exclude: [
        // Swift tests are in the target `FirebaseAppCheckUnitSwift` since mixed language targets
        // are not supported (as of Xcode 15.0).
        "Swift",
      ],
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
    .testTarget(
      name: "FirebaseAppCheckUnitSwift",
      dependencies: ["FirebaseAppCheck"],
      path: "FirebaseAppCheck/Tests/Unit/Swift"
    ),

    // MARK: Testing support

    .target(
      name: "FirebaseFirestoreTestingSupport",
      dependencies: ["FirebaseFirestoreTarget"],
      path: "FirebaseTestingSupport/Firestore/Sources",
      publicHeadersPath: "./",
      cSettings: [
        .headerSearchPath("../../.."),
        .headerSearchPath("../../../Firestore/Source/Public/FirebaseFirestore"),
      ]
    ),
    .testTarget(
      name: "FirestoreTestingSupportTests",
      dependencies: ["FirebaseFirestoreTestingSupport"],
      path: "FirebaseTestingSupport/Firestore/Tests",
      cSettings: [
        .headerSearchPath("../../.."),
      ]
    ),
  ] + firestoreTargets(),
  cLanguageStandard: .c99,
  cxxLanguageStandard: CXXLanguageStandard.gnucxx14
)

// MARK: - Helper Functions

func googleAppMeasurementDependency() -> Package.Dependency {
  let appMeasurementURL = "https://github.com/google/GoogleAppMeasurement.git"

  // Point SPM CI to the tip of main of https://github.com/google/GoogleAppMeasurement so that the
  // release process can defer publishing the GoogleAppMeasurement tag until after testing.
  if ProcessInfo.processInfo.environment["FIREBASECI_USE_LATEST_GOOGLEAPPMEASUREMENT"] != nil {
    return .package(url: appMeasurementURL, branch: "main")
  }

  return .package(url: appMeasurementURL, exact: "10.22.1")
}

func abseilDependency() -> Package.Dependency {
  let packageInfo: (url: String, range: Range<Version>)

  // If building Firestore from source, abseil will need to be built as source
  // as the headers in the binary version of abseil are unusable.
  if ProcessInfo.processInfo.environment["FIREBASE_SOURCE_FIRESTORE"] != nil {
    packageInfo = (
      "https://github.com/firebase/abseil-cpp-SwiftPM.git",
      "0.20240116.1" ..< "0.20240117.0"
    )
  } else {
    packageInfo = (
      "https://github.com/google/abseil-cpp-binary.git",
      "1.2024011601.0" ..< "1.2024011700.0"
    )
  }

  return .package(url: packageInfo.url, packageInfo.range)
}

func grpcDependency() -> Package.Dependency {
  let packageInfo: (url: String, range: Range<Version>)

  // If building Firestore from source, abseil will need to be built as source
  // as the headers in the binary version of abseil are unusable.
  if ProcessInfo.processInfo.environment["FIREBASE_SOURCE_FIRESTORE"] != nil {
    packageInfo = ("https://github.com/grpc/grpc-ios.git", "1.62.3" ..< "1.63.0")
  } else {
    packageInfo = ("https://github.com/google/grpc-binary.git", "1.62.1" ..< "1.63.0")
  }

  return .package(url: packageInfo.url, packageInfo.range)
}

func firestoreWrapperTarget() -> Target {
  if ProcessInfo.processInfo.environment["FIREBASE_SOURCE_FIRESTORE"] != nil {
    return .target(
      name: "FirebaseFirestoreTarget",
      dependencies: [.target(name: "FirebaseFirestore",
                             condition: .when(platforms: [.iOS, .tvOS, .macOS,
                                                          .firebaseVisionOS]))],
      path: "SwiftPM-PlatformExclude/FirebaseFirestoreWrap"
    )
  }

  return .target(
    name: "FirebaseFirestoreTarget",
    dependencies: [.target(name: "FirebaseFirestore",
                           condition: .when(platforms: [.iOS, .tvOS, .macOS, .macCatalyst]))],
    path: "SwiftPM-PlatformExclude/FirebaseFirestoreWrap",
    cSettings: [.define("FIREBASE_BINARY_FIRESTORE", to: "1")]
  )
}

func firestoreTargets() -> [Target] {
  if ProcessInfo.processInfo.environment["FIREBASE_SOURCE_FIRESTORE"] != nil {
    return [
      .target(
        name: "FirebaseFirestoreInternalWrapper",
        dependencies: [
          "FirebaseAppCheckInterop",
          "FirebaseCore",
          "leveldb",
          .product(name: "nanopb", package: "nanopb"),
          .product(name: "abseil", package: "abseil-cpp-SwiftPM"),
          .product(name: "gRPC-cpp", package: "grpc-ios"),
        ],
        path: "Firestore",
        exclude: [
          "CHANGELOG.md",
          "CMakeLists.txt",
          "Example/",
          "LICENSE",
          "Protos/CMakeLists.txt",
          "Protos/Podfile",
          "Protos/README.md",
          "Protos/build_protos.py",
          "Protos/cpp/",
          "Protos/lib/",
          "Protos/nanopb_cpp_generator.py",
          "Protos/protos/",
          "README.md",
          "Source/CMakeLists.txt",
          "Swift/",
          "core/CMakeLists.txt",
          "core/src/util/config_detected.h.in",
          "core/test/",
          "fuzzing/",
          "test.sh",
          // Swift PM doesn't recognize hpp files, so we're relying on search paths
          // to find third_party/nlohmann_json/json.hpp.
          "third_party/",

          // Exclude alternate implementations for other platforms
          "core/src/remote/connectivity_monitor_noop.cc",
          "core/src/util/filesystem_win.cc",
          "core/src/util/log_stdio.cc",
          "core/src/util/secure_random_openssl.cc",
        ],
        sources: [
          "Source/",
          "Protos/nanopb/",
          "core/include/",
          "core/src",
        ],
        publicHeadersPath: "Source/Public",
        cSettings: [
          .headerSearchPath("../"),
          .headerSearchPath("Source/Public/FirebaseFirestore"),
          .headerSearchPath("Protos/nanopb"),
          .define("PB_FIELD_32BIT", to: "1"),
          .define("PB_NO_PACKED_STRUCTS", to: "1"),
          .define("PB_ENABLE_MALLOC", to: "1"),
          .define("FIRFirestore_VERSION", to: firebaseVersion),
        ],
        linkerSettings: [
          .linkedFramework(
            "SystemConfiguration",
            .when(platforms: [.iOS, .macOS, .tvOS, .firebaseVisionOS])
          ),
          .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS, .firebaseVisionOS])),
          .linkedLibrary("c++"),
        ]
      ),
      .target(
        name: "FirebaseFirestore",
        dependencies: [
          "FirebaseCore",
          "FirebaseCoreExtension",
          "FirebaseFirestoreInternalWrapper",
          "FirebaseSharedSwift",
        ],
        path: "Firestore",
        exclude: [
          "CHANGELOG.md",
          "CMakeLists.txt",
          "Example/",
          "LICENSE",
          "Protos/",
          "README.md",
          "Source/",
          "core/",
          "fuzzing/",
          "test.sh",
          "Swift/CHANGELOG.md",
          "Swift/Tests/",
          "third_party/nlohmann_json",
        ],
        sources: [
          "Swift/Source/",
        ],
        resources: [.process("Source/Resources/PrivacyInfo.xcprivacy")]
      ),
    ]
  }

  let firestoreInternalTarget: Target = {
    if ProcessInfo.processInfo.environment["FIREBASECI_USE_LOCAL_FIRESTORE_ZIP"] != nil {
      // This is set when running `scripts/check_firestore_symbols.sh`.
      return .binaryTarget(
        name: "FirebaseFirestoreInternal",
        // The `xcframework` should be moved to the root of the repo.
        path: "FirebaseFirestoreInternal.xcframework"
      )
    } else {
      return .binaryTarget(
        name: "FirebaseFirestoreInternal",
        url: "https://dl.google.com/firebase/ios/bin/firestore/10.22.0/FirebaseFirestoreInternal.zip",
        checksum: "35c02539c6bbd43ec1c3b58f894984e48ff8c560db0c799fb8f6377b59c96099"
      )
    }
  }()

  return [
    .target(
      name: "FirebaseFirestore",
      dependencies: [
        .target(
          name: "FirebaseFirestoreInternalWrapper",
          condition: .when(platforms: [.iOS, .macCatalyst, .tvOS, .macOS])
        ),
        .product(
          name: "abseil",
          package: "abseil-cpp-binary",
          condition: .when(platforms: [.iOS, .macCatalyst, .tvOS, .macOS])
        ),
        .product(
          name: "gRPC-C++",
          package: "grpc-binary",
          condition: .when(platforms: [.iOS, .macCatalyst, .tvOS, .macOS])
        ),
        .product(name: "nanopb", package: "nanopb"),
        "FirebaseAppCheckInterop",
        "FirebaseCore",
        "FirebaseCoreExtension",
        "leveldb",
        "FirebaseSharedSwift",
      ],
      path: "Firestore/Swift/Source",
      resources: [.process("Resources/PrivacyInfo.xcprivacy")],
      linkerSettings: [
        .linkedFramework("SystemConfiguration", .when(platforms: [.iOS, .macOS, .tvOS])),
        .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
        .linkedLibrary("c++"),
      ]
    ),
    .target(
      name: "FirebaseFirestoreInternalWrapper",
      dependencies: [.target(
        name: "FirebaseFirestoreInternal",
        condition: .when(platforms: [.iOS, .macCatalyst, .tvOS, .macOS])
      )],
      path: "FirebaseFirestoreInternal",
      publicHeadersPath: "."
    ),
    firestoreInternalTarget,
  ]
}

extension Platform {
  // Xcode dependent value for the visionOS platform. Namespaced with
  // "firebase" prefix to prevent any API collisions (such issues should not
  // arise as the manifest APIs should be confined to the `Package.swift`).
  static var firebaseVisionOS: Self {
    #if swift(>=5.9)
      // For Xcode 15, return the available `visionOS` platform.
      return .visionOS
    #else
      // For Xcode 14, return `iOS` as visionOS is unavailable. Since all targets
      // support iOS, this acts as a no-op.
      return .iOS
    #endif // swift(>=5.9)
  }
}
