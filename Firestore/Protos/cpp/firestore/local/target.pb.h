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

// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: firestore/local/target.proto

#ifndef GOOGLE_PROTOBUF_INCLUDED_firestore_2flocal_2ftarget_2eproto
#define GOOGLE_PROTOBUF_INCLUDED_firestore_2flocal_2ftarget_2eproto

#include <limits>
#include <string>

#include <google/protobuf/port_def.inc>
#if PROTOBUF_VERSION < 3009000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers. Please update
#error your headers.
#endif
#if 3009002 < PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers. Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/port_undef.inc>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/arena.h>
#include <google/protobuf/arenastring.h>
#include <google/protobuf/generated_message_table_driven.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/inlined_string_field.h>
#include <google/protobuf/metadata.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/message.h>
#include <google/protobuf/repeated_field.h>  // IWYU pragma: export
#include <google/protobuf/extension_set.h>  // IWYU pragma: export
#include <google/protobuf/unknown_field_set.h>
#include "google/firestore/v1/firestore.pb.h"
#include <google/protobuf/timestamp.pb.h>
// @@protoc_insertion_point(includes)
#include <google/protobuf/port_def.inc>
#define PROTOBUF_INTERNAL_EXPORT_firestore_2flocal_2ftarget_2eproto
PROTOBUF_NAMESPACE_OPEN
namespace internal {
class AnyMetadata;
}  // namespace internal
PROTOBUF_NAMESPACE_CLOSE

