/*
* Copyright 2022 Google LLC
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

#ifndef FIRESTORE_CORE_SRC_LOCAL_OVERLAY_MIGRATION_MANAGER_H_
#define FIRESTORE_CORE_SRC_LOCAL_OVERLAY_MIGRATION_MANAGER_H_

namespace firebase {
namespace firestore {
namespace local {

/**
 * Provides methods to save and read Firestore bundles.
 */
class OverlayMigrationManager {
 public:
  virtual ~OverlayMigrationManager() = default;

  virtual void Run() = 0;
};

}  // namespace local
}  // namespace firestore
}  // namespace firebase


#endif  // FIRESTORE_CORE_SRC_LOCAL_OVERLAY_MIGRATION_MANAGER_H_
