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

#import "Private/FIRAuth_Internal.h"

#import "FIRAppAssociationRegistration.h"
#import "FIRAppInternal.h"
#import "FIROptions.h"
#import "FIRLogger.h"
#import "AuthProviders/EmailPassword/FIREmailPasswordAuthCredential.h"
#import "AuthProviders/Phone/FIRPhoneAuthCredential_Internal.h"
#import "Private/FIRAdditionalUserInfo_Internal.h"
#import "Private/FIRAuthCredential_Internal.h"
#import "Private/FIRAuthDataResult_Internal.h"
#import "Private/FIRAuthDispatcher.h"
#import "Private/FIRAuthErrorUtils.h"
#import "FIRAuthExceptionUtils.h"
#import "Private/FIRAuthGlobalWorkQueue.h"
#import "Private/FIRAuthKeychain.h"
#import "Private/FIRUser_Internal.h"
#import "FirebaseAuth.h"
#import "FIRAuthBackend.h"
#import "FIRCreateAuthURIRequest.h"
#import "FIRCreateAuthURIResponse.h"
#import "FIRGetOOBConfirmationCodeRequest.h"
#import "FIRGetOOBConfirmationCodeResponse.h"
#import "FIRResetPasswordRequest.h"
#import "FIRResetPasswordResponse.h"
#import "FIRSendVerificationCodeRequest.h"
#import "FIRSendVerificationCodeResponse.h"
#import "FIRSetAccountInfoRequest.h"
#import "FIRSetAccountInfoResponse.h"
#import "FIRSignUpNewUserRequest.h"
#import "FIRSignUpNewUserResponse.h"
#import "FIRVerifyAssertionRequest.h"
#import "FIRVerifyAssertionResponse.h"
#import "FIRVerifyCustomTokenRequest.h"
#import "FIRVerifyCustomTokenResponse.h"
#import "FIRVerifyPasswordRequest.h"
#import "FIRVerifyPasswordResponse.h"
#import "FIRVerifyPhoneNumberRequest.h"
#import "FIRVerifyPhoneNumberResponse.h"

#if TARGET_OS_IOS
#import "Private/FIRAuthAPNSToken.h"
#import "Private/FIRAuthAPNSTokenManager.h"
#import "Private/FIRAuthAppCredentialManager.h"
#import "Private/FIRAuthAppDelegateProxy.h"
#import "Private/FIRAuthNotificationManager.h"
#endif

#pragma mark - Constants

NSString *const FIRAuthStateDidChangeInternalNotification =
    @"FIRAuthStateDidChangeInternalNotification";
NSString *const FIRAuthStateDidChangeInternalNotificationTokenKey =
    @"FIRAuthStateDidChangeInternalNotificationTokenKey";

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
const NSNotificationName FIRAuthStateDidChangeNotification = @"FIRAuthStateDidChangeNotification";
#else
NSString *const FIRAuthStateDidChangeNotification = @"FIRAuthStateDidChangeNotification";
#endif  // defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

/** @var kMaxWaitTimeForBackoff
    @brief The maximum wait time before attempting to retry auto refreshing tokens after a failed
        attempt.
    @remarks This is the upper limit (in seconds) of the exponential backoff used for retrying
        token refresh.
 */
static NSTimeInterval kMaxWaitTimeForBackoff = 16 * 60;

/** @var kTokenRefreshHeadStart
    @brief The amount of time before the token expires that proactive refresh should be attempted.
 */
NSTimeInterval kTokenRefreshHeadStart  = 5 * 60;

/** @var kUserKey
    @brief Key of user stored in the keychain. Prefixed with a Firebase app name.
 */
static NSString *const kUserKey = @"%@_firebase_user";

/** @var kMissingEmailInvalidParameterExceptionReason
    @brief The key of missing email key @c invalidParameterException.
 */
static NSString *const kEmailInvalidParameterReason = @"The email used to initiate password reset "
    "cannot be nil";

static NSString *const kPasswordResetRequestType = @"PASSWORD_RESET";

static NSString *const kVerifyEmailRequestType = @"VERIFY_EMAIL";

/** @var kMissingPasswordReason
    @brief The reason why the @c FIRAuthErrorCodeWeakPassword error is thrown.
    @remarks This error message will be localized in the future.
 */
static NSString *const kMissingPasswordReason = @"Missing Password";

/** @var gKeychainServiceNameForAppName
    @brief A map from Firebase app name to keychain service names.
    @remarks This map is needed for looking up the keychain service name after the FIRApp instance
        is deleted, to remove the associated keychain item. Accessing should occur within a
        @syncronized([FIRAuth class]) context.
 */
static NSMutableDictionary *gKeychainServiceNameForAppName;

#pragma mark - FIRActionCodeInfo

@implementation FIRActionCodeInfo {
  /** @var _email
      @brief The email address to which the code was sent. The new email address in the case of
          FIRActionCodeOperationRecoverEmail.
   */
  NSString *_email;

  /** @var _fromEmail
      @brief The current email address in the case of FIRActionCodeOperationRecoverEmail.
   */
  NSString *_fromEmail;
}

- (NSString *)dataForKey:(FIRActionDataKey)key{
  switch (key) {
    case FIRActionCodeEmailKey:
      return _email;
    case FIRActionCodeFromEmailKey:
      return _fromEmail;
  }
}

- (instancetype)initWithOperation:(FIRActionCodeOperation)operation
                            email:(NSString *)email
                         newEmail:(nullable NSString *)newEmail {
  self = [super init];
  if (self) {
    _operation = operation;
    if (newEmail) {
      _email = [newEmail copy];
      _fromEmail = [email copy];
    } else {
      _email = [email copy];
    }
  }
  return self;
}

/** @fn actionCodeOperationForRequestType:
    @brief Returns the corresponding operation type per provided request type string.
    @param requestType Request type returned in in the server response.
    @return The corresponding FIRActionCodeOperation for the supplied request type.
 */