// Internal implementation detail -- do not use these members.
struct TableStruct_firestore_2flocal_2ftarget_2eproto {
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTableField entries[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::AuxillaryParseTableField aux[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTable schema[2]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::FieldMetadata field_metadata[];
  static const ::PROTOBUF_NAMESPACE_ID::internal::SerializationTable serialization_table[];
  static const ::PROTOBUF_NAMESPACE_ID::uint32 offsets[];
};
extern const ::PROTOBUF_NAMESPACE_ID::internal::DescriptorTable descriptor_table_firestore_2flocal_2ftarget_2eproto;
namespace firestore {
namespace client {
class Target;
class TargetDefaultTypeInternal;
extern TargetDefaultTypeInternal _Target_default_instance_;
class TargetGlobal;
class TargetGlobalDefaultTypeInternal;
extern TargetGlobalDefaultTypeInternal _TargetGlobal_default_instance_;
}  // namespace client
}  // namespace firestore
PROTOBUF_NAMESPACE_OPEN
template<> ::firestore::client::Target* Arena::CreateMaybeMessage<::firestore::client::Target>(Arena*);
template<> ::firestore::client::TargetGlobal* Arena::CreateMaybeMessage<::firestore::client::TargetGlobal>(Arena*);
PROTOBUF_NAMESPACE_CLOSE
namespace firestore {
namespace client {

// ===================================================================

class Target :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:firestore.client.Target) */ {
 public:
  Target();
  virtual ~Target();

  Target(const Target& from);
  Target(Target&& from) noexcept
    : Target() {
    *this = ::std::move(from);
  }

  inline Target& operator=(const Target& from) {
    CopyFrom(from);
    return *this;
  }
  inline Target& operator=(Target&& from) noexcept {
    if (GetArenaNoVirtual() == from.GetArenaNoVirtual()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return GetMetadataStatic().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return GetMetadataStatic().reflection;
  }
  static const Target& default_instance();

  enum TargetTypeCase {
    kQuery = 5,
    kDocuments = 6,
    TARGET_TYPE_NOT_SET = 0,
  };

  static void InitAsDefaultInstance();  // FOR INTERNAL USE ONLY
  static inline const Target* internal_default_instance() {
    return reinterpret_cast<const Target*>(
               &_Target_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    0;

  friend void swap(Target& a, Target& b) {
    a.Swap(&b);
  }
  inline void Swap(Target* other) {
    if (other == this) return;
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  inline Target* New() const final {
    return CreateMaybeMessage<Target>(nullptr);
  }

  Target* New(::PROTOBUF_NAMESPACE_ID::Arena* arena) const final {
    return CreateMaybeMessage<Target>(arena);
  }
  void CopyFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void MergeFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void CopyFrom(const Target& from);
  void MergeFrom(const Target& from);
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  #if GOOGLE_PROTOBUF_ENABLE_EXPERIMENTAL_PARSER
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  #else
  bool MergePartialFromCodedStream(
      ::PROTOBUF_NAMESPACE_ID::io::CodedInputStream* input) final;
  #endif  // GOOGLE_PROTOBUF_ENABLE_EXPERIMENTAL_PARSER
  void SerializeWithCachedSizes(
      ::PROTOBUF_NAMESPACE_ID::io::CodedOutputStream* output) const final;
  ::PROTOBUF_NAMESPACE_ID::uint8* InternalSerializeWithCachedSizesToArray(
      ::PROTOBUF_NAMESPACE_ID::uint8* target) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  inline void SharedCtor();
  inline void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(Target* other);
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "firestore.client.Target";
  }
  private:
  inline ::PROTOBUF_NAMESPACE_ID::Arena* GetArenaNoVirtual() const {
    return nullptr;
  }
  inline void* MaybeArenaPtr() const {
    return nullptr;
  }
  public:

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;
  private:
  static ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadataStatic() {
    ::PROTOBUF_NAMESPACE_ID::internal::AssignDescriptors(&::descriptor_table_firestore_2flocal_2ftarget_2eproto);
    return ::descriptor_table_firestore_2flocal_2ftarget_2eproto.file_level_metadata[kIndexInFileMessages];
  }

  public:

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kResumeTokenFieldNumber = 3,
    kSnapshotVersionFieldNumber = 2,
    kLastListenSequenceNumberFieldNumber = 4,
    kTargetIdFieldNumber = 1,
    kQueryFieldNumber = 5,
    kDocumentsFieldNumber = 6,
  };
  // bytes resume_token = 3;
  void clear_resume_token();
  const std::string& resume_token() const;
  void set_resume_token(const std::string& value);
  void set_resume_token(std::string&& value);
  void set_resume_token(const char* value);
  void set_resume_token(const void* value, size_t size);
  std::string* mutable_resume_token();
  std::string* release_resume_token();
  void set_allocated_resume_token(std::string* resume_token);

  // .google.protobuf.Timestamp snapshot_version = 2;
  bool has_snapshot_version() const;
  void clear_snapshot_version();
  const PROTOBUF_NAMESPACE_ID::Timestamp& snapshot_version() const;
  PROTOBUF_NAMESPACE_ID::Timestamp* release_snapshot_version();
  PROTOBUF_NAMESPACE_ID::Timestamp* mutable_snapshot_version();
  void set_allocated_snapshot_version(PROTOBUF_NAMESPACE_ID::Timestamp* snapshot_version);

  // int64 last_listen_sequence_number = 4;
  void clear_last_listen_sequence_number();
  ::PROTOBUF_NAMESPACE_ID::int64 last_listen_sequence_number() const;
  void set_last_listen_sequence_number(::PROTOBUF_NAMESPACE_ID::int64 value);

  // int32 target_id = 1;
  void clear_target_id();
  ::PROTOBUF_NAMESPACE_ID::int32 target_id() const;
  void set_target_id(::PROTOBUF_NAMESPACE_ID::int32 value);

  // .google.firestore.v1.Target.QueryTarget query = 5;
  bool has_query() const;
  void clear_query();
  const ::google::firestore::v1::Target_QueryTarget& query() const;
  ::google::firestore::v1::Target_QueryTarget* release_query();
  ::google::firestore::v1::Target_QueryTarget* mutable_query();
  void set_allocated_query(::google::firestore::v1::Target_QueryTarget* query);

  // .google.firestore.v1.Target.DocumentsTarget documents = 6;
  bool has_documents() const;
  void clear_documents();
  const ::google::firestore::v1::Target_DocumentsTarget& documents() const;
  ::google::firestore::v1::Target_DocumentsTarget* release_documents();
  ::google::firestore::v1::Target_DocumentsTarget* mutable_documents();
  void set_allocated_documents(::google::firestore::v1::Target_DocumentsTarget* documents);

  void clear_target_type();
  TargetTypeCase target_type_case() const;
  // @@protoc_insertion_point(class_scope:firestore.client.Target)
 private:
  class _Internal;
  void set_has_query();
  void set_has_documents();

  inline bool has_target_type() const;
  inline void clear_has_target_type();

  ::PROTOBUF_NAMESPACE_ID::internal::InternalMetadataWithArena _internal_metadata_;
  ::PROTOBUF_NAMESPACE_ID::internal::ArenaStringPtr resume_token_;
  PROTOBUF_NAMESPACE_ID::Timestamp* snapshot_version_;
  ::PROTOBUF_NAMESPACE_ID::int64 last_listen_sequence_number_;
  ::PROTOBUF_NAMESPACE_ID::int32 target_id_;
  union TargetTypeUnion {
    TargetTypeUnion() {}
    ::google::firestore::v1::Target_QueryTarget* query_;
    ::google::firestore::v1::Target_DocumentsTarget* documents_;
  } target_type_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  ::PROTOBUF_NAMESPACE_ID::uint32 _oneof_case_[1];

  friend struct ::TableStruct_firestore_2flocal_2ftarget_2eproto;
};
// -------------------------------------------------------------------

class TargetGlobal :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:firestore.client.TargetGlobal) */ {
 public:
  TargetGlobal();
  virtual ~TargetGlobal();

  TargetGlobal(const TargetGlobal& from);
  TargetGlobal(TargetGlobal&& from) noexcept
    : TargetGlobal() {
    *this = ::std::move(from);
  }

  inline TargetGlobal& operator=(const TargetGlobal& from) {
    CopyFrom(from);
    return *this;
  }
  inline TargetGlobal& operator=(TargetGlobal&& from) noexcept {
    if (GetArenaNoVirtual() == from.GetArenaNoVirtual()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return GetMetadataStatic().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return GetMetadataStatic().reflection;
  }
  static const TargetGlobal& default_instance();

  static void InitAsDefaultInstance();  // FOR INTERNAL USE ONLY
  static inline const TargetGlobal* internal_default_instance() {
    return reinterpret_cast<const TargetGlobal*>(
               &_TargetGlobal_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    1;

  friend void swap(TargetGlobal& a, TargetGlobal& b) {
    a.Swap(&b);
  }
  inline void Swap(TargetGlobal* other) {
    if (other == this) return;
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  inline TargetGlobal* New() const final {
    return CreateMaybeMessage<TargetGlobal>(nullptr);
  }

  TargetGlobal* New(::PROTOBUF_NAMESPACE_ID::Arena* arena) const final {
    return CreateMaybeMessage<TargetGlobal>(arena);
  }
  void CopyFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void MergeFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void CopyFrom(const TargetGlobal& from);
  void MergeFrom(const TargetGlobal& from);
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  #if GOOGLE_PROTOBUF_ENABLE_EXPERIMENTAL_PARSER
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  #else
  bool MergePartialFromCodedStream(
      ::PROTOBUF_NAMESPACE_ID::io::CodedInputStream* input) final;
  #endif  // GOOGLE_PROTOBUF_ENABLE_EXPERIMENTAL_PARSER
  void SerializeWithCachedSizes(
      ::PROTOBUF_NAMESPACE_ID::io::CodedOutputStream* output) const final;
  ::PROTOBUF_NAMESPACE_ID::uint8* InternalSerializeWithCachedSizesToArray(
      ::PROTOBUF_NAMESPACE_ID::uint8* target) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  inline void SharedCtor();
  inline void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(TargetGlobal* other);
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "firestore.client.TargetGlobal";
  }
  private:
  inline ::PROTOBUF_NAMESPACE_ID::Arena* GetArenaNoVirtual() const {
    return nullptr;
  }
  inline void* MaybeArenaPtr() const {
    return nullptr;
  }
  public:

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;
  private:
  static ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadataStatic() {
    ::PROTOBUF_NAMESPACE_ID::internal::AssignDescriptors(&::descriptor_table_firestore_2flocal_2ftarget_2eproto);
    return ::descriptor_table_firestore_2flocal_2ftarget_2eproto.file_level_metadata[kIndexInFileMessages];
  }

  public:

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kLastRemoteSnapshotVersionFieldNumber = 3,
    kHighestListenSequenceNumberFieldNumber = 2,
    kHighestTargetIdFieldNumber = 1,
    kTargetCountFieldNumber = 4,
  };
  // .google.protobuf.Timestamp last_remote_snapshot_version = 3;
  bool has_last_remote_snapshot_version() const;
  void clear_last_remote_snapshot_version();
  const PROTOBUF_NAMESPACE_ID::Timestamp& last_remote_snapshot_version() const;
  PROTOBUF_NAMESPACE_ID::Timestamp* release_last_remote_snapshot_version();
  PROTOBUF_NAMESPACE_ID::Timestamp* mutable_last_remote_snapshot_version();
  void set_allocated_last_remote_snapshot_version(PROTOBUF_NAMESPACE_ID::Timestamp* last_remote_snapshot_version);

  // int64 highest_listen_sequence_number = 2;
  void clear_highest_listen_sequence_number();
  ::PROTOBUF_NAMESPACE_ID::int64 highest_listen_sequence_number() const;
  void set_highest_listen_sequence_number(::PROTOBUF_NAMESPACE_ID::int64 value);

  // int32 highest_target_id = 1;
  void clear_highest_target_id();
  ::PROTOBUF_NAMESPACE_ID::int32 highest_target_id() const;
  void set_highest_target_id(::PROTOBUF_NAMESPACE_ID::int32 value);

  // int32 target_count = 4;
  void clear_target_count();
  ::PROTOBUF_NAMESPACE_ID::int32 target_count() const;
  void set_target_count(::PROTOBUF_NAMESPACE_ID::int32 value);

  // @@protoc_insertion_point(class_scope:firestore.client.TargetGlobal)
 private:
  class _Internal;

  ::PROTOBUF_NAMESPACE_ID::internal::InternalMetadataWithArena _internal_metadata_;
  PROTOBUF_NAMESPACE_ID::Timestamp* last_remote_snapshot_version_;
  ::PROTOBUF_NAMESPACE_ID::int64 highest_listen_sequence_number_;
  ::PROTOBUF_NAMESPACE_ID::int32 highest_target_id_;
  ::PROTOBUF_NAMESPACE_ID::int32 target_count_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  friend struct ::TableStruct_firestore_2flocal_2ftarget_2eproto;
};
// ===================================================================


// ===================================================================

#ifdef __GNUC__
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif  // __GNUC__
// Target

// int32 target_id = 1;
inline void Target::clear_target_id() {
  target_id_ = 0;
}
inline ::PROTOBUF_NAMESPACE_ID::int32 Target::target_id() const {
  // @@protoc_insertion_point(field_get:firestore.client.Target.target_id)
  return target_id_;
}
inline void Target::set_target_id(::PROTOBUF_NAMESPACE_ID::int32 value) {
  
  target_id_ = value;
  // @@protoc_insertion_point(field_set:firestore.client.Target.target_id)
}

// .google.protobuf.Timestamp snapshot_version = 2;
inline bool Target::has_snapshot_version() const {
  return this != internal_default_instance() && snapshot_version_ != nullptr;
}
inline const PROTOBUF_NAMESPACE_ID::Timestamp& Target::snapshot_version() const {
  const PROTOBUF_NAMESPACE_ID::Timestamp* p = snapshot_version_;
  // @@protoc_insertion_point(field_get:firestore.client.Target.snapshot_version)
  return p != nullptr ? *p : *reinterpret_cast<const PROTOBUF_NAMESPACE_ID::Timestamp*>(
      &PROTOBUF_NAMESPACE_ID::_Timestamp_default_instance_);
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Target::release_snapshot_version() {
  // @@protoc_insertion_point(field_release:firestore.client.Target.snapshot_version)
  
  PROTOBUF_NAMESPACE_ID::Timestamp* temp = snapshot_version_;
  snapshot_version_ = nullptr;
  return temp;
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Target::mutable_snapshot_version() {
  
  if (snapshot_version_ == nullptr) {
    auto* p = CreateMaybeMessage<PROTOBUF_NAMESPACE_ID::Timestamp>(GetArenaNoVirtual());
    snapshot_version_ = p;
  }
  // @@protoc_insertion_point(field_mutable:firestore.client.Target.snapshot_version)
  return snapshot_version_;
}
inline void Target::set_allocated_snapshot_version(PROTOBUF_NAMESPACE_ID::Timestamp* snapshot_version) {
  ::PROTOBUF_NAMESPACE_ID::Arena* message_arena = GetArenaNoVirtual();
  if (message_arena == nullptr) {
    delete reinterpret_cast< ::PROTOBUF_NAMESPACE_ID::MessageLite*>(snapshot_version_);
  }
  if (snapshot_version) {
    ::PROTOBUF_NAMESPACE_ID::Arena* submessage_arena =
      reinterpret_cast<::PROTOBUF_NAMESPACE_ID::MessageLite*>(snapshot_version)->GetArena();
    if (message_arena != submessage_arena) {
      snapshot_version = ::PROTOBUF_NAMESPACE_ID::internal::GetOwnedMessage(
          message_arena, snapshot_version, submessage_arena);
    }
    
  } else {
    
  }
  snapshot_version_ = snapshot_version;
  // @@protoc_insertion_point(field_set_allocated:firestore.client.Target.snapshot_version)
}

// bytes resume_token = 3;
inline void Target::clear_resume_token() {
  resume_token_.ClearToEmptyNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited());
}
inline const std::string& Target::resume_token() const {
  // @@protoc_insertion_point(field_get:firestore.client.Target.resume_token)
  return resume_token_.GetNoArena();
}
inline void Target::set_resume_token(const std::string& value) {
  
  resume_token_.SetNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), value);
  // @@protoc_insertion_point(field_set:firestore.client.Target.resume_token)
}
inline void Target::set_resume_token(std::string&& value) {
  
  resume_token_.SetNoArena(
    &::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), ::std::move(value));
  // @@protoc_insertion_point(field_set_rvalue:firestore.client.Target.resume_token)
}
inline void Target::set_resume_token(const char* value) {
  GOOGLE_DCHECK(value != nullptr);
  
  resume_token_.SetNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), ::std::string(value));
  // @@protoc_insertion_point(field_set_char:firestore.client.Target.resume_token)
}
inline void Target::set_resume_token(const void* value, size_t size) {
  
  resume_token_.SetNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(),
      ::std::string(reinterpret_cast<const char*>(value), size));
  // @@protoc_insertion_point(field_set_pointer:firestore.client.Target.resume_token)
}
inline std::string* Target::mutable_resume_token() {
  
  // @@protoc_insertion_point(field_mutable:firestore.client.Target.resume_token)
  return resume_token_.MutableNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited());
}
inline std::string* Target::release_resume_token() {
  // @@protoc_insertion_point(field_release:firestore.client.Target.resume_token)
  
  return resume_token_.ReleaseNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited());
}
inline void Target::set_allocated_resume_token(std::string* resume_token) {
  if (resume_token != nullptr) {
    
  } else {
    
  }
  resume_token_.SetAllocatedNoArena(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), resume_token);
  // @@protoc_insertion_point(field_set_allocated:firestore.client.Target.resume_token)
}

