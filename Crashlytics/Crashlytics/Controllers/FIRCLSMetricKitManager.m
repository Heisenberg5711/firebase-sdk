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

#import <Foundation/Foundation.h>

#import "Crashlytics/Crashlytics/Controllers/FIRCLSMetricKitManager.h"

#if CLS_METRICKIT_SUPPORTED

#import "Crashlytics/Crashlytics/Controllers/FIRCLSManagerData.h"
#import "Crashlytics/Crashlytics/Helpers/FIRCLSFile.h"
#import "Crashlytics/Crashlytics/Helpers/FIRCLSLogger.h"
#import "Crashlytics/Crashlytics/Models/FIRCLSExecutionIdentifierModel.h"
#import "Crashlytics/Crashlytics/Models/FIRCLSInternalReport.h"
#import "Crashlytics/Crashlytics/Public/FirebaseCrashlytics/FIRCrashlyticsReport.h"

@interface FIRCLSMetricKitManager ()

@property FBLPromise *metricKitDataAvailable;
@property FIRCLSExistingReportManager *existingReportManager;
@property FIRCLSFileManager *fileManager;
@property FIRCLSManagerData *managerData;
@property BOOL metricKitPromiseFulfilled;

@end

@implementation FIRCLSMetricKitManager

- (instancetype)initWithManagerData:(FIRCLSManagerData *)managerData
              existingReportManager:(FIRCLSExistingReportManager *)existingReportManager
                        fileManager:(FIRCLSFileManager *)fileManager {
  _existingReportManager = existingReportManager;
  _fileManager = fileManager;
  _managerData = managerData;
  _metricKitPromiseFulfilled = NO;
  return self;
}

/*
 * Registers the MetricKit manager to receive MetricKit reports by adding self to the
 * MXMetricManager subscribers. Also initializes the promise that we'll use to ensure that any
 * MetricKit report files are included in Crashylytics fatal reports. If no crash occurred on the
 * last run of the app, this promise is immediately resolved so that the upload of any nonfatal
 * events can proceed.
 */
- (void)registerMetricKitManager {
  [[MXMetricManager sharedManager] addSubscriber:self];
  self.metricKitDataAvailable = [FBLPromise pendingPromise];

  // If there was no crash on the last run of the app or there's no diagnostic report in the
  // MetricKit directory, then we aren't expecting a MetricKit diagnostic report and should resolve
  // the promise immediately. If MetricKit captured a fatal event and Crashlytics did not, then
  // we'll still process the MetricKit crash but won't upload it until the app restarts again.
  if (![self.fileManager didCrashOnPreviousExecution] ||
      ![self.fileManager metricKitDiagnosticFileExists]) {
    @synchronized(self) {
      [self fulfillMetricKitPromise];
    }
  }

  // If we haven't resolved this promise within three seconds, resolve it now so that we're not
  // waiting indefinitely for MetricKit payloads that won't arrive.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), self.managerData.dispatchQueue,
                 ^{
                   @synchronized(self) {
                     if (!self.metricKitPromiseFulfilled) {
                       FIRCLSDebugLog(@"Resolving MetricKit promise after three seconds");
                       [self fulfillMetricKitPromise];
                     }
                   }
                 });
}

/*
 * This method receives diagnostic payloads from MetricKit whenever a fatal or nonfatal MetricKit
 * event occurs. If a fatal event, this method will be called when the app restarts. Since we're
 * including a MetricKit report file in the Crashlytics report to be sent to the backend, we need
 * to make sure that we process the payloads and write the included information to file before
 * the report is sent up. If this method is called due to a nonfatal event, it will be called
 * immediately after the event. Since we send nonfatal events on the next run of the app, we can
 * write out the information but won't need to resolve the promise.
 */
- (void)didReceiveDiagnosticPayloads:(NSArray<MXDiagnosticPayload *> *)payloads {
  BOOL processedFatalPayload = NO;
  for (MXDiagnosticPayload *diagnosticPayload in payloads) {
    if (!diagnosticPayload) {
      continue;
    }

    BOOL processedPayload = [self processMetricKitPayload:diagnosticPayload
                                           skipCrashEvent:processedFatalPayload];
    if (processedPayload && ([diagnosticPayload.crashDiagnostics count] > 0)) {
      processedFatalPayload = YES;
    }
  }
  // Once we've processed all the payloads, resolve the promise so that reporting uploading
  // continues. If there was not a crash on the previous run of the app, the promise will already
  // have been resolved.
  @synchronized(self) {
    [self fulfillMetricKitPromise];
  }
}

