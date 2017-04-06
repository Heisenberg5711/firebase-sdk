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

#import "FIRDeleteAccountResponse.h"

#import "../Private/FIRAuthErrorUtils.h"

/** @var kExpectedKind
    @brief The expected value for the "kind" field in the JSON response from the server.
 */
static NSString *const kExpectedKind = @"identitytoolkit#DeleteAccountResponse";

@implementation FIRDeleteAccountResponse

- (NSString *)expectedKind {
  return kExpectedKind;
}

- (BOOL)setWithDictionary:(NSDictionary *)dictionary
                   error:(NSError *_Nullable *_Nullable)error {
  return YES;
}

@end