// int64 last_listen_sequence_number = 4;
inline void Target::clear_last_listen_sequence_number() {
  last_listen_sequence_number_ = PROTOBUF_LONGLONG(0);
}
inline ::PROTOBUF_NAMESPACE_ID::int64 Target::last_listen_sequence_number() const {
  // @@protoc_insertion_point(field_get:firestore.client.Target.last_listen_sequence_number)
  return last_listen_sequence_number_;
}
inline void Target::set_last_listen_sequence_number(::PROTOBUF_NAMESPACE_ID::int64 value) {
  
  last_listen_sequence_number_ = value;
  // @@protoc_insertion_point(field_set:firestore.client.Target.last_listen_sequence_number)
}

// .google.firestore.v1.Target.QueryTarget query = 5;
inline bool Target::has_query() const {
  return target_type_case() == kQuery;
}
inline void Target::set_has_query() {
  _oneof_case_[0] = kQuery;
}
inline ::google::firestore::v1::Target_QueryTarget* Target::release_query() {
  // @@protoc_insertion_point(field_release:firestore.client.Target.query)
  if (has_query()) {
    clear_has_target_type();
      ::google::firestore::v1::Target_QueryTarget* temp = target_type_.query_;
    target_type_.query_ = nullptr;
    return temp;
  } else {
    return nullptr;
  }
}
inline const ::google::firestore::v1::Target_QueryTarget& Target::query() const {
  // @@protoc_insertion_point(field_get:firestore.client.Target.query)
  return has_query()
      ? *target_type_.query_
      : *reinterpret_cast< ::google::firestore::v1::Target_QueryTarget*>(&::google::firestore::v1::_Target_QueryTarget_default_instance_);
}
inline ::google::firestore::v1::Target_QueryTarget* Target::mutable_query() {
  if (!has_query()) {
    clear_target_type();
    set_has_query();
    target_type_.query_ = CreateMaybeMessage< ::google::firestore::v1::Target_QueryTarget >(
        GetArenaNoVirtual());
  }
  // @@protoc_insertion_point(field_mutable:firestore.client.Target.query)
  return target_type_.query_;
}

