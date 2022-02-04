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

#include "Firestore/core/src/local/memory_document_overlay_cache.h"

#include "Firestore/core/src/util/hard_assert.h"

namespace firebase {
namespace firestore {
namespace local {

using model::DocumentKey;
using model::Mutation;
using model::mutation::Overlay;

absl::optional<Overlay> MemoryDocumentOverlayCache::GetOverlay(const DocumentKey& key) const {
  const auto overlay_iter = overlays_.find(key);
  if (overlay_iter == overlays_.end()) {
    return absl::nullopt;
  } else {
    return overlay_iter->second;
  }
}

void MemoryDocumentOverlayCache::SaveOverlay(int largest_batch_id, const Mutation& mutation) {
  {
    const auto overlays_iter = overlays_.find(mutation.key());
    if (overlays_iter != overlays_.end()) {
      const Overlay& existing = overlays_iter->second;
      auto overlay_by_batch_id_iter = overlay_by_batch_id_.find(existing.largest_batch_id());
      HARD_ASSERT(overlay_by_batch_id_iter != overlay_by_batch_id_.end());
      DocumentKeySet& existing_keys = overlay_by_batch_id_iter->second;
      existing_keys.erase(mutation.key());
      overlays_.erase(overlays_iter);
    }
  }

  overlays_.insert({mutation.key(), Overlay(largest_batch_id, mutation)});

  overlay_by_batch_id_[largest_batch_id].insert(mutation.key());
}

void MemoryDocumentOverlayCache::SaveOverlays(int largest_batch_id, const MutationByDocumentKeyMap& overlays) {
  for (auto& kv : overlays) {
    SaveOverlay(largest_batch_id, kv.second);
  }
}

void MemoryDocumentOverlayCache::RemoveOverlaysForBatchId(int batch_id) {
  const auto overlay_by_batch_id_iter = overlay_by_batch_id_.find(batch_id);
  if (overlay_by_batch_id_iter != overlay_by_batch_id_.end()) {
    const DocumentKeySet& keys = overlay_by_batch_id_iter->second;
    for (const auto& key : keys) {
      overlays_.erase(key);
    }
    overlay_by_batch_id_.erase(overlay_by_batch_id_iter);
  }
}

DocumentOverlayCache::OverlayByDocumentKeyMap MemoryDocumentOverlayCache::GetOverlays(const model::ResourcePath& collection, int since_batch_id) const {
  (void)collection;
  (void)since_batch_id;
  OverlayByDocumentKeyMap result;

  size_t immediate_children_path_length{collection.size() + 1};
  DocumentKey prefix(collection.Append(""));
  const auto view = overlays_.lower_bound(prefix);

  (void)immediate_children_path_length;
  (void)view;

  return result;
}

DocumentOverlayCache::OverlayByDocumentKeyMap MemoryDocumentOverlayCache::GetOverlays(absl::string_view collection_group, int since_batch_id, int count) const {
  (void)collection_group;
  (void)since_batch_id;
  (void)count;
  abort();
  return {};
}


}  // namespace local
}  // namespace firestore
}  // namespace firebase