+ (FIRActionCodeOperation)actionCodeOperationForRequestType:(NSString *)requestType {
  if ([requestType isEqualToString:kPasswordResetRequestType]) {
    return FIRActionCodeOperationPasswordReset;
  }
  if ([requestType isEqualToString:kVerifyEmailRequestType]) {
    return FIRActionCodeOperationVerifyEmail;
  }
  return FIRActionCodeOperationUnknown;
}

@end

#pragma mark - FIRAuth

#if TARGET_OS_IOS
@interface FIRAuth () <FIRAuthAppDelegateHandler>
#else
@interface FIRAuth ()
#endif

/** @property firebaseAppId
    @brief The Firebase app ID.
 */
@property(nonatomic, copy, readonly) NSString *firebaseAppId;

/** @fn initWithApp:
    @brief Creates a @c FIRAuth instance associated with the provided @c FIRApp instance.
    @param app The application to associate the auth instance with.
 */
- (instancetype)initWithApp:(FIRApp *)app;

@end

@implementation FIRAuth {
  /** @var _firebaseAppName
      @brief The Firebase app name.
   */
  NSString *_firebaseAppName;

  /** @var _listenerHandles
      @brief Handles returned from @c NSNotificationCenter for blocks which are "auth state did
          change" notification listeners.
      @remarks Mutations should occur within a @syncronized(self) context.
   */
  NSMutableArray<FIRAuthStateDidChangeListenerHandle> *_listenerHandles;

  /** @var _keychain
      @brief The keychain service.
   */
  FIRAuthKeychain *_keychain;

  /** @var _autoRefreshTokens
      @brief This flag denotes whether or not tokens should be automatically refreshed.
      @remarks Will only be set to @YES if the another Firebase service is included (additionally to
        Firebase Auth).
   */
  BOOL _autoRefreshTokens;

  /** @var _autoRefreshScheduled
      @brief Whether or not token auto-refresh is currently scheduled.
   */
  BOOL _autoRefreshScheduled;

  /** @var _isAppInBackground
      @brief A flag that is set to YES if the app is put in the background and no when the app is
          returned to the foreground.
   */
  BOOL _isAppInBackground;

  /** @var _applicationDidBecomeActiveObserver
      @brief An opaque object to act as the observer for UIApplicationDidBecomeActiveNotification.
   */
  id<NSObject> _applicationDidBecomeActiveObserver;

  /** @var _applicationDidBecomeActiveObserver
      @brief An opaque object to act as the observer for
          UIApplicationDidEnterBackgroundNotification.
   */
  id<NSObject> _applicationDidEnterBackgroundObserver;
}

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    gKeychainServiceNameForAppName = [[NSMutableDictionary alloc] init];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    // Ensures the @c FIRAuth instance for a given app gets loaded as soon as the app is ready.
    [defaultCenter addObserverForName:kFIRAppReadyToConfigureSDKNotification
                               object:[FIRApp class]
                                queue:nil
                           usingBlock:^(NSNotification *notification) {
      [FIRAuth authWithApp:[FIRApp appNamed:notification.userInfo[kFIRAppNameKey]]];
    }];
    // Ensures the saved user is cleared when the app is deleted.
    [defaultCenter addObserverForName:kFIRAppDeleteNotification
                               object:[FIRApp class]
                                queue:nil
                           usingBlock:^(NSNotification *notification) {
      dispatch_async(FIRAuthGlobalWorkQueue(), ^{
        // This doesn't stop any request already issued, see b/27704535 .
        NSString *appName = notification.userInfo[kFIRAppNameKey];
        NSString *keychainServiceName = [FIRAuth keychainServiceNameForAppName:appName];
        if (keychainServiceName) {
          [self deleteKeychainServiceNameForAppName:appName];
          FIRAuthKeychain *keychain = [[FIRAuthKeychain alloc] initWithService:keychainServiceName];
          NSString *userKey = [NSString stringWithFormat:kUserKey, appName];
          [keychain removeDataForKey:userKey error:NULL];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter]
              postNotificationName:FIRAuthStateDidChangeNotification
                            object:nil];
        });
      });
    }];
  });
}

+ (FIRAuth *)auth {
  FIRApp *defaultApp = [FIRApp defaultApp];
  if (!defaultApp) {
    [NSException raise:NSInternalInconsistencyException
                format:@"The default FIRApp instance must be configured before the default FIRAuth"
                       @"instance can be initialized. One way to ensure that is to call "
                       @"`[FIRApp configure];` (`FirebaseApp.configure()` in Swift) in the App "
                       @"Delegate's `application:didFinishLaunchingWithOptions:` "
                       @"(`application(_:didFinishLaunchingWithOptions:)` in Swift)."];
  }
  return [self authWithApp:defaultApp];
}

+ (FIRAuth *)authWithApp:(FIRApp *)app {
  return [FIRAppAssociationRegistration registeredObjectWithHost:app
                                                             key:NSStringFromClass(self)
                                                   creationBlock:^FIRAuth *_Nullable() {
    return [[FIRAuth alloc] initWithApp:app];
  }];
}

