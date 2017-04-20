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

#import "FIRGetOOBConfirmationCodeResponse.h"

#import "../Private/FIRAuthErrorUtils.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kMissingContinueURIErrorMessage
    @brief The error returned by the server if continue URL is invalid.
 */
static NSString *const kMissingContinueURIErrorMessage = @"MISSING_CONTINUE_URI";

/** @var kOOBCodeKey
    @brief The name of the field in the response JSON for the OOB code.
 */
static NSString *const kOOBCodeKey = @"oobCode";

@implementation FIRGetOOBConfirmationCodeResponse

- (BOOL)setWithDictionary:(NSDictionary *)dictionary
                    error:(NSError *_Nullable *_Nullable)error {
  _OOBCode = [dictionary[kOOBCodeKey] copy];
  return YES;
}

- (nullable NSError *)clientErrorWithShortErrorMessage:(NSString *)shortErrorMessage
                                    detailErrorMessage:(NSString *)detailErrorMessage {
  if ([shortErrorMessage isEqualToString:kMissingContinueURIErrorMessage]) {
    return [FIRAuthErrorUtils missingContinueURIErrorWithMessage:detailErrorMessage];
  }
  return nil;
}

@end

NS_ASSUME_NONNULL_END