// Helper method to write a MetricKit payload's data to file.
- (BOOL)processMetricKitPayload:(MXDiagnosticPayload *)diagnosticPayload
                 skipCrashEvent:(BOOL)skipCrashEvent {
  BOOL writeFailed = NO;
  // TODO: Time stamp information is only available in begin and end time periods. Hopefully this
  // is updated with iOS 15.
  NSTimeInterval beginSecondsSince1970 = [diagnosticPayload.timeStampBegin timeIntervalSince1970];
  NSTimeInterval endSecondsSince1970 = [diagnosticPayload.timeStampEnd timeIntervalSince1970];

  // Get file path for the active reports directory.
  NSString *activePath = [[self.fileManager activePath] stringByAppendingString:@"/"];

  // If there is a crash diagnostic in the payload, then this method was called for a fatal event.
  // Also ensure that there is a report from the last run of the app that we can write to.
  NSString *metricKitReportFile;
  NSString *newestUnsentReportID =
      [self.existingReportManager.newestUnsentReport.reportID stringByAppendingString:@"/"];
  BOOL fatal = ([diagnosticPayload.crashDiagnostics count] > 0) && (newestUnsentReportID != nil) &&
               ([self.fileManager
                   fileExistsAtPath:[activePath stringByAppendingString:newestUnsentReportID]]);

  // Set the metrickit path appropriately depending on whether the diagnostic report came from
  // a fatal or nonfatal event. If fatal, use the report from the last run of the app. Otherwise,
  // use the report for the current run.
  if (fatal) {
    metricKitReportFile = [[activePath stringByAppendingString:newestUnsentReportID]
        stringByAppendingString:FIRCLSMetricKitReportFile];
  } else {
    NSString *currentReportID =
        [_managerData.executionIDModel.executionID stringByAppendingString:@"/"];
    metricKitReportFile = [[activePath stringByAppendingString:currentReportID]
        stringByAppendingString:FIRCLSMetricKitReportFile];
  }

  if (!metricKitReportFile) {
    FIRCLSDebugLog(@"Error finding MetricKit file");
    return NO;
  }

  FIRCLSDebugLog(@"File path for MetricKit:  %@", [metricKitReportFile copy]);

  if (![_fileManager fileExistsAtPath:metricKitReportFile]) {
    [_fileManager createFileAtPath:metricKitReportFile contents:nil attributes:nil];
  }
  NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:metricKitReportFile];
  if (file == nil) {
    FIRCLSDebugLog(@"Unable to create or open MetricKit file.");
    return false;
  }

  // Write out time information to the MetricKit report file. Time needs to be a value for
  // backend serialization, so we write out end_time separately.
  NSDictionary *timeDictionary = @{
    @"time" : [NSNumber numberWithDouble:beginSecondsSince1970],
    @"end_time" : [NSNumber numberWithDouble:endSecondsSince1970]
  };
  writeFailed = ![self writeDictionaryToFile:timeDictionary file:file newLineData:nil];

  NSData *newLineData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];

  // Write out each type of diagnostic if it exists in the report
  BOOL hasCrash = [diagnosticPayload.crashDiagnostics count] > 0;
  BOOL hasHang = [diagnosticPayload.hangDiagnostics count] > 0;
  BOOL hasCPUException = [diagnosticPayload.cpuExceptionDiagnostics count] > 0;
  BOOL hasDiskWriteException = [diagnosticPayload.diskWriteExceptionDiagnostics count] > 0;

  // For each diagnostic type, write out a section in the MetricKit report file. This section will
  // have subsections for threads, metadata, and event specific metadata.
  if (hasCrash && !skipCrashEvent) {
    MXCrashDiagnostic *crashDiagnostic = [diagnosticPayload.crashDiagnostics objectAtIndex:0];

    NSDictionary *threadDict =
        [self convertThreadsToDictionary:[crashDiagnostic.callStackTree JSONRepresentation]];
    NSDictionary *metadataDict =
        [self convertMetadataToDictionary:[crashDiagnostic.metaData JSONRepresentation]];

    NSString *nilString = @"";
    NSDictionary *crashDictionary = @{
      @"crash_event" : @{
        @"threads_data" : threadDict,
        @"metadata" : metadataDict,
        @"termination_reason" :
                (crashDiagnostic.terminationReason) ? crashDiagnostic.terminationReason : nilString,
        @"virtual_memory_region_info" : (crashDiagnostic.virtualMemoryRegionInfo)
            ? crashDiagnostic.virtualMemoryRegionInfo
            : nilString,
        @"exception_type" : crashDiagnostic.exceptionType,
        @"exception_code" : crashDiagnostic.exceptionCode,
        @"signal" : crashDiagnostic.signal
      }
    };
    writeFailed = ![self writeDictionaryToFile:crashDictionary file:file newLineData:newLineData];
  }

  if (hasHang) {
    MXHangDiagnostic *hangDiagnostic = [diagnosticPayload.hangDiagnostics objectAtIndex:0];

    NSDictionary *threadDict =
        [self convertThreadsToDictionary:[hangDiagnostic.callStackTree JSONRepresentation]];
    NSDictionary *metadataDict =
        [self convertMetadataToDictionary:[hangDiagnostic.metaData JSONRepresentation]];

    NSDictionary *hangDictionary = @{
      @"hang_event" : @{
        @"threads_data" : threadDict,
        @"metadata" : metadataDict,
        @"hang_duration" : [NSNumber numberWithDouble:[hangDiagnostic.hangDuration doubleValue]]
      }
    };
    writeFailed = ![self writeDictionaryToFile:hangDictionary file:file newLineData:newLineData];
  }

  if (hasCPUException) {
    MXCPUExceptionDiagnostic *cpuExceptionDiagnostic =
        [diagnosticPayload.cpuExceptionDiagnostics objectAtIndex:0];

    NSDictionary *threadDict =
        [self convertThreadsToDictionary:[cpuExceptionDiagnostic.callStackTree JSONRepresentation]];
    NSDictionary *metadataDict =
        [self convertMetadataToDictionary:[cpuExceptionDiagnostic.metaData JSONRepresentation]];

    NSDictionary *cpuDictionary = @{
      @"cpu_exception_event" : @{
        @"threads_data" : threadDict,
        @"metadata" : metadataDict,
        @"total_cpu_time" :
            [NSNumber numberWithDouble:[cpuExceptionDiagnostic.totalCPUTime doubleValue]],
        @"total_sampled_time" :
            [NSNumber numberWithDouble:[cpuExceptionDiagnostic.totalSampledTime doubleValue]]
      }
    };
    writeFailed = ![self writeDictionaryToFile:cpuDictionary file:file newLineData:newLineData];
  }

  if (hasDiskWriteException) {
    MXDiskWriteExceptionDiagnostic *diskWriteExceptionDiagnostic =
        [diagnosticPayload.diskWriteExceptionDiagnostics objectAtIndex:0];

    NSDictionary *threadDict = [self
        convertThreadsToDictionary:[diskWriteExceptionDiagnostic.callStackTree JSONRepresentation]];
    NSDictionary *metadataDict = [self
        convertMetadataToDictionary:[diskWriteExceptionDiagnostic.metaData JSONRepresentation]];

    NSDictionary *diskWriteDictionary = @{
      @"disk_write_exception_event" : @{
        @"threads_data" : threadDict,
        @"metadata" : metadataDict,
        @"total_writes_caused" :
            [NSNumber numberWithDouble:[diskWriteExceptionDiagnostic.totalWritesCaused doubleValue]]
      }
    };
    writeFailed = ![self writeDictionaryToFile:diskWriteDictionary
                                          file:file
                                   newLineData:newLineData];
  }

  return !writeFailed;
}
/*
 * Required for MXMetricManager subscribers. Since we aren't currently collecting any MetricKit
 * metrics, this method is left empty.
 */