- (instancetype)initWithApp:(FIRApp *)app {
  [FIRAuth setKeychainServiceNameForApp:app];
  self = [self initWithAPIKey:app.options.APIKey appName:app.name];
  if (self) {
    _app = app;
    __weak FIRAuth *weakSelf = self;
    app.getTokenImplementation = ^(BOOL forceRefresh, FIRTokenCallback callback) {
      dispatch_async(FIRAuthGlobalWorkQueue(), ^{
        FIRAuth *strongSelf = weakSelf;
        if (strongSelf && !strongSelf->_autoRefreshTokens) {
          FIRLogInfo(kFIRLoggerAuth, @"I-AUT000002", @"Token auto-refresh enabled.");
          strongSelf->_autoRefreshTokens = YES;
          [strongSelf scheduleAutoTokenRefresh];

          #if TARGET_OS_IOS // TODO: Is a similar mechanism needed on macOS?
          strongSelf->_applicationDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter]
              addObserverForName:UIApplicationDidBecomeActiveNotification
                          object:nil
                           queue:nil
                      usingBlock:^(NSNotification *notification) {
            FIRAuth *strongSelf = weakSelf;
            if (strongSelf) {
              strongSelf->_isAppInBackground = NO;
              if (!strongSelf->_autoRefreshScheduled) {
                [weakSelf scheduleAutoTokenRefresh];
              }
            }
          }];
          strongSelf->_applicationDidEnterBackgroundObserver = [[NSNotificationCenter defaultCenter]
              addObserverForName:UIApplicationDidEnterBackgroundNotification
                          object:nil
                           queue:nil
                      usingBlock:^(NSNotification *notification) {
            FIRAuth *strongSelf = weakSelf;
            if (strongSelf) {
              strongSelf->_isAppInBackground = YES;
            }
          }];
          #endif
        }
        if (!strongSelf.currentUser) {
          dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, nil);
          });
          return;
        }
        [strongSelf.currentUser internalGetTokenForcingRefresh:forceRefresh
                                                      callback:^(NSString *_Nullable token,
                                                                 NSError *_Nullable error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            callback(token, error);
          });
        }];
      });
    };
    app.getUIDImplementation = ^NSString *_Nullable() {
      __block NSString *uid;
      dispatch_sync(FIRAuthGlobalWorkQueue(), ^{
        uid = [weakSelf getUID];
      });
      return uid;
    };
  }
  return self;
}

- (instancetype)initWithAPIKey:(NSString *)APIKey appName:(NSString *)appName {
  self = [super init];
  if (self) {
    _listenerHandles = [NSMutableArray array];
    _APIKey = [APIKey copy];
    _firebaseAppName = [appName copy];
    NSString *keychainServiceName = [FIRAuth keychainServiceNameForAppName:appName];
    if (keychainServiceName) {
      _keychain = [[FIRAuthKeychain alloc] initWithService:keychainServiceName];
    }
    // Load current user from keychain.
    FIRUser *user;
    NSError *error;
    if ([self getUser:&user error:&error]) {
      [self updateCurrentUser:user byForce:NO savingToDisk:NO error:&error];
    } else {
      FIRLogError(kFIRLoggerAuth, @"I-AUT000001",
                  @"Error loading saved user when starting up: %@", error);
    }

    #if TARGET_OS_IOS
    // Initialize for phone number auth.
    _tokenManager =
        [[FIRAuthAPNSTokenManager alloc] initWithApplication:[UIApplication sharedApplication]];

    _appCredentialManager = [[FIRAuthAppCredentialManager alloc] initWithKeychain:_keychain];

    _notificationManager =
        [[FIRAuthNotificationManager alloc] initWithApplication:[UIApplication sharedApplication]
                                           appCredentialManager:_appCredentialManager];
    
    [[FIRAuthAppDelegateProxy sharedInstance] addHandler:self];
    #endif
  }
  return self;
}

- (void)dealloc {
  @synchronized (self) {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    while (_listenerHandles.count != 0) {
      FIRAuthStateDidChangeListenerHandle handleToRemove = _listenerHandles.lastObject;
      [defaultCenter removeObserver:handleToRemove];
      [_listenerHandles removeLastObject];
    }

    #if TARGET_OS_IOS
    [defaultCenter removeObserver:_applicationDidBecomeActiveObserver
                             name:UIApplicationDidBecomeActiveNotification
                           object:nil];
    [defaultCenter removeObserver:_applicationDidEnterBackgroundObserver
                             name:UIApplicationDidEnterBackgroundNotification
                           object:nil];
    #endif
  }
}

#pragma mark - Public API

- (void)fetchProvidersForEmail:(NSString *)email
                    completion:(FIRProviderQueryCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRCreateAuthURIRequest *request =
        [[FIRCreateAuthURIRequest alloc] initWithIdentifier:email
                                                continueURI:@"http://www.google.com/"
                                                     APIKey:_APIKey];
    [FIRAuthBackend createAuthURI:request callback:^(FIRCreateAuthURIResponse *_Nullable response,
                                                     NSError *_Nullable error) {
      if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(response.allProviders, error);
        });
      }
    }];
  });
}

- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(FIRAuthResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    [self signInWithEmail:email
                 password:password
                 callback:[self signInFlowAuthResultCallbackByDecoratingCallback:completion]];
  });
}

/** @fn signInWithEmail:password:callback:
    @brief Signs in using an email address and password.
    @param email The user's email address.
    @param password The user's password.
    @param callback A block which is invoked when the sign in finishes (or is cancelled.) Invoked
        asynchronously on the global auth work queue in the future.
    @remarks This is the internal counterpart of this method, which uses a callback that does not
        update the current user.
 */
- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
               callback:(FIRAuthResultCallback)callback {
  FIRVerifyPasswordRequest *request =
      [[FIRVerifyPasswordRequest alloc] initWithEmail:email password:password APIKey:_APIKey];

  if (![request.password length]) {
    callback(nil, [FIRAuthErrorUtils wrongPasswordErrorWithMessage:nil]);
    return;
  }
  [FIRAuthBackend verifyPassword:request
                        callback:^(FIRVerifyPasswordResponse *_Nullable response,
                                   NSError *_Nullable error) {
    if (error) {
      callback(nil, error);
      return;
    }
    [self completeSignInWithAccessToken:response.IDToken
              accessTokenExpirationDate:response.approximateExpirationDate
                           refreshToken:response.refreshToken
                              anonymous:NO
                               callback:callback];
  }];
}

