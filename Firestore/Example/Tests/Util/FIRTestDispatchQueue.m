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

#import "FIRTestDispatchQueue.h"

#import <XCTest/XCTestExpectation.h>

#import "Util/FSTAssert.h"

@interface FSTTestDispatchQueue ()

@property(nonatomic, weak) XCTestExpectation* expectation;

@end

@implementation FSTTestDispatchQueue

+ (instancetype)queueWith:(dispatch_queue_t)dispatchQueue {
  return [[FSTTestDispatchQueue alloc] initWithQueue:dispatchQueue];
}

- (instancetype)initWithQueue:(dispatch_queue_t)dispatchQueue {
  return (self = [super initWithQueue:dispatchQueue]);
}

- (void)dispatchAsync:(void (^)(void))block after:(NSTimeInterval)delay {
  [super dispatchAsyncAllowingSameQueue:^() {
    block();
    [_expectation fulfill];
    _expectation = nil;
  }
                                  after:MIN(delay, 1.0)];
}

- (void)dispatchAsyncAllowingSameQueue:(void (^)(void))block after:(NSTimeInterval)delay {
  [super dispatchAsyncAllowingSameQueue:^() {
    block();
    [_expectation fulfill];
    _expectation = nil;
  }
                                  after:MIN(delay, 1.0)];
}

- (void)fulfillOnExecution:(XCTestExpectation*)expectation {
  FSTAssert(_expectation == nil, @"Previous expectation still active");
  _expectation = expectation;
}

@end
