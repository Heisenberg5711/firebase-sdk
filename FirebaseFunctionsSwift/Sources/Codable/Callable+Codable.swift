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

import Foundation
import FirebaseFunctions
import FirebaseSharedSwift

public extension Functions {
  /// Creates a reference to the Callable HTTPS trigger with the given name, the type of an `Encodable`
  /// request and the type of a `Decodable` response.
  /// - Parameter name: The name of the Callable HTTPS trigger
  /// - Parameter requestType: The type of the `Encodable` entity to use for requests to this `Callable`
  /// - Parameter responseType: The type of the `Decodable` entity to use for responses from this `Callable`
  func httpsCallable<Request: Encodable,
    Response: Decodable>(_ name: String,
                         requestAs requestType: Request.Type = Request.self,
                         responseAs responseType: Response.Type = Response.self,
                         encoder: FirebaseDataEncoder = FirebaseDataEncoder(),
                         decoder: FirebaseDataDecoder = FirebaseDataDecoder())
    -> Callable<Request, Response> {
    return Callable(callable: httpsCallable(name), encoder: encoder, decoder: decoder)
  }
}

// A `Callable` is reference to a particular Callable HTTPS trigger in Cloud Functions.
public struct Callable<Request: Encodable, Response: Decodable> {
  /// The timeout to use when calling the function. Defaults to 60 seconds.
  public var timeoutInterval: TimeInterval {
    get {
      callable.timeoutInterval
    }
    set {
      callable.timeoutInterval = newValue
    }
  }

  enum CallableError: Error {
    case internalError
  }

  private let callable: HTTPSCallable
  private let encoder: FirebaseDataEncoder
  private let decoder: FirebaseDataDecoder

  init(callable: HTTPSCallable, encoder: FirebaseDataEncoder, decoder: FirebaseDataDecoder) {
    self.callable = callable
    self.encoder = encoder
    self.decoder = decoder
  }

  /// Executes this Callable HTTPS trigger asynchronously.
  ///
  /// The data passed into the trigger must be of the generic `Request` type:
  ///
  /// The request to the Cloud Functions backend made by this method automatically includes a
  /// FCM token to identify the app instance. If a user is logged in with Firebase
  /// Auth, an auth ID token for the user is also automatically included.
  ///
  /// Firebase Cloud Messaging sends data to the Firebase backend periodically to collect information
  /// regarding the app instance. To stop this, see `Messaging.deleteData()`. It
  /// resumes with a new FCM Token the next time you call this method.
  ///
  /// - Parameter data: Parameters to pass to the trigger.
  /// - Parameter completion: The block to call when the HTTPS request has completed.
  public func call(_ data: Request,
                   completion: @escaping (Result<Response, Error>)
                     -> Void) {
    do {
      let encoded = try encoder.encode(data)

      callable.call(encoded) { result, error in
        do {
          if let result = result {
            let decoded = try decoder.decode(Response.self, from: result.data)
            completion(.success(decoded))
          } else if let error = error {
            completion(.failure(error))
          } else {
            completion(.failure(CallableError.internalError))
          }
        } catch {
          completion(.failure(error))
        }
      }
    } catch {
      completion(.failure(error))
    }
  }

  /// Creates a directly callable function.
  ///
  /// This allows users to call a HTTPS Callable Function like a normal Swift function:
  /// ```swift
  ///     let greeter = functions.httpsCallable("greeter",
  ///                                           requestType: GreetingRequest.self,
  ///                                           responseType: GreetingResponse.self)
  ///     greeter(data) { result in
  ///       print(result.greeting)
  ///     }
  /// ```
  /// You can also call a HTTPS Callable function using the following syntax:
  /// ```swift
  ///     let greeter: Callable<GreetingRequest, GreetingResponse> = functions.httpsCallable("greeter")
  ///     greeter(data) { result in
  ///       print(result.greeting)
  ///     }
  /// ```
  /// - Parameters:
  ///   - data: Parameters to pass to the trigger.
  ///   - completion: The block to call when the HTTPS request has completed.
  public func callAsFunction(_ data: Request,
                             completion: @escaping (Result<Response, Error>)
                               -> Void) {
    call(data, completion: completion)
  }

  #if compiler(>=5.5) && canImport(_Concurrency)
    /// Executes this Callable HTTPS trigger asynchronously.
    ///
    /// The data passed into the trigger must be of the generic `Request` type:
    ///
    /// The request to the Cloud Functions backend made by this method automatically includes a
    /// FCM token to identify the app instance. If a user is logged in with Firebase
    /// Auth, an auth ID token for the user is also automatically included.
    ///
    /// Firebase Cloud Messaging sends data to the Firebase backend periodically to collect information
    /// regarding the app instance. To stop this, see `Messaging.deleteData()`. It
    /// resumes with a new FCM Token the next time you call this method.
    ///
    /// - Parameter data: The `Request` representing the data to pass to the trigger.
    ///
    /// - Throws: An error if any value throws an error during encoding.
    /// - Throws: An error if any value throws an error during decoding.
    /// - Throws: An error if the callable fails to complete
    ///
    /// - Returns: The decoded `Response` value
    @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
    public func call(_ data: Request,
                     encoder: FirebaseDataEncoder = FirebaseDataEncoder(),
                     decoder: FirebaseDataDecoder =
                       FirebaseDataDecoder()) async throws -> Response {
      let encoded = try encoder.encode(data)
      let result = try await callable.call(encoded)
      return try decoder.decode(Response.self, from: result.data)
    }

    /// Creates a directly callable function.
    ///
    /// This allows users to call a HTTPS Callable Function like a normal Swift function:
    /// ```swift
    ///     let greeter = functions.httpsCallable("greeter",
    ///                                           requestType: GreetingRequest.self,
    ///                                           responseType: GreetingResponse.self)
    ///     let result = try await greeter(data)
    ///     print(result.greeting)
    /// ```
    /// You can also call a HTTPS Callable function using the following syntax:
    /// ```swift
    ///     let greeter: Callable<GreetingRequest, GreetingResponse> = functions.httpsCallable("greeter")
    ///     let result = try await greeter(data)
    ///     print(result.greeting)
    /// ```
    /// - Parameters:
    ///   - data: Parameters to pass to the trigger.
    /// - Returns: The decoded `Response` value
    @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
    public func callAsFunction(_ data: Request) async throws -> Response {
      return try await call(data)
    }
  #endif
}