- (void)signInWithCredential:(FIRAuthCredential *)credential
                  completion:(FIRAuthResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRAuthResultCallback callback =
        [self signInFlowAuthResultCallbackByDecoratingCallback:completion];
    [self internalSignInWithCredential:credential callback:callback];
  });
}

- (void)signInAndRetrieveDataWithCredential:(FIRAuthCredential *)credential
                                 completion:(nullable FIRAuthDataResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRAuthDataResultCallback callback =
        [self signInFlowAuthDataResultCallbackByDecoratingCallback:completion];
    [self internalSignInAndRetrieveDataWithCredential:credential
                                   isReauthentication:NO
                                             callback:callback];
  });
}

- (void)internalSignInWithCredential:(FIRAuthCredential *)credential
                            callback:(FIRAuthResultCallback)callback {
  [self internalSignInAndRetrieveDataWithCredential:credential
                                 isReauthentication:NO
                                           callback:^(FIRAuthDataResult *_Nullable authResult,
                                                      NSError *_Nullable error) {
    callback(authResult.user, error);
  }];
}

- (void)internalSignInAndRetrieveDataWithCredential:(FIRAuthCredential *)credential
                                 isReauthentication:(BOOL)isReauthentication
                                           callback:(nullable FIRAuthDataResultCallback)callback {
  if ([credential isKindOfClass:[FIREmailPasswordAuthCredential class]]) {
    // Special case for email/password credentials
    FIREmailPasswordAuthCredential *emailPasswordCredential =
        (FIREmailPasswordAuthCredential *)credential;
    [self signInWithEmail:emailPasswordCredential.email
                 password:emailPasswordCredential.password
                 callback:^(FIRUser *_Nullable user, NSError *_Nullable error) {
      if (callback) {
        FIRAuthDataResult *result = user ?
            [[FIRAuthDataResult alloc] initWithUser:user additionalUserInfo:nil] : nil;
        callback(result, error);
      }
    }];
    return;
  }

  #if TARGET_OS_IOS
  if ([credential isKindOfClass:[FIRPhoneAuthCredential class]]) {
    // Special case for phone auth credentials
    FIRPhoneAuthCredential *phoneCredential = (FIRPhoneAuthCredential *)credential;
    [self signInWithPhoneCredential:phoneCredential callback:^(FIRUser *_Nullable user,
                                                               NSError *_Nullable error) {
      if (callback) {
        FIRAuthDataResult *result = user ?
            [[FIRAuthDataResult alloc] initWithUser:user additionalUserInfo:nil] : nil;
        callback(result, error);
      }
    }];
    return;
  }
  #endif

  FIRVerifyAssertionRequest *request =
      [[FIRVerifyAssertionRequest alloc] initWithAPIKey:_APIKey providerID:credential.provider];
  request.autoCreate = !isReauthentication;
  [credential prepareVerifyAssertionRequest:request];
  [FIRAuthBackend verifyAssertion:request
                         callback:^(FIRVerifyAssertionResponse *response, NSError *error) {
    if (error) {
      if (callback) {
        callback(nil, error);
      }
      return;
    }

    if (response.needConfirmation) {
      if (callback) {
        NSString *email = response.email;
        callback(nil, [FIRAuthErrorUtils accountExistsWithDifferentCredentialErrorWithEmail:email]);
      }
      return;
    }

    if (!response.providerID.length) {
      if (callback) {
        callback(nil, [FIRAuthErrorUtils unexpectedResponseWithDeserializedResponse:response]);
      }
      return;
    }
    [self completeSignInWithAccessToken:response.IDToken
              accessTokenExpirationDate:response.approximateExpirationDate
                           refreshToken:response.refreshToken
                              anonymous:NO
                               callback:^(FIRUser *_Nullable user, NSError *_Nullable error) {
      if (callback) {
        FIRAdditionalUserInfo *additionalUserInfo =
            [FIRAdditionalUserInfo userInfoWithVerifyAssertionResponse:response];
        FIRAuthDataResult *result = user ?
            [[FIRAuthDataResult alloc] initWithUser:user
                                 additionalUserInfo:additionalUserInfo] : nil;
        callback(result, error);
      }
    }];
  }];
}

- (void)signInWithCredential:(FIRAuthCredential *)credential
                    callback:(FIRAuthResultCallback)callback {
  [self signInAndRetrieveDataWithCredential:credential
                                 completion:^(FIRAuthDataResult *_Nullable authResult,
                                              NSError *_Nullable error) {
    callback(authResult.user, error);
  }];
}

- (void)signInAnonymouslyWithCompletion:(FIRAuthResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRAuthResultCallback decoratedCallback =
        [self signInFlowAuthResultCallbackByDecoratingCallback:completion];
    if (_currentUser.anonymous) {
      decoratedCallback(_currentUser, nil);
      return;
    }
    FIRSignUpNewUserRequest *request = [[FIRSignUpNewUserRequest alloc] initWithAPIKey:_APIKey];
    [FIRAuthBackend signUpNewUser:request
                         callback:^(FIRSignUpNewUserResponse *_Nullable response,
                                    NSError *_Nullable error) {
      if (error) {
        decoratedCallback(nil, error);
        return;
      }
      [self completeSignInWithAccessToken:response.IDToken
                accessTokenExpirationDate:response.approximateExpirationDate
                             refreshToken:response.refreshToken
                                anonymous:YES
                                 callback:decoratedCallback];
    }];
  });
}

