// Copyright 2024 Google LLC
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

#import "FirebaseAuth/Sources/Public/FirebaseAuth/FIRRecaptchaBridge.h"
#import "RecaptchaInterop/RecaptchaInterop.h"

// This is thread safe since it is only called by the AuthRecaptchaVerifier singleton.
static id<RCARecaptchaClientProtocol> recaptchaClient;

static void retrieveToken(NSString *actionString,
                          NSString *fakeToken,
                          FIRAuthRecaptchaTokenCallback completion) {
  Class RecaptchaActionClass = NSClassFromString(@"RecaptchaAction");
  SEL customActionSelector = NSSelectorFromString(@"initWithCustomAction:");
  if (RecaptchaActionClass &&
      [RecaptchaActionClass instancesRespondToSelector:customActionSelector]) {
    // Initialize with a custom action
    id (*funcWithCustomAction)(id, SEL, NSString *) = (id(*)(
        id, SEL, NSString *))[RecaptchaActionClass instanceMethodForSelector:customActionSelector];

    id<RCAActionProtocol> customAction = funcWithCustomAction([[RecaptchaActionClass alloc] init],
                                                              customActionSelector, actionString);
    if (customAction) {
      [recaptchaClient execute:customAction
                    completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                      if (!error) {
                        completion(token, nil, YES);
                        return;
                      } else {
                        completion(fakeToken, nil, YES);
                      }
                    }];
    }

  } else {
    // RecaptchaEnterprise not linked.
    completion(nil, nil, NO);
  }
}

void FIRRecaptchaGetToken(NSString *siteKey,
                          NSString *actionString,
                          NSString *fakeToken,
                          FIRAuthRecaptchaTokenCallback completion) {
  if (recaptchaClient != nil) {
    retrieveToken(actionString, fakeToken, completion);
    return;
  }

  Class RecaptchaClass = NSClassFromString(@"Recaptcha");
  SEL selector = NSSelectorFromString(@"getClientWithSiteKey:completion:");
  if (RecaptchaClass && [RecaptchaClass respondsToSelector:selector]) {
    void (*funcWithoutTimeout)(id, SEL, NSString *,
                               void (^)(id<RCARecaptchaClientProtocol> _Nullable recaptchaClient,
                                        NSError *_Nullable error)) =
        (void *)[RecaptchaClass methodForSelector:selector];
    funcWithoutTimeout(RecaptchaClass, selector, siteKey,
                       ^(id<RCARecaptchaClientProtocol> _Nonnull client, NSError *_Nullable error) {
                         if (error) {
                           completion(nil, error, YES);
                         } else {
                           recaptchaClient = client;
                           retrieveToken(actionString, fakeToken, completion);
                         }
                       });
  } else {
    // RecaptchaEnterprise not linked.
    completion(nil, nil, NO);
  }
}
