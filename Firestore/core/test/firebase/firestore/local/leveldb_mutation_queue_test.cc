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

#include <string>
#include <vector>

#include "Firestore/Protos/nanopb/firestore/local/mutation.nanopb.h"
#include "Firestore/Protos/nanopb/google/protobuf/empty.nanopb.h"
#include "Firestore/core/src/firebase/firestore/auth/user.h"
#include "Firestore/core/src/firebase/firestore/local/leveldb_key.h"
#include "Firestore/core/src/firebase/firestore/local/leveldb_mutation_queue.h"
#include "Firestore/core/src/firebase/firestore/local/leveldb_persistence.h"
#include "Firestore/core/src/firebase/firestore/local/reference_set.h"
#include "Firestore/core/src/firebase/firestore/nanopb/byte_string.h"
#include "Firestore/core/src/firebase/firestore/nanopb/fields_array.h"
#include "Firestore/core/src/firebase/firestore/nanopb/message.h"
#include "Firestore/core/src/firebase/firestore/nanopb/reader.h"
#include "Firestore/core/src/firebase/firestore/nanopb/writer.h"
#include "Firestore/core/src/firebase/firestore/util/ordered_code.h"
#include "Firestore/core/test/firebase/firestore/local/mutation_queue_test.h"
#include "Firestore/core/test/firebase/firestore/local/persistence_testing.h"
#include "Firestore/core/test/firebase/firestore/util/status_testing.h"
#include "absl/strings/string_view.h"
#include "gtest/gtest.h"
#include "leveldb/db.h"

namespace firebase {
namespace firestore {
namespace local {
namespace {

using auth::User;
using leveldb::DB;
using leveldb::Slice;
using leveldb::Status;
using leveldb::WriteOptions;
using model::BatchId;
using nanopb::ByteString;
using nanopb::Message;
using nanopb::StringReader;
using nanopb::StringWriter;
using util::OrderedCode;

// A dummy mutation value, useful for testing code that's known to examine only
// mutation keys.
const char* kDummy = "1";

std::unique_ptr<Persistence> PersistenceFactory() {
  return LevelDbPersistenceForTesting();
}

}  // namespace

INSTANTIATE_TEST_CASE_P(LevelDbMutationQueueTest,
                        MutationQueueTest,
                        testing::Values(PersistenceFactory));

class LevelDbMutationQueueTest : public MutationQueueTestBase {
 public:
  LevelDbMutationQueueTest()
      : MutationQueueTestBase(PersistenceFactory()),
        db_(static_cast<LevelDbPersistence*>(persistence_.get())->ptr()) {
  }

 protected:
  void SetDummyValueForKey(const std::string& key);

  DB* db_;
};

/**
 * Creates a key that's structurally the same as LevelDbMutationKey except it
 * allows for nonstandard table names.
 */
std::string MutationLikeKey(absl::string_view table,
                            absl::string_view user_id,
                            BatchId batch_id) {
  std::string key;
  OrderedCode::WriteSignedNumIncreasing(&key, 5);  // TableName
  OrderedCode::WriteString(&key, table);
  OrderedCode::WriteSignedNumIncreasing(&key, 13);  // UserId
  OrderedCode::WriteString(&key, user_id);
  OrderedCode::WriteSignedNumIncreasing(&key, 10);  // BatchId
  OrderedCode::WriteSignedNumIncreasing(&key, batch_id);
  OrderedCode::WriteSignedNumIncreasing(&key, 0);  // Terminator
  return key;
}

TEST_F(LevelDbMutationQueueTest, LoadNextBatchID_zeroWhenTotallyEmpty) {
  // Initial seek is invalid
  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 1);
}

TEST_F(LevelDbMutationQueueTest, LoadNextBatchID_zeroWhenNoMutations) {
  // Initial seek finds no mutations
  SetDummyValueForKey(MutationLikeKey("mutationr", "foo", 20));
  SetDummyValueForKey(MutationLikeKey("mutationsa", "foo", 10));
  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 1);
}

TEST_F(LevelDbMutationQueueTest, LoadNextBatchID_findsSingleRow) {
  // Seeks off the end of the table altogether
  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 6));

  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 7);
}

TEST_F(LevelDbMutationQueueTest,
       LoadNextBatchID_findsSingleRowAmongNonMutations) {
  // Seeks into table following mutations.
  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 6));
  SetDummyValueForKey(MutationLikeKey("mutationsa", "foo", 10));

  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 7);
}

TEST_F(LevelDbMutationQueueTest, LoadNextBatchID_findsMaxAcrossUsers) {
  SetDummyValueForKey(LevelDbMutationKey::Key("fo", 5));
  SetDummyValueForKey(LevelDbMutationKey::Key("food", 3));

  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 6));
  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 2));
  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 1));

  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 7);
}

TEST_F(LevelDbMutationQueueTest, LoadNextBatchID_onlyFindsMutations) {
  // Write higher-valued batch_i_ds in nearby "tables"
  std::vector<std::string> tables{"mutatio", "mutationsa", "bears", "zombies"};
  BatchId high_batch_id = 5;
  for (const auto& table : tables) {
    SetDummyValueForKey(MutationLikeKey(table, "", high_batch_id++));
  }

  SetDummyValueForKey(LevelDbMutationKey::Key("bar", 3));
  SetDummyValueForKey(LevelDbMutationKey::Key("bar", 2));
  SetDummyValueForKey(LevelDbMutationKey::Key("foo", 1));

  // None of the higher tables should match -- this is the only entry that's in
  // the mutations table
  ASSERT_EQ(LoadNextBatchIdFromDb(db_), 4);
}

TEST_F(LevelDbMutationQueueTest, EmptyProtoCanBeUpgraded) {
  // An empty protocol buffer serializes to a zero-length byte buffer.
  google_protobuf_Empty empty{};

  StringWriter writer;
  writer.Write(google_protobuf_Empty_fields, &empty);
  std::string empty_data = writer.Release();
  ASSERT_EQ(empty_data.size(), 0);

  // Choose some other (arbitrary) proto and parse it from the empty message and
  // it should all be defaults. This shows that empty proto values within the
  // index row value don't pose any future liability.
  StringReader reader(empty_data);
  auto parsed_message =
      Message<firestore_client_MutationQueue>::TryParse(&reader);
  ASSERT_OK(reader.status());

  Message<firestore_client_MutationQueue> default_message;
  ASSERT_EQ(parsed_message->last_acknowledged_batch_id,
            default_message->last_acknowledged_batch_id);
  ASSERT_EQ(ByteString(parsed_message->last_stream_token),
            ByteString(default_message->last_stream_token));
}

void LevelDbMutationQueueTest::SetDummyValueForKey(const std::string& key) {
  db_->Put(WriteOptions(), key, kDummy);
}

}  // namespace local
}  // namespace firestore
}  // namespace firebase