- (void)signInWithCustomToken:(NSString *)token
                   completion:(nullable FIRAuthResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRAuthResultCallback decoratedCallback =
        [self signInFlowAuthResultCallbackByDecoratingCallback:completion];
    FIRVerifyCustomTokenRequest *request =
        [[FIRVerifyCustomTokenRequest alloc] initWithToken:token APIKey:_APIKey];
    [FIRAuthBackend verifyCustomToken:request
                             callback:^(FIRVerifyCustomTokenResponse *_Nullable response,
                                        NSError *_Nullable error) {
      if (error) {
        decoratedCallback(nil, error);
        return;
      }
      [self completeSignInWithAccessToken:response.IDToken
                accessTokenExpirationDate:response.approximateExpirationDate
                             refreshToken:response.refreshToken
                                anonymous:NO
                                 callback:decoratedCallback];
    }];
  });
}

- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                 completion:(nullable FIRAuthResultCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRAuthResultCallback decoratedCallback =
        [self signInFlowAuthResultCallbackByDecoratingCallback:completion];
    FIRSignUpNewUserRequest *request = [[FIRSignUpNewUserRequest alloc] initWithAPIKey:_APIKey
                                                                                 email:email
                                                                              password:password
                                                                           displayName:nil];
    if (![request.password length]) {
      decoratedCallback(nil, [FIRAuthErrorUtils
          weakPasswordErrorWithServerResponseReason:kMissingPasswordReason]);
      return;
    }
    if (![request.email length]) {
      decoratedCallback(nil, [FIRAuthErrorUtils missingEmail]);
      return;
    }
    [FIRAuthBackend signUpNewUser:request
                         callback:^(FIRSignUpNewUserResponse *_Nullable response,
                                     NSError *_Nullable error) {
      if (error) {
        decoratedCallback(nil, error);
        return;
      }
      [self completeSignInWithAccessToken:response.IDToken
                accessTokenExpirationDate:response.approximateExpirationDate
                             refreshToken:response.refreshToken
                                anonymous:NO
                                 callback:decoratedCallback];
    }];
  });
}

- (void)confirmPasswordResetWithCode:(NSString *)code
                         newPassword:(NSString *)newPassword
                          completion:(FIRConfirmPasswordResetCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRResetPasswordRequest *request =
        [[FIRResetPasswordRequest alloc] initWithAPIKey:_APIKey
                                                oobCode:code
                                            newPassword:newPassword];
    [FIRAuthBackend resetPassword:request callback:^(FIRResetPasswordResponse *_Nullable response,
                                                     NSError *_Nullable error) {
      if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (error) {
            completion(error);
            return;
          }
          completion(nil);
        });
      }
    }];
  });
}

- (void)checkActionCode:(NSString *)code completion:(FIRCheckActionCodeCallBack)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^ {
    FIRResetPasswordRequest *request =
    [[FIRResetPasswordRequest alloc] initWithAPIKey:_APIKey
                                            oobCode:code
                                        newPassword:nil];
    [FIRAuthBackend resetPassword:request callback:^(FIRResetPasswordResponse *_Nullable response,
                                                     NSError *_Nullable error) {
      if (completion) {
        if (error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
          });
          return;
        }
        FIRActionCodeOperation operation =
            [FIRActionCodeInfo actionCodeOperationForRequestType:response.requestType];
        FIRActionCodeInfo *actionCodeInfo =
            [[FIRActionCodeInfo alloc] initWithOperation:operation
                                                   email:response.email
                                                newEmail:response.verifiedEmail];
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(actionCodeInfo, nil);
        });
      }
    }];
  });
}

- (void)verifyPasswordResetCode:(NSString *)code
                     completion:(FIRVerifyPasswordResetCodeCallback)completion {
  [self checkActionCode:code completion:^(FIRActionCodeInfo *_Nullable info,
                                          NSError *_Nullable error) {
    if (completion) {
      if (error) {
        completion(nil, error);
        return;
      }
      completion([info dataForKey:FIRActionCodeEmailKey], nil);
    }
  }];
}

- (void)applyActionCode:(NSString *)code completion:(FIRApplyActionCodeCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^ {
    FIRSetAccountInfoRequest *request = [[FIRSetAccountInfoRequest alloc]initWithAPIKey:_APIKey];
    request.OOBCode = code;
    [FIRAuthBackend setAccountInfo:request callback:^(FIRSetAccountInfoResponse *_Nullable response,
                                                      NSError *_Nullable error) {
      if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(error);
        });
      }
    }];
  });
}

- (void)sendPasswordResetWithEmail:(NSString *)email
                        completion:(nullable FIRSendPasswordResetCallback)completion {
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    if (!email) {
      [FIRAuthExceptionUtils raiseInvalidParameterExceptionWithReason:kEmailInvalidParameterReason];
    }
    FIRGetOOBConfirmationCodeRequest *request =
        [FIRGetOOBConfirmationCodeRequest passwordResetRequestWithEmail:email APIKey:_APIKey];
    [FIRAuthBackend getOOBConfirmationCode:request
                                  callback:^(FIRGetOOBConfirmationCodeResponse *_Nullable response,
                                             NSError *_Nullable error) {
      if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(error);
        });
      }
    }];
  });
}

- (BOOL)signOut:(NSError *_Nullable *_Nullable)error {
  __block BOOL result = YES;
  dispatch_sync(FIRAuthGlobalWorkQueue(), ^{
    if (!_currentUser) {
      return;
    }
    result = [self updateCurrentUser:nil byForce:NO savingToDisk:YES error:error];
  });
  return result;
}

- (BOOL)signOutByForceWithUserID:(NSString *)userID error:(NSError *_Nullable *_Nullable)error {
  if (_currentUser.uid != userID) {
    return YES;
  }
  return [self updateCurrentUser:nil byForce:YES savingToDisk:YES error:error];
}

- (FIRAuthStateDidChangeListenerHandle)addAuthStateDidChangeListener:
    (FIRAuthStateDidChangeListenerBlock)listener {
  __block BOOL firstInvocation = YES;
  __block NSString *previousUserID;
  return [self addIDTokenDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
    BOOL shouldCallListener = firstInvocation ||
         !(previousUserID == user.uid || [previousUserID isEqualToString:user.uid]);
    firstInvocation = NO;
    previousUserID = [user.uid copy];
    if (shouldCallListener) {
      listener(auth, user);
    }
  }];
}

