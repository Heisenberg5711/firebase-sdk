//
//  FIRHeartbeatInfoTest.m
//  FirebaseCore-iOS-Unit-unit
//
//  Created by Vinay Guthal on 10/23/19.
//

#import <FirebaseCore/FIRHeartbeatInfo.h>
#import <GoogleUtilities/GULHeartbeatDateStorage.h>
#import <XCTest/XCTest.h>

@interface FIRHeartbeatInfoTest : XCTestCase

@property(nonatomic, strong) GULHeartbeatDateStorage *dataStorage;

@property(nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation FIRHeartbeatInfoTest

- (void)setUp {
  NSString *const kHeartbeatStorageFile = @"HEARTBEAT_INFO_STORAGE";
  self.dataStorage = [[GULHeartbeatDateStorage alloc]
      initWithFileURL:[GULHeartbeatDateStorage filePathURLWithName:kHeartbeatStorageFile]];
  NSDate *pastTime = [NSDate dateWithTimeIntervalSinceNow:-96400];
  [self.dataStorage setHearbeatDate:pastTime forTag:@"fire-iid"];
  [self.dataStorage setHearbeatDate:pastTime forTag:@"GLOBAL"];
}

- (void)testCombinedHeartbeat {
  FIRHeartbeatInfoCode heartbeatCode = [FIRHeartbeatInfo getHeartbeatCode:@"fire-iid"];
  XCTAssertEqual(heartbeatCode, FIRHeartbeatInfoCodeCombined);
}

- (void)testSdkOnlyHeartbeat {
  [self.dataStorage setHearbeatDate:[NSDate date] forTag:@"GLOBAL"];
  FIRHeartbeatInfoCode heartbeatCode = [FIRHeartbeatInfo getHeartbeatCode:@"fire-iid"];
  XCTAssertEqual(heartbeatCode, FIRHeartbeatInfoCodeSdk);
}

- (void)testGlobalOnlyHeartbeat {
  [self.dataStorage setHearbeatDate:[NSDate date] forTag:@"fire-iid"];
  FIRHeartbeatInfoCode heartbeatCode = [FIRHeartbeatInfo getHeartbeatCode:@"fire-iid"];
  XCTAssertEqual(heartbeatCode, FIRHeartbeatInfoCodeGlobal);
}

- (void)testNoHeartbeat {
  [self.dataStorage setHearbeatDate:[NSDate date] forTag:@"fire-iid"];
  [self.dataStorage setHearbeatDate:[NSDate date] forTag:@"GLOBAL"];
  FIRHeartbeatInfoCode heartbeatCode = [FIRHeartbeatInfo getHeartbeatCode:@"fire-iid"];
  XCTAssertEqual(heartbeatCode, FIRHeartbeatInfoCodeNone);
}

@end
