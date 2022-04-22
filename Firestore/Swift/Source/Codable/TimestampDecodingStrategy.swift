/*
 * Copyright 2021 Google LLC
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

import Foundation
import FirebaseFirestore

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
private var _iso8601Formatter: ISO8601DateFormatter = {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = .withInternetDateTime
  return formatter
}()

public extension Firestore.Decoder.DateDecodingStrategy {
  /// Decode the `Date` from a Firestore `Timestamp`
  static var timestamp: Firestore.Decoder.DateDecodingStrategy {
    return .custom { decoder in
      let container = try decoder.singleValueContainer()
      let value = try container.decode(Timestamp.self)
      return value.dateValue()
    }
  }
}