// .google.firestore.v1.Target.DocumentsTarget documents = 6;
inline bool Target::has_documents() const {
  return target_type_case() == kDocuments;
}
inline void Target::set_has_documents() {
  _oneof_case_[0] = kDocuments;
}
inline ::google::firestore::v1::Target_DocumentsTarget* Target::release_documents() {
  // @@protoc_insertion_point(field_release:firestore.client.Target.documents)
  if (has_documents()) {
    clear_has_target_type();
      ::google::firestore::v1::Target_DocumentsTarget* temp = target_type_.documents_;
    target_type_.documents_ = nullptr;
    return temp;
  } else {
    return nullptr;
  }
}
inline const ::google::firestore::v1::Target_DocumentsTarget& Target::documents() const {
  // @@protoc_insertion_point(field_get:firestore.client.Target.documents)
  return has_documents()
      ? *target_type_.documents_
      : *reinterpret_cast< ::google::firestore::v1::Target_DocumentsTarget*>(&::google::firestore::v1::_Target_DocumentsTarget_default_instance_);
}
inline ::google::firestore::v1::Target_DocumentsTarget* Target::mutable_documents() {
  if (!has_documents()) {
    clear_target_type();
    set_has_documents();
    target_type_.documents_ = CreateMaybeMessage< ::google::firestore::v1::Target_DocumentsTarget >(
        GetArenaNoVirtual());
  }
  // @@protoc_insertion_point(field_mutable:firestore.client.Target.documents)
  return target_type_.documents_;
}

