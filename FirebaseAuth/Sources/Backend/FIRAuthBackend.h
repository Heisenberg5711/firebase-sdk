/*
 * Copyright 2017 Google
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

@protocol FIRAuthRPCRequest;
@protocol FIRAuthRPCResponse;
@class FIRAuthRequestConfiguration;
@class FIRVerifyPhoneNumberResponse;
// TODO: FIRSignUpNewUserResponse Used in extra internal functions in FIRAuth.m
@class FIRSignUpNewUserResponse;

@protocol FIRAuthBackendImplementation;
@protocol FIRAuthBackendRPCIssuer;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthBackendRPCIssuerCompletionHandler
    @brief The type of block used to return the result of a call to an endpoint.
    @param data The HTTP response body.
    @param error The error which occurred, if any.
    @remarks One of response or error will be non-nil.
 */
typedef void (^FIRAuthBackendRPCIssuerCompletionHandler)(NSData *_Nullable data,
                                                         NSError *_Nullable error);

/** @typedef FIRSignupNewUserCallback
    @brief The type of block used to return the result of a call to the signupNewUser endpoint.
    @param response The received response, if any.
    @param error The error which occurred, if any.
    @remarks One of response or error will be non-nil.
 */
typedef void (^FIRSignupNewUserCallback)(FIRSignUpNewUserResponse *_Nullable response,
                                         NSError *_Nullable error);

/** @typedef FIRVerifyPhoneNumberResponseCallback
    @brief The type of block used to return the result of a call to the verifyPhoneNumber endpoint.
    @param response The received response, if any.
    @param error The error which occurred, if any.
    @remarks One of response or error will be non-nil.
 */
typedef void (^FIRVerifyPhoneNumberResponseCallback)(
    FIRVerifyPhoneNumberResponse *_Nullable response, NSError *_Nullable error);

/** @class FIRAuthBackend
    @brief Simple static class with methods representing the backend RPCs.
    @remarks All callback blocks passed as method parameters are invoked asynchronously on the
        global work queue in the future. See
        https://github.com/firebase/firebase-ios-sdk/tree/master/FirebaseAuth/Docs/threading.md
 */
@interface FIRAuthBackend : NSObject

/** @fn authUserAgent
    @brief Retrieves the Firebase Auth user agent.
    @return The Firebase Auth user agent.
 */
+ (NSString *)authUserAgent;

+ (id<FIRAuthBackendImplementation>)implementation;

/** @fn setBackendImplementation:
    @brief Changes the default backend implementation to something else.
    @param backendImplementation The backend implementation to use.
    @remarks This is not, generally, safe to call in a scenario where other backend requests may
        be occuring. This is specifically to help mock the backend for testing purposes.
 */
+ (void)setBackendImplementation:(id<FIRAuthBackendImplementation>)backendImplementation;

/** @fn setDefaultBackendImplementationWithRPCIssuer:
    @brief Uses the default backend implementation, but with a custom RPC issuer.
    @param RPCIssuer The RPC issuer to use. If @c nil, will use the default implementation.
    @remarks This is not, generally, safe to call in a scenario where other backend requests may
        be occuring. This is specifically to help test the backend interfaces (requests, responses,
        and shared FIRAuthBackend logic.)
 */
+ (void)setDefaultBackendImplementationWithRPCIssuer:
    (nullable id<FIRAuthBackendRPCIssuer>)RPCIssuer;

@end

/** @protocol FIRAuthBackendRPCIssuer
    @brief Used to make FIRAuthBackend
 */
@protocol FIRAuthBackendRPCIssuer <NSObject>

/** @fn asyncPostToURLWithRequestConfiguration:URL:body:contentType:completionHandler:
    @brief Asynchronously seXnds a POST request.
    @param requestConfiguration The request to be made.
    @param URL The request URL.
    @param body Request body.
    @param contentType Content type of the body.
    @param handler provided that handles POST response. Invoked asynchronously on the auth global
        work queue in the future.
 */
- (void)asyncPostToURLWithRequestConfiguration:(FIRAuthRequestConfiguration *)requestConfiguration
                                           URL:(NSURL *)URL
                                          body:(nullable NSData *)body
                                   contentType:(NSString *)contentType
                             completionHandler:(FIRAuthBackendRPCIssuerCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