- (void)removeAuthStateDidChangeListener:(FIRAuthStateDidChangeListenerHandle)listenerHandle {
  [self removeIDTokenDidChangeListener:listenerHandle];
}

- (FIRIDTokenDidChangeListenerHandle)addIDTokenDidChangeListener:
    (FIRIDTokenDidChangeListenerBlock)listener {
  if (!listener) {
    [NSException raise:NSInvalidArgumentException format:@"listener must not be nil."];
    return nil;
  }
  FIRAuthStateDidChangeListenerHandle handle;
  NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
  handle = [notifications addObserverForName:FIRAuthStateDidChangeNotification
                                      object:self
                                       queue:[NSOperationQueue mainQueue]
                                  usingBlock:^(NSNotification *_Nonnull notification) {
    FIRAuth *auth = notification.object;
    listener(auth, auth.currentUser);
  }];
  @synchronized (self) {
    [_listenerHandles addObject:handle];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    listener(self, self.currentUser);
  });
  return handle;
}

- (void)removeIDTokenDidChangeListener:(FIRIDTokenDidChangeListenerHandle)listenerHandle {
  [[NSNotificationCenter defaultCenter] removeObserver:listenerHandle];
  @synchronized (self) {
    [_listenerHandles removeObject:listenerHandle];
  }
}

#if TARGET_OS_IOS
- (NSData *)APNSToken {
  __block NSData *result = nil;
  dispatch_sync(FIRAuthGlobalWorkQueue(), ^{
    result = _tokenManager.token.data;
  });
  return result;
}

- (void)setAPNSToken:(NSData *)APNSToken {
  [self setAPNSToken:APNSToken type:FIRAuthAPNSTokenTypeUnknown];
}

- (void)setAPNSToken:(NSData *)token type:(FIRAuthAPNSTokenType)type {
  dispatch_sync(FIRAuthGlobalWorkQueue(), ^{
    _tokenManager.token = [[FIRAuthAPNSToken alloc] initWithData:token type:type];
  });
}

- (BOOL)canHandleNotification:(NSDictionary *)userInfo {
  __block BOOL result = NO;
  dispatch_sync(FIRAuthGlobalWorkQueue(), ^{
    result = [_notificationManager canHandleNotification:userInfo];
  });
  return result;
}
#endif

#pragma mark - Internal Methods

#if TARGET_OS_IOS
/** @fn signInWithPhoneCredential:callback:
    @brief Signs in using a phone credential.
    @param credential The Phone Auth credential used to sign in.
    @param callback A block which is invoked when the sign in finishes (or is cancelled.) Invoked
        asynchronously on the global auth work queue in the future.
 */
- (void)signInWithPhoneCredential:(FIRPhoneAuthCredential *)credential
                         callback:(FIRAuthResultCallback)callback {
  if (credential.temporaryProof.length && credential.phoneNumber.length) {
    FIRVerifyPhoneNumberRequest *request =
      [[FIRVerifyPhoneNumberRequest alloc] initWithTemporaryProof:credential.temporaryProof
                                                      phoneNumber:credential.phoneNumber
                                                           APIKey:_APIKey];
    [self phoneNumberSignInWithRequest:request callback:callback];
    return;
  }

  if (!credential.verificationID.length) {
    callback(nil, [FIRAuthErrorUtils missingVerificationIDErrorWithMessage:nil]);
    return;
  }
  if (!credential.verificationCode.length) {
    callback(nil, [FIRAuthErrorUtils missingVerificationCodeErrorWithMessage:nil]);
    return;
  }
  FIRVerifyPhoneNumberRequest *request =
      [[FIRVerifyPhoneNumberRequest alloc]initWithVerificationID:credential.verificationID
                                                verificationCode:credential.verificationCode
                                                          APIKey:_APIKey];
  [self phoneNumberSignInWithRequest:request callback:callback];
}


/** @fn phoneNumberSignInWithVerificationID:pasverificationCodesword:callback:
    @brief Signs in using a FIRVerifyPhoneNumberRequest object.
    @param request THe FIRVerifyPhoneNumberRequest request object.
    @param callback A block which is invoked when the sign in finishes (or is cancelled.) Invoked
        asynchronously on the global auth work queue in the future.
 */
- (void)phoneNumberSignInWithRequest:(FIRVerifyPhoneNumberRequest *)request
                            callback:(FIRAuthResultCallback)callback {
  [FIRAuthBackend verifyPhoneNumber:request
                           callback:^(FIRVerifyPhoneNumberResponse *_Nullable response,
                                      NSError *_Nullable error) {
    if (error) {
      callback(nil, error);
      return;
    }
    [self completeSignInWithAccessToken:response.IDToken
              accessTokenExpirationDate:response.approximateExpirationDate
                           refreshToken:response.refreshToken
                              anonymous:NO
                               callback:callback];
  }];
}
#endif

- (void)notifyListenersOfAuthStateChangeWithUser:(FIRUser *)user token:(NSString *)token {
  if (user && _autoRefreshTokens) {
    // Shedule new refresh task after successful attempt.
    [self scheduleAutoTokenRefresh];
  }
  if (user == _currentUser) {
    NSMutableDictionary *internalNotificationParameters = [NSMutableDictionary dictionary];
    if (token.length) {
      internalNotificationParameters[FIRAuthStateDidChangeInternalNotificationTokenKey] = token;
    }
    NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
    dispatch_async(dispatch_get_main_queue(), ^{
      [notifications postNotificationName:FIRAuthStateDidChangeInternalNotification
                                   object:self
                                 userInfo:internalNotificationParameters];
      [notifications postNotificationName:FIRAuthStateDidChangeNotification
                                   object:self];
    });
  }
}