inline bool Target::has_target_type() const {
  return target_type_case() != TARGET_TYPE_NOT_SET;
}
inline void Target::clear_has_target_type() {
  _oneof_case_[0] = TARGET_TYPE_NOT_SET;
}
inline Target::TargetTypeCase Target::target_type_case() const {
  return Target::TargetTypeCase(_oneof_case_[0]);
}
// -------------------------------------------------------------------

// TargetGlobal

// int32 highest_target_id = 1;
inline void TargetGlobal::clear_highest_target_id() {
  highest_target_id_ = 0;
}
inline ::PROTOBUF_NAMESPACE_ID::int32 TargetGlobal::highest_target_id() const {
  // @@protoc_insertion_point(field_get:firestore.client.TargetGlobal.highest_target_id)
  return highest_target_id_;
}
inline void TargetGlobal::set_highest_target_id(::PROTOBUF_NAMESPACE_ID::int32 value) {
  
  highest_target_id_ = value;
  // @@protoc_insertion_point(field_set:firestore.client.TargetGlobal.highest_target_id)
}

// int64 highest_listen_sequence_number = 2;
inline void TargetGlobal::clear_highest_listen_sequence_number() {
  highest_listen_sequence_number_ = PROTOBUF_LONGLONG(0);
}
inline ::PROTOBUF_NAMESPACE_ID::int64 TargetGlobal::highest_listen_sequence_number() const {
  // @@protoc_insertion_point(field_get:firestore.client.TargetGlobal.highest_listen_sequence_number)
  return highest_listen_sequence_number_;
}
inline void TargetGlobal::set_highest_listen_sequence_number(::PROTOBUF_NAMESPACE_ID::int64 value) {
  
  highest_listen_sequence_number_ = value;
  // @@protoc_insertion_point(field_set:firestore.client.TargetGlobal.highest_listen_sequence_number)
}

