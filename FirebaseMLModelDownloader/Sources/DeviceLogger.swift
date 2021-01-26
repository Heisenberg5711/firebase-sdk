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

import Foundation
#if SWIFT_PACKAGE
  import GoogleUtilities_Logger
#else
  import GoogleUtilities
#endif

/// Enum of debug messages.
// TODO: Create list of all possible messages with code - according to format.
enum LoggerMessageCode: Int {
  case modelDownloaded = 1
  case downloadedModelMovedToURL
  case downloadedModelSaveError
  case analyticsEventEncodeError
  case telemetryInitError
  case backgroundDownloadError
  case testError
}

/// On-device logger.
class DeviceLogger {
  static let service = "[Firebase/MLModelDownloader]"
  static func logEvent(level: GoogleLoggerLevel, message: String, messageCode: LoggerMessageCode) {
    let code = String(format: "I-MLM%06d", messageCode.rawValue)
    let args: [CVarArg] = []
    GULLoggerWrapper.log(
      with: level,
      withService: DeviceLogger.service,
      withCode: code,
      withMessage: message,
      withArgs: getVaList(args)
    )
  }
}
