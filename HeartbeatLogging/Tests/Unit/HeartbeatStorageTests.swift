// Copyright 2021 Google LLC
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
@testable import HeartbeatLogging

// TODO: Add additional validation (#8896 comments).

extension Weak: Equatable {
  public static func == (lhs: Weak<Object>, rhs: Weak<Object>) -> Bool {
    lhs.object === rhs.object
  }
}

enum DummyError: Error {
  case error
}

class StorageFake: Storage {
  private var data: Data?

  var failOnNextRead = false
  var failOnNextWrite = false

  func read() throws -> Data {
    if failOnNextRead {
      failOnNextRead.toggle()
      throw DummyError.error
    } else {
      return try data ?? { throw DummyError.error }()
    }
  }

  func write(_ value: Data?) throws {
    if failOnNextWrite {
      failOnNextWrite.toggle()
      throw DummyError.error
    } else {
      data = value
    }
  }
}

class HeartbeatStorageTests: XCTestCase {
  // MARK: - Instance Management

  func testGettingInstance_WhenInstanceDoesNotExist_ReturnsNewInstance() {
    // Given
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
    // When
    let heartbeatStorage = HeartbeatStorage.getInstance(id: "sparky")
    // Then
    XCTAssertEqual(
      HeartbeatStorage.cachedInstances,
      ["sparky": Weak(object: heartbeatStorage)]
    )

    addTeardownBlock {
      // Assert that deallocated `HeartbeatStorage` is removed
      // from cached instances.
      XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
    }
  }

  func testGettingInstance_WhenInstanceDoesExist_ReturnsExistingInstance() {
    // Given
    let cachedHeartbeatStorage = HeartbeatStorage.getInstance(id: "sparky")
    XCTAssertEqual(
      HeartbeatStorage.cachedInstances,
      ["sparky": Weak(object: cachedHeartbeatStorage)]
    )
    // When
    let heartbeatStorage = HeartbeatStorage.getInstance(id: "sparky")
    // Then
    XCTAssert(heartbeatStorage === cachedHeartbeatStorage)

    addTeardownBlock {
      // Assert that deallocated `HeartbeatStorage` is removed
      // from cached instances.
      XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
    }
  }

  func testCachedInstancesAreRemovedUponDeinit() {
    // Given
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
    var heartbeatStorage1: HeartbeatStorage? = .getInstance(id: "sparky")
    var heartbeatStorage2: HeartbeatStorage? = .getInstance(id: "sparky")
    XCTAssertNotNil(heartbeatStorage1)
    XCTAssertNotNil(heartbeatStorage2)
    XCTAssert(heartbeatStorage1 === heartbeatStorage2)
    // When
    heartbeatStorage1 = nil
    // - Then
    XCTAssertNil(heartbeatStorage1)
    XCTAssertNotNil(heartbeatStorage2)
    XCTAssertEqual(
      HeartbeatStorage.cachedInstances,
      ["sparky": Weak(object: heartbeatStorage2)]
    )
    // When
    heartbeatStorage2 = nil
    // - Then
    XCTAssertNil(heartbeatStorage2)
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])

    // Then
    let heartbeatStorage = HeartbeatStorage.getInstance(id: "sparky")
    XCTAssertEqual(
      HeartbeatStorage.cachedInstances,
      ["sparky": Weak(object: heartbeatStorage)]
    )
  }

  func testDeinit_WhenCached_RemovesInstanceFromInstanceCache() {
    // Given
    var heartbeatStorage: HeartbeatStorage? = .getInstance(id: "sparky")
    XCTAssertEqual(
      HeartbeatStorage.cachedInstances,
      ["sparky": Weak(object: heartbeatStorage)]
    )
    // When
    heartbeatStorage = nil
    // Then
    XCTAssertNil(heartbeatStorage)
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
  }

  func testDeinit_WhenNotCached_DoesNotAffectInstanceCache() {
    // Given
    var heartbeatStorage: HeartbeatStorage?
    heartbeatStorage = HeartbeatStorage(id: "sparky", storage: StorageFake())
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
    // When
    heartbeatStorage = nil
    // Then
    XCTAssertNil(heartbeatStorage)
    XCTAssertEqual(HeartbeatStorage.cachedInstances, [:])
  }
}

// MARK: - HeartbeatStorageProtocol

// MARK: - HeartbeatStorage + StorageFactory

