/*
 * Copyright 2019 Google
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

#import "FIRMessagingExtensionHelper.h"

#import "FIRMMessageCode.h"
#import "FIRMessagingLogger.h"

static NSString *const kPayloadOptionsName = @"fcm_options";
static NSString *const kPayloadOptionsImageURLName = @"image";

@interface FIRMessagingExtensionHelper ()

@property(nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property(nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation FIRMessagingExtensionHelper

- (void)populateNotificationContent:(UNMutableNotificationContent *)content
                 withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
  self.contentHandler = [contentHandler copy];
  self.bestAttemptContent = content;

  NSString *currentImageURL = content.userInfo[kPayloadOptionsName][kPayloadOptionsImageURLName];
  if (!currentImageURL) {
    [self deliverNotification];
    return;
  }
  NSURL *attachmentURL = [NSURL URLWithString:currentImageURL];
  if (attachmentURL) {
    [self loadAttachmentForURL:attachmentURL
             completionHandler:^(UNNotificationAttachment *attachment) {
               self.bestAttemptContent.attachments = @[ attachment ];
               [self deliverNotification];
             }];
  } else {
    FIRMessagingLoggerError(kFIRMessagingServiceExtensionImageInvalidURL,
                            @"The Image URL provided is invalid %@.", currentImageURL);
    [self deliverNotification];
  }
}

- (void)loadAttachmentForURL:(NSURL *)attachmentURL
           completionHandler:(void (^)(UNNotificationAttachment *))completionHandler {
  __block UNNotificationAttachment *attachment = nil;

  NSURLSession *session = [NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  __weak FIRMessagingExtensionHelper *weakSelf = self;
  [[session
      downloadTaskWithURL:attachmentURL
        completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
          if (error != nil) {
            FIRMessagingLoggerError(kFIRMessagingServiceExtensionImageNotDownloaded,
                                    @"Failed to download image given URL %@, error: %@\n",
                                    attachmentURL, error);
            [weakSelf deliverNotification];
            return;
          }

          NSFileManager *fileManager = [NSFileManager defaultManager];
          NSString *fileExtension =
              [NSString stringWithFormat:@".%@", [response.suggestedFilename pathExtension]];
          NSURL *localURL = [NSURL
              fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExtension]];
          [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
          if (error) {
            FIRMessagingLoggerError(
                kFIRMessagingServiceExtensionLocalFileNotCreated,
                @"Failed to move the image file to local location: %@, error: %@\n", localURL,
                error);
            [weakSelf deliverNotification];
            return;
          }

          attachment = [UNNotificationAttachment attachmentWithIdentifier:@""
                                                                      URL:localURL
                                                                  options:nil
                                                                    error:&error];
          if (error) {
            FIRMessagingLoggerError(kFIRMessagingServiceExtensionImageNotAttached,
                                    @"Failed to attach the image to attachments, error: %@\n",
                                    error);
            [weakSelf deliverNotification];
            return;
          }
          completionHandler(attachment);
        }] resume];
}

- (void)deliverNotification {
  if (self.contentHandler) {
    self.contentHandler(self.bestAttemptContent);
  }
}

@end