- (void)didReceiveMetricPayloads:(NSArray<MXMetricPayload *> *)payloads {
}

- (FBLPromise *)waitForMetricKitDataAvailable {
  FBLPromise *result = nil;
  @synchronized(self) {
    result = self.metricKitDataAvailable;
  }
  return result;
}

/*
 * Helper method to convert threads for a MetricKit diagnostic event to a dictionary.
 */
- (NSDictionary *)convertThreadsToDictionary:(NSData *)threads {
  NSMutableString *threadsString = [[NSMutableString alloc] initWithData:threads
                                                                encoding:NSUTF8StringEncoding];
  [threadsString replaceOccurrencesOfString:@"\n"
                                 withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [threadsString length])];
  [threadsString replaceOccurrencesOfString:@"\t"
                                 withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [threadsString length])];
  NSError *error = nil;
  NSDictionary *threadDictionary = [NSJSONSerialization JSONObjectWithData:threads
                                                                   options:0
                                                                     error:&error];
  return threadDictionary;
}

/*
 * Helper method to convert metadata for a MetricKit diagnostic event to a dictionary.
 */
- (NSDictionary *)convertMetadataToDictionary:(NSData *)metadata {
  NSMutableString *metadataString = [[NSMutableString alloc] initWithData:metadata
                                                                 encoding:NSUTF8StringEncoding];
  [metadataString replaceOccurrencesOfString:@"\n"
                                  withString:@""
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, [metadataString length])];
  [metadataString replaceOccurrencesOfString:@"\t"
                                  withString:@""
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, [metadataString length])];
  NSError *error = nil;
  NSDictionary *metadataDictionary = [NSJSONSerialization JSONObjectWithData:metadata
                                                                     options:0
                                                                       error:&error];
  return metadataDictionary;
}

/*
 * Helper method to fulfill the metricKitDataAvailable promise and track that it has been fulfilled.
 */
- (void)fulfillMetricKitPromise {
  if (self.metricKitPromiseFulfilled) return;

  [self.metricKitDataAvailable fulfill:nil];
  self.metricKitPromiseFulfilled = YES;
}

/*
 * Helper method to write a dictionary of event information to file. Returns whether it succeeded.
 */
- (BOOL)writeDictionaryToFile:(NSDictionary *)dictionary
                         file:(NSFileHandle *)file
                  newLineData:(NSData *)newLineData {
  NSError *dataError = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&dataError];
  if (dataError) {
    FIRCLSDebugLog(@"Unable to write out dictionary.");
    return NO;
  }

  [file seekToEndOfFile];
  [file writeData:newLineData];
  [file writeData:data];
}

@end

#endif  // CLS_METRICKIT_SUPPORTED
