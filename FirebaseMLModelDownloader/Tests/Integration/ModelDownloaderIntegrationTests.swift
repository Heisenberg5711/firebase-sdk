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

import XCTest
@testable import FirebaseCore
@testable import FirebaseMLModelDownloader

extension UserDefaults {
  /// For testing: returns a new cleared instance of user defaults.
  static func getTestInstance() -> UserDefaults {
    let suiteName = "com.google.firebase.ml.test"
    // TODO: reconsider force unwrapping
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
  }
}

final class ModelDownloaderIntegrationTests: XCTestCase {
  override class func setUp() {
    super.setUp()
    let bundle = Bundle(for: self)
    if let plistPath = bundle.path(forResource: "GoogleService-Info", ofType: "plist"),
      let options = FirebaseOptions(contentsOfFile: plistPath) {
      FirebaseApp.configure(options: options)
    } else {
      XCTFail("Could not locate GoogleService-Info.plist.")
    }
  }

  /// Test to retrieve FIS token - makes an actual network call.
  func testGetAuthToken() {
    guard let testApp = FirebaseApp.app() else {
      XCTFail("Default app was not configured.")
      return
    }
    let testModelName = "image-classification"
    let modelInfoRetriever = ModelInfoRetriever(
      app: testApp,
      modelName: testModelName,
      defaults: .getTestInstance()
    )
    let expectation = self.expectation(description: "Wait for FIS auth token.")
    modelInfoRetriever.getAuthToken(completion: { result in
      switch result {
      case let .success(token):
        XCTAssertNotNil(token)
      case let .failure(error):
        XCTFail(error.localizedDescription)
      }
      expectation.fulfill()

    })
    waitForExpectations(timeout: 5, handler: nil)
  }

  /// Test to download model info - makes an actual network call.
  func testDownloadModelInfo() {
    guard let testApp = FirebaseApp.app() else {
      XCTFail("Default app was not configured.")
      return
    }
    let testModelName = "pose-detection"
    let modelInfoRetriever = ModelInfoRetriever(
      app: testApp,
      modelName: testModelName,
      defaults: .getTestInstance()
    )
    let downloadExpectation = expectation(description: "Wait for model info to download.")
    modelInfoRetriever.downloadModelInfo(completion: { error in
      XCTAssertNil(error)
      guard let modelInfo = modelInfoRetriever.modelInfo else {
        XCTFail("Empty model info.")
        return
      }
      XCTAssertNotEqual(modelInfo.downloadURL, "")
      XCTAssertNotEqual(modelInfo.modelHash, "")
      XCTAssertGreaterThan(modelInfo.size, 0)
      downloadExpectation.fulfill()
    })

    waitForExpectations(timeout: 5, handler: nil)

    let retrieveExpectation = expectation(description: "Wait for model info to be retrieved.")
    modelInfoRetriever.downloadModelInfo(completion: { error in
      XCTAssertNil(error)
      guard let modelInfo = modelInfoRetriever.modelInfo else {
        XCTFail("Empty model info.")
        return
      }
      XCTAssertNotEqual(modelInfo.downloadURL, "")
      XCTAssertNotEqual(modelInfo.modelHash, "")
      XCTAssertGreaterThan(modelInfo.size, 0)
      retrieveExpectation.fulfill()
    })

    waitForExpectations(timeout: 500, handler: nil)
  }
}