- (BOOL)updateKeychainWithUser:(FIRUser *)user error:(NSError *_Nullable *_Nullable)error {
  if (user == _currentUser) {
    return [self saveUser:user error:error];
  }
  // No-op if the user is no longer signed in. This is not considered an error as we don't check
  // whether the user is still current on other callbacks of user operations either.
  return YES;
}

/** @fn setKeychainServiceNameForApp
    @brief Sets the keychain service name global data for the particular app.
    @param app The Firebase app to set keychain service name for.
 */
+ (void)setKeychainServiceNameForApp:(FIRApp *)app {
  @synchronized (self) {
    gKeychainServiceNameForAppName[app.name] =
        [@"firebase_auth_" stringByAppendingString:app.options.googleAppID];
  }
}

/** @fn keychainServiceNameForAppName:
    @brief Gets the keychain service name global data for the particular app by name.
    @param appName The name of the Firebase app to get keychain service name for.
 */
+ (NSString *)keychainServiceNameForAppName:(NSString *)appName {
  @synchronized (self) {
    return gKeychainServiceNameForAppName[appName];
  }
}

/** @fn deleteKeychainServiceNameForAppName:
    @brief Deletes the keychain service name global data for the particular app by name.
    @param appName The name of the Firebase app to delete keychain service name for.
 */
+ (void)deleteKeychainServiceNameForAppName:(NSString *)appName {
  @synchronized (self) {
    [gKeychainServiceNameForAppName removeObjectForKey:appName];
  }
}

/** @fn scheduleAutoTokenRefreshWithDelay:
    @brief Schedules a task to automatically refresh tokens on the current user. The token refresh
        is scheduled 5 minutes before the  scheduled expiration time.
    @remarks If the token expires in less than 5 minutes, schedule the token refresh immediately.
 */
- (void)scheduleAutoTokenRefresh {
  NSTimeInterval tokenExpirationInterval =
      [_currentUser.accessTokenExpirationDate timeIntervalSinceNow] - kTokenRefreshHeadStart;
  [self scheduleAutoTokenRefreshWithDelay:MAX(tokenExpirationInterval, 0) retry:NO];
}

/** @fn scheduleAutoTokenRefreshWithDelay:
    @brief Schedules a task to automatically refresh tokens on the current user.
    @param delay The delay in seconds after which the token refresh task should be scheduled to be
        executed.
    @param retry Flag to determine whether the invocation is a retry attempt or not.
 */
- (void)scheduleAutoTokenRefreshWithDelay:(NSTimeInterval)delay retry:(BOOL)retry {
  NSString *accessToken = _currentUser.rawAccessToken;
  if (!accessToken) {
    return;
  }
  if (retry) {
    FIRLogNotice(kFIRLoggerAuth, @"I-AUT000003",
                 @"Token auto-refresh re-scheduled in %02d:%02d "
                 @"because of error on previous refresh attempt.",
                 (int)ceil(delay) / 60, (int)ceil(delay) % 60);
  } else {
    FIRLogInfo(kFIRLoggerAuth, @"I-AUT000004",
               @"Token auto-refresh scheduled in %02d:%02d for the new token.",
               (int)ceil(delay) / 60, (int)ceil(delay) % 60);
  }
  _autoRefreshScheduled = YES;
  __weak FIRAuth *weakSelf = self;
  [[FIRAuthDispatcher sharedInstance] dispatchAfterDelay:delay
                                                   queue:FIRAuthGlobalWorkQueue()
                                                    task:^(void) {
    FIRAuth *strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    if (![strongSelf->_currentUser.rawAccessToken isEqualToString:accessToken]) {
      // Another auto refresh must have been scheduled, so keep _autoRefreshScheduled unchanged.
      return;
    }
    strongSelf->_autoRefreshScheduled = NO;
    if (strongSelf->_isAppInBackground) {
      return;
    }
    NSString *uid = strongSelf->_currentUser.uid;
    [strongSelf->_currentUser internalGetTokenForcingRefresh:YES
                                                    callback:^(NSString *_Nullable token,
                                                               NSError *_Nullable error) {
      if (![strongSelf->_currentUser.uid isEqualToString:uid]) {
        return;
      }
      // If the error is an invalid token, sign the user out.
      if (error.code == FIRAuthErrorCodeInvalidUserToken) {
        FIRLogWarning(kFIRLoggerAuth, @"I-AUT000005",
                      @"Invalid refresh token detected, user is automatically signed out.");
        [strongSelf signOutByForceWithUserID:uid error:nil];
        return;
      }
      if (error) {
        // Kicks off exponential back off logic to retry failed attempt. Starts with one minute
        // delay (60 seconds) if this is the first failed attempt.
        NSTimeInterval rescheduleDelay;
        if (retry) {
          rescheduleDelay = MIN(delay * 2, kMaxWaitTimeForBackoff);
        } else {
          rescheduleDelay = 60;
        }
        [strongSelf scheduleAutoTokenRefreshWithDelay:rescheduleDelay retry:YES];
      }
    }];
  }];
}

#pragma mark -

/** @fn completeSignInWithTokenService:callback:
    @brief Completes a sign-in flow once we have access and refresh tokens for the user.
    @param accessToken The STS access token.
    @param accessTokenExpirationDate The approximate expiration date of the access token.
    @param refreshToken The STS refresh token.
    @param anonymous Whether or not the user is anonymous.
    @param callback Called when the user has been signed in or when an error occurred. Invoked
        asynchronously on the global auth work queue in the future.
 */