// extension HeartbeatStorageTests {
//  func testOfferHeartbeatThenFlush() throws {
//    // Given
//    let storage = HeartbeatStorage(id: #file, storage: StorageFake())
//    XCTAssertNil(storage.flush())
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    XCTAssertNotNil(storage.flush())
//  }
//
//  func testOfferHeartbeatWithStorageReadError() throws {
//    // Given
//    let (storageFake, queue) = (StorageFake(), DispatchQueue(label: #function))
//    let storage = HeartbeatStorage(id: #file, storage: storageFake, queue: queue)
//    XCTAssertNil(storage.flush())
//    storageFake.failOnNextRead = true
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    drain(queue)
//    // Expect
//    XCTAssertNotNil(storage.flush())
//  }
//
//  func testOfferHeartbeatWithStorageWriteError() throws {
//    // Given
//    let (storageFake, queue) = (StorageFake(), DispatchQueue(label: #function))
//    let storage = HeartbeatStorage(id: #file, storage: storageFake, queue: queue)
//    XCTAssertNil(storage.flush())
//    storage.offer(Heartbeat(info: #function))
//    drain(queue)
//    storageFake.failOnNextWrite = true
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    drain(queue)
//    // Expect
//    XCTAssertNotNil(storage.flush())
//  }
//
//  func testOfferHeartbeatWithEncodingError() throws {
//    // Given
//    let coderFake = CoderFake()
//    let storage = HeartbeatStorage(id: #file, storage: StorageFake(), coder: coderFake)
//    XCTAssertNil(storage.flush())
//    coderFake.failOnNextEncode = true
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    XCTAssertNil(storage.flush())
//  }
//
//  func testOfferHeartbeatWithDecodingError() throws {
//    // Given
//    let coderFake = CoderFake()
//    let storage = HeartbeatStorage(id: #file, storage: StorageFake(), coder: coderFake)
//    coderFake.failOnNextDecode = true
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    XCTAssertNil(storage.flush())
//  }
//
//  func testOfferHeartbeatWithErrorThenOffer() throws {
//    // Given
//    let (storageFake, queue) = (StorageFake(), DispatchQueue(label: #function))
//    let storage = HeartbeatStorage(id: #file, storage: storageFake, queue: queue)
//    storageFake.failOnNextWrite = true
//    storage.offer(Heartbeat(info: #function))
//    drain(queue)
//    XCTAssertNil(storage.flush())
//    // When
//    storage.offer(Heartbeat(info: #function))
//    // Then
//    drain(queue)
//    // Expect
//    XCTAssertNotNil(storage.flush())
//  }
//
//  func testFlushWithStorageReadError() throws {
//    // Given
//    let (storageFake, queue) = (StorageFake(), DispatchQueue(label: #function))
//    let storage = HeartbeatStorage(id: #file, storage: storageFake, queue: queue)
//    // Storage is non-empty.
//    storage.offer(Heartbeat(info: #function))
//    drain(queue)
//    storageFake.failOnNextRead = true
//    // When
//    let flushed = storage.flush()
//    // Then
//    XCTAssertNil(flushed)
//    // Storage should empty on successful flush to recover for future reads.
//    XCTAssertNil(storage.flush())
//  }
//
//  func testFlushWithStorageWriteError() throws {
//    // Given
//    let (storageFake, queue) = (StorageFake(), DispatchQueue(label: #function))
//    let storage = HeartbeatStorage(id: #file, storage: storageFake, queue: queue)
//    // Storage is non-empty.
//    storage.offer(Heartbeat(info: #function))
//    drain(queue)
//    storageFake.failOnNextWrite = true
//    // When
//    let flushed = storage.flush()
//    // Then
//    XCTAssertNil(flushed)
//    // Flushing storage returns flushed contents when flush was successful.
//    XCTAssertNotNil(storage.flush())
//  }
// }
//
///// Dispatches a block to a given queue and returns when the block has executed.
///// - Parameter queue: The queue to drain.
// func drain(_ queue: DispatchQueue) {
//  queue.sync {}
// }
//
//// MARK: - Fakes
//
// private extension HeartbeatStorageTests {
//  enum DummyError: Error {
//    case error
//  }
//
//  class StorageFake: PersistentStorage {
//    private var data: Data?
//
//    var failOnNextRead = false
//    var failOnNextWrite = false
//
//    func read() throws -> Data {
//      if failOnNextRead {
//        failOnNextRead.toggle()
//        throw DummyError.error
//      } else {
//        return try data ?? { throw DummyError.error }()
//      }
//    }
//
//    func write(_ value: Data?) throws {
//      if failOnNextWrite {
//        failOnNextWrite.toggle()
//        throw DummyError.error
//      } else {
//        data = value
//      }
//    }
//  }
//
//  class CoderFake: Coder {
//    var failOnNextDecode = false
//    var failOnNextEncode = false
//
//    func decode<T>(_ type: T.Type,
//                   from data: Data) throws -> T where T: Decodable {
//      if failOnNextDecode {
//        failOnNextDecode.toggle()
//        throw DummyError.error
//      } else {
//        return try JSONDecoder().decode(type, from: data)
//      }
//    }
//
//    func encode<T>(_ value: T) throws -> Data where T: Encodable {
//      if failOnNextEncode {
//        failOnNextEncode.toggle()
//        throw DummyError.error
//      } else {
//        return try JSONEncoder().encode(value)
//      }
//    }
//  }
// }
