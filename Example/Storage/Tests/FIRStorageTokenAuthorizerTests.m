// Copyright 2017 Google
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

#import "FIRStorageTestHelpers.h"

@interface FIRStorageTokenAuthorizerTests : XCTestCase

@property(strong, nonatomic) GTMSessionFetcher *fetcher;
@property(strong, nonatomic) id mockApp;

@end

@implementation FIRStorageTokenAuthorizerTests

- (void)setUp {
  [super setUp];
  NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:[FIRStorageTestHelpers objectURL]];
  self.fetcher = [GTMSessionFetcher fetcherWithRequest:fetchRequest];

  self.mockApp = OCMClassMock([FIRApp class]);
  OCMStub([self.mockApp getTokenImplementation])
      .andReturn(^{
      });
  FIRTokenCallback mockCallback =
      [OCMArg invokeBlockWithArgs:kFIRStorageTestAuthToken, [NSNull null], nil];
  OCMStub([self.mockApp getTokenForcingRefresh:NO withCallback:mockCallback]);
  GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
  self.fetcher.authorizer =
      [[FIRStorageTokenAuthorizer alloc] initWithApp:self.mockApp fetcherService:fetcherService];
}

- (void)tearDown {
  self.fetcher = nil;
  self.mockApp = nil;
  [super tearDown];
}

- (void)testSuccessfulAuth {
  XCTestExpectation *expectation = [self expectationWithDescription:@"testSuccessfulAuth"];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    XCTAssertTrue([self.fetcher.authorizer isAuthorizedRequest:fetcher.request]);
#pragma clang diagnostic pop
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:200
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, nil);
  };

  [self.fetcher beginFetchWithCompletionHandler:^(NSData *_Nullable data,
                                                  NSError *_Nullable error) {
    NSDictionary<NSString *, NSString *> *headers = self.fetcher.request.allHTTPHeaderFields;
    NSString *authHeader = [headers objectForKey:@"Authorization"];
    NSString *firebaseToken =
        [NSString stringWithFormat:kFIRStorageAuthTokenFormat, kFIRStorageTestAuthToken];
    XCTAssertEqualObjects(authHeader, firebaseToken);
    [expectation fulfill];
  }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

- (void)testUnsuccessfulAuth {
  XCTestExpectation *expectation = [self expectationWithDescription:@"testUnsuccessfulAuth"];

  NSError *authError = [NSError errorWithDomain:FIRStorageErrorDomain
                                           code:FIRStorageErrorCodeUnauthenticated
                                       userInfo:nil];
  id unsuccessfulApp = OCMClassMock([FIRApp class]);
  OCMStub([unsuccessfulApp getTokenImplementation])
      .andReturn(^{
      });
  FIRTokenCallback mockCallback = [OCMArg invokeBlockWithArgs:[NSNull null], authError, nil];
  OCMStub([unsuccessfulApp getTokenForcingRefresh:NO withCallback:mockCallback]);
  GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
  self.fetcher.authorizer =
      [[FIRStorageTokenAuthorizer alloc] initWithApp:unsuccessfulApp fetcherService:fetcherService];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    XCTAssertEqual([self.fetcher.authorizer isAuthorizedRequest:fetcher.request], NO);
#pragma cland diagnostic pop
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:401
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, authError);
  };

  [self.fetcher beginFetchWithCompletionHandler:^(NSData *_Nullable data,
                                                  NSError *_Nullable error) {
    NSDictionary<NSString *, NSString *> *headers = self.fetcher.request.allHTTPHeaderFields;
    NSString *authHeader = [headers objectForKey:@"Authorization"];
    XCTAssertNil(authHeader);
    XCTAssertEqualObjects(error.domain, FIRStorageErrorDomain);
    XCTAssertEqual(error.code, FIRStorageErrorCodeUnauthenticated);
    [expectation fulfill];
  }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

- (void)testSuccessfulUnauthenticatedAuth {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"testSuccessfulUnauthenticatedAuth"];

  // Note that self.mockApp is left with null properties--this simulates no token present
  self.mockApp = OCMClassMock([FIRApp class]);
  GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
  self.fetcher.authorizer =
      [[FIRStorageTokenAuthorizer alloc] initWithApp:self.mockApp fetcherService:fetcherService];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    XCTAssertFalse([self.fetcher.authorizer isAuthorizedRequest:fetcher.request]);
#pragma cland diagnostic pop
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:200
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, nil);
  };

  [self.fetcher beginFetchWithCompletionHandler:^(NSData *_Nullable data,
                                                  NSError *_Nullable error) {
    NSDictionary<NSString *, NSString *> *headers = self.fetcher.request.allHTTPHeaderFields;
    NSString *authHeader = [headers objectForKey:@"Authorization"];
    XCTAssertNil(authHeader);
    XCTAssertNil(error);
    [expectation fulfill];
  }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

- (void)testIsAuthorizing {
  XCTestExpectation *expectation = [self expectationWithDescription:@"testIsAuthorizing"];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
    XCTAssertFalse([fetcher.authorizer isAuthorizingRequest:fetcher.request]);
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:200
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, nil);
  };

  [self.fetcher
      beginFetchWithCompletionHandler:^(NSData *_Nullable data, NSError *_Nullable error) {
        [expectation fulfill];
      }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

- (void)testStopAuthorizingNoop {
  XCTestExpectation *expectation = [self expectationWithDescription:@"testStopAuthorizingNoop"];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
    // Since both of these are noops, we expect that invoking them
    // will still result in successful authentication
    [fetcher.authorizer stopAuthorization];
    [fetcher.authorizer stopAuthorizationForRequest:fetcher.request];
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:200
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, nil);
  };

  [self.fetcher beginFetchWithCompletionHandler:^(NSData *_Nullable data,
                                                  NSError *_Nullable error) {
    NSDictionary<NSString *, NSString *> *headers = self.fetcher.request.allHTTPHeaderFields;
    NSString *authHeader = [headers objectForKey:@"Authorization"];
    NSString *firebaseToken =
        [NSString stringWithFormat:kFIRStorageAuthTokenFormat, kFIRStorageTestAuthToken];
    XCTAssertEqualObjects(authHeader, firebaseToken);
    [expectation fulfill];
  }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

- (void)testEmail {
  XCTestExpectation *expectation = [self expectationWithDescription:@"testEmail"];

  self.fetcher.testBlock = ^(GTMSessionFetcher *fetcher, GTMSessionFetcherTestResponse response) {
    XCTAssertNil([fetcher.authorizer userEmail]);
    NSHTTPURLResponse *httpResponse =
        [[NSHTTPURLResponse alloc] initWithURL:fetcher.request.URL
                                    statusCode:200
                                   HTTPVersion:kHTTPVersion
                                  headerFields:nil];
    response(httpResponse, nil, nil);
  };

  [self.fetcher
      beginFetchWithCompletionHandler:^(NSData *_Nullable data, NSError *_Nullable error) {
        [expectation fulfill];
      }];

  [FIRStorageTestHelpers waitForExpectation:self];
}

@end