// .google.protobuf.Timestamp last_remote_snapshot_version = 3;
inline bool TargetGlobal::has_last_remote_snapshot_version() const {
  return this != internal_default_instance() && last_remote_snapshot_version_ != nullptr;
}
inline const PROTOBUF_NAMESPACE_ID::Timestamp& TargetGlobal::last_remote_snapshot_version() const {
  const PROTOBUF_NAMESPACE_ID::Timestamp* p = last_remote_snapshot_version_;
  // @@protoc_insertion_point(field_get:firestore.client.TargetGlobal.last_remote_snapshot_version)
  return p != nullptr ? *p : *reinterpret_cast<const PROTOBUF_NAMESPACE_ID::Timestamp*>(
      &PROTOBUF_NAMESPACE_ID::_Timestamp_default_instance_);
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* TargetGlobal::release_last_remote_snapshot_version() {
  // @@protoc_insertion_point(field_release:firestore.client.TargetGlobal.last_remote_snapshot_version)
  
  PROTOBUF_NAMESPACE_ID::Timestamp* temp = last_remote_snapshot_version_;
  last_remote_snapshot_version_ = nullptr;
  return temp;
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* TargetGlobal::mutable_last_remote_snapshot_version() {
  
  if (last_remote_snapshot_version_ == nullptr) {
    auto* p = CreateMaybeMessage<PROTOBUF_NAMESPACE_ID::Timestamp>(GetArenaNoVirtual());
    last_remote_snapshot_version_ = p;
  }
  // @@protoc_insertion_point(field_mutable:firestore.client.TargetGlobal.last_remote_snapshot_version)
  return last_remote_snapshot_version_;
}
inline void TargetGlobal::set_allocated_last_remote_snapshot_version(PROTOBUF_NAMESPACE_ID::Timestamp* last_remote_snapshot_version) {
  ::PROTOBUF_NAMESPACE_ID::Arena* message_arena = GetArenaNoVirtual();
  if (message_arena == nullptr) {
    delete reinterpret_cast< ::PROTOBUF_NAMESPACE_ID::MessageLite*>(last_remote_snapshot_version_);
  }
  if (last_remote_snapshot_version) {
    ::PROTOBUF_NAMESPACE_ID::Arena* submessage_arena =
      reinterpret_cast<::PROTOBUF_NAMESPACE_ID::MessageLite*>(last_remote_snapshot_version)->GetArena();
    if (message_arena != submessage_arena) {
      last_remote_snapshot_version = ::PROTOBUF_NAMESPACE_ID::internal::GetOwnedMessage(
          message_arena, last_remote_snapshot_version, submessage_arena);
    }
    
  } else {
    
  }
  last_remote_snapshot_version_ = last_remote_snapshot_version;
  // @@protoc_insertion_point(field_set_allocated:firestore.client.TargetGlobal.last_remote_snapshot_version)
}

// int32 target_count = 4;
inline void TargetGlobal::clear_target_count() {
  target_count_ = 0;
}
inline ::PROTOBUF_NAMESPACE_ID::int32 TargetGlobal::target_count() const {
  // @@protoc_insertion_point(field_get:firestore.client.TargetGlobal.target_count)
  return target_count_;
}
inline void TargetGlobal::set_target_count(::PROTOBUF_NAMESPACE_ID::int32 value) {
  
  target_count_ = value;
  // @@protoc_insertion_point(field_set:firestore.client.TargetGlobal.target_count)
}

#ifdef __GNUC__
  #pragma GCC diagnostic pop
#endif  // __GNUC__
// -------------------------------------------------------------------


// @@protoc_insertion_point(namespace_scope)

}  // namespace client
}  // namespace firestore

// @@protoc_insertion_point(global_scope)

#include <google/protobuf/port_undef.inc>
#endif  // GOOGLE_PROTOBUF_INCLUDED_GOOGLE_PROTOBUF_INCLUDED_firestore_2flocal_2ftarget_2eproto
