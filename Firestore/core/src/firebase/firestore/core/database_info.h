/*
 * Copyright 2018 Google
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

#ifndef FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_CORE_DATABASE_INFO_H_
#define FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_CORE_DATABASE_INFO_H_

#include <string>

#include "Firestore/core/src/firebase/firestore/model/database_id.h"
#include "absl/strings/string_view.h"

namespace firebase {
namespace firestore {
namespace core {

/** FSTDatabaseInfo contains data about the database. */
class DatabaseInfo {
 public:
  /**
   * Creates and returns a new FSTDatabaseInfo.
   *
   * @param database_id The project/database to use.
   * @param persistence_key A unique identifier for this Firestore's local
   * storage. Usually derived from -[FIRApp appName].
   * @param host The hostname of the datastore backend.
   * @param ssl_enabled Whether to use SSL when connecting.
   */
  DatabaseInfo(const firebase::firestore::model::DatabaseId& database_id,
               const absl::string_view persistence_key,
               const absl::string_view host,
               bool ssl_enabled);

  const firebase::firestore::model::DatabaseId& database_id() const {
    return database_id_;
  }

  const std::string& persistence_key() const {
    return persistence_key_;
  }

  const std::string& host() const {
    return host_;
  }

  bool ssl_enabled() const {
    return ssl_enabled_;
  }

 private:
  firebase::firestore::model::DatabaseId database_id_;
  std::string persistence_key_;
  std::string host_;
  bool ssl_enabled_;
};

}  // namespace core
}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_CORE_DATABASE_INFO_H_
