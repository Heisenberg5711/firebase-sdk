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

#include "Firestore/core/src/api/aggregate_query.h"

#include <utility>

#include "Firestore/core/src/api/api_fwd.h"
#include "Firestore/core/src/api/firestore.h"
#include "Firestore/core/src/core/firestore_client.h"

namespace firebase {
namespace firestore {
namespace api {

AggregateQuery::AggregateQuery(Query query) : query_{std::move(query)} {
}

void AggregateQuery::Get(CountQueryCallback&& callback) {
  query_.firestore()->client()->RunCountQuery(query_.query(),
                                              std::move(callback));
}

bool operator==(const AggregateQuery& lhs, const AggregateQuery& rhs) {
  return lhs.query() == rhs.query();
}

}  // namespace api
}  // namespace firestore
}  // namespace firebase
