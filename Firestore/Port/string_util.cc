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

#include "Firestore/Port/string_util.h"

#include <leveldb/db.h>

namespace Firestore {

std::string PrefixSuccessor(leveldb::Slice prefix) {
  // We can increment the last character in the string and be done
  // unless that character is 255 (0xff), in which case we have to erase the
  // last character and increment the previous character, unless that
  // is 255, etc. If the string is empty or consists entirely of
  // 255's, we just return the empty string.
  std::string limit(prefix.data(), prefix.size());
  while (!limit.empty()) {
    size_t index = limit.length() - 1;
    if (limit[index] == '\xff') {  // char literal avoids signed/unsigned.
      limit.erase(index);
    } else {
      limit[index]++;
      break;
    }
  }
  return limit;
}

std::string ImmediateSuccessor(leveldb::Slice s) {
  // Return the input string, with an additional NUL byte appended.
  std::string out;
  out.reserve(s.size() + 1);
  out.append(s.data(), s.size());
  out.push_back('\0');
  return out;
}

}  // namespace Firestore