- (void)completeSignInWithAccessToken:(NSString *)accessToken
            accessTokenExpirationDate:(NSDate *)accessTokenExpirationDate
                         refreshToken:(NSString *)refreshToken
                            anonymous:(BOOL)anonymous
                             callback:(FIRAuthResultCallback)callback {
  [FIRUser retrieveUserWithAPIKey:_APIKey
                      accessToken:accessToken
        accessTokenExpirationDate:accessTokenExpirationDate
                     refreshToken:refreshToken
                        anonymous:anonymous
                         callback:callback];
}

/** @fn signInFlowAuthResultCallbackByDecoratingCallback:
    @brief Creates a FIRAuthResultCallback block which wraps another FIRAuthResultCallback; trying
        to update the current user before forwarding it's invocations along to a subject block
    @param callback Called when the user has been updated or when an error has occurred. Invoked
        asynchronously on the main thread in the future.
    @return Returns a block that updates the current user.
    @remarks Typically invoked as part of the complete sign-in flow. For any other uses please
        consider alternative ways of updating the current user.
*/
- (FIRAuthResultCallback)signInFlowAuthResultCallbackByDecoratingCallback:
    (nullable FIRAuthResultCallback)callback {
  return ^(FIRUser *_Nullable user, NSError *_Nullable error) {
    if (error) {
      if (callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(nil, error);
        });
      }
      return;
    }
    if (![self updateCurrentUser:user byForce:NO savingToDisk:YES error:&error]) {
      if (callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(nil, error);
        });
      }
      return;
    }
    if (callback) {
      dispatch_async(dispatch_get_main_queue(), ^{
        callback(user, nil);
      });
    }
  };
}

/** @fn signInFlowAuthDataResultCallbackByDecoratingCallback:
    @brief Creates a FIRAuthDataResultCallback block which wraps another FIRAuthDataResultCallback;
        trying to update the current user before forwarding it's invocations along to a subject
        block.
    @param callback Called when the user has been updated or when an error has occurred. Invoked
        asynchronously on the main thread in the future.
    @return Returns a block that updates the current user.
    @remarks Typically invoked as part of the complete sign-in flow. For any other uses please
        consider alternative ways of updating the current user.
*/
- (FIRAuthDataResultCallback)signInFlowAuthDataResultCallbackByDecoratingCallback:
    (nullable FIRAuthDataResultCallback)callback {
  return ^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
    if (error) {
      if (callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(nil, error);
        });
      }
      return;
    }
    if (![self updateCurrentUser:authResult.user byForce:NO savingToDisk:YES error:&error]) {
      if (callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(nil, error);
        });
      }
      return;
    }
    if (callback) {
      dispatch_async(dispatch_get_main_queue(), ^{
        callback(authResult, nil);
      });
    }
  };
}

#pragma mark - User-Related Methods

/** @fn updateCurrentUser:savingToDisk:
    @brief Update the current user; initializing the user's internal properties correctly, and
        optionally saving the user to disk.
    @remarks This method is called during: sign in and sign out events, as well as during class
        initialization time. The only time the saveToDisk parameter should be set to NO is during
        class initialization time because the user was just read from disk.
    @param user The user to use as the current user (including nil, which is passed at sign out
        time.)
    @param saveToDisk Indicates the method should persist the user data to disk.
 */
- (BOOL)updateCurrentUser:(FIRUser *)user
                  byForce:(BOOL)force
             savingToDisk:(BOOL)saveToDisk
                    error:(NSError *_Nullable *_Nullable)error {
  if (user == _currentUser) {
    return YES;
  }
  BOOL success = YES;
  if (saveToDisk) {
    success = [self saveUser:user error:error];
  }
  if (success || force) {
    FIRUser *previousUser = _currentUser;
    previousUser.auth = nil;
    _currentUser = user;
    _currentUser.auth = self;
    [self notifyListenersOfAuthStateChangeWithUser:user token:user.rawAccessToken];
  }
  return success;
}

/** @fn saveUser:error:
    @brief Persists user.
    @param user The user to save.
    @param error Return value for any error which occurs.
    @return @YES on success, @NO otherwise.
 */
- (BOOL)saveUser:(FIRUser *)user
           error:(NSError *_Nullable *_Nullable)error {
  BOOL success;
  NSString *userKey = [NSString stringWithFormat:kUserKey, _firebaseAppName];

  if (!user) {
    success = [_keychain removeDataForKey:userKey error:error];
  } else {
    // Encode the user object.
    NSMutableData *archiveData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    [archiver encodeObject:user forKey:userKey];
    [archiver finishEncoding];

    // Save the user object's encoded value.
    success = [_keychain setData:archiveData forKey:userKey error:error];
  }
  return success;
}

/** @fn getUser:error:
    @brief Retrieves the saved user associated, if one exists, from the keychain.
    @param outUser An out parameter which is populated with the saved user, if one exists.
    @param error Return value for any error which occurs.
    @return YES if the operation was a success (irrespective of whether or not a saved user existed
        for the given @c firebaseAppId,) NO if an error occurred.
 */
- (BOOL)getUser:(FIRUser *_Nullable *)outUser
          error:(NSError *_Nullable *_Nullable)error {
  NSString *userKey = [NSString stringWithFormat:kUserKey, _firebaseAppName];

  NSError *keychainError;
  NSData *encodedUserData = [_keychain dataForKey:userKey error:&keychainError];
  if (keychainError) {
    if (error) {
      *error = keychainError;
    }
    return NO;
  }
  if (!encodedUserData) {
    *outUser = nil;
    return YES;
  }
  NSKeyedUnarchiver *unarchiver =
      [[NSKeyedUnarchiver alloc] initForReadingWithData:encodedUserData];
  *outUser = [unarchiver decodeObjectOfClass:[FIRUser class] forKey:userKey];
  return YES;
}

/** @fn getUID
    @brief Gets the identifier of the current user, if any.
    @return The identifier of the current user, or nil if there is no current user.
 */
- (nullable NSString *)getUID {
  return _currentUser.uid;
}

@end
