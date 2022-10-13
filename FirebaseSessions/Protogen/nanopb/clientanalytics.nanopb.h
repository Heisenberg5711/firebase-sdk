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

/* Automatically generated nanopb header */
/* Generated by nanopb-0.3.9.8 */

#ifndef PB_CLIENTANALYTICS_NANOPB_H_INCLUDED
#define PB_CLIENTANALYTICS_NANOPB_H_INCLUDED
#include <nanopb/pb.h>

/* @@protoc_insertion_point(includes) */
#if PB_PROTO_HEADER_VERSION != 30
#error Regenerate this file with the current version of nanopb generator.
#endif


/* Enum definitions */
typedef enum _NetworkConnectionInfo_NetworkType {
    NetworkConnectionInfo_NetworkType_NONE = -1,
    NetworkConnectionInfo_NetworkType_MOBILE = 0,
    NetworkConnectionInfo_NetworkType_WIFI = 1,
    NetworkConnectionInfo_NetworkType_MOBILE_MMS = 2,
    NetworkConnectionInfo_NetworkType_MOBILE_SUPL = 3,
    NetworkConnectionInfo_NetworkType_MOBILE_DUN = 4,
    NetworkConnectionInfo_NetworkType_MOBILE_HIPRI = 5,
    NetworkConnectionInfo_NetworkType_WIMAX = 6,
    NetworkConnectionInfo_NetworkType_BLUETOOTH = 7,
    NetworkConnectionInfo_NetworkType_DUMMY = 8,
    NetworkConnectionInfo_NetworkType_ETHERNET = 9,
    NetworkConnectionInfo_NetworkType_MOBILE_FOTA = 10,
    NetworkConnectionInfo_NetworkType_MOBILE_IMS = 11,
    NetworkConnectionInfo_NetworkType_MOBILE_CBS = 12,
    NetworkConnectionInfo_NetworkType_WIFI_P2P = 13,
    NetworkConnectionInfo_NetworkType_MOBILE_IA = 14,
    NetworkConnectionInfo_NetworkType_MOBILE_EMERGENCY = 15,
    NetworkConnectionInfo_NetworkType_PROXY = 16,
    NetworkConnectionInfo_NetworkType_VPN = 17
} NetworkConnectionInfo_NetworkType;
#define _NetworkConnectionInfo_NetworkType_MIN NetworkConnectionInfo_NetworkType_NONE
#define _NetworkConnectionInfo_NetworkType_MAX NetworkConnectionInfo_NetworkType_VPN
#define _NetworkConnectionInfo_NetworkType_ARRAYSIZE ((NetworkConnectionInfo_NetworkType)(NetworkConnectionInfo_NetworkType_VPN+1))

typedef enum _NetworkConnectionInfo_MobileSubtype {
    NetworkConnectionInfo_MobileSubtype_UNKNOWN_MOBILE_SUBTYPE = 0,
    NetworkConnectionInfo_MobileSubtype_GPRS = 1,
    NetworkConnectionInfo_MobileSubtype_EDGE = 2,
    NetworkConnectionInfo_MobileSubtype_UMTS = 3,
    NetworkConnectionInfo_MobileSubtype_CDMA = 4,
    NetworkConnectionInfo_MobileSubtype_EVDO_0 = 5,
    NetworkConnectionInfo_MobileSubtype_EVDO_A = 6,
    NetworkConnectionInfo_MobileSubtype_RTT = 7,
    NetworkConnectionInfo_MobileSubtype_HSDPA = 8,
    NetworkConnectionInfo_MobileSubtype_HSUPA = 9,
    NetworkConnectionInfo_MobileSubtype_HSPA = 10,
    NetworkConnectionInfo_MobileSubtype_IDEN = 11,
    NetworkConnectionInfo_MobileSubtype_EVDO_B = 12,
    NetworkConnectionInfo_MobileSubtype_LTE = 13,
    NetworkConnectionInfo_MobileSubtype_EHRPD = 14,
    NetworkConnectionInfo_MobileSubtype_HSPAP = 15,
    NetworkConnectionInfo_MobileSubtype_GSM = 16,
    NetworkConnectionInfo_MobileSubtype_TD_SCDMA = 17,
    NetworkConnectionInfo_MobileSubtype_IWLAN = 18,
    NetworkConnectionInfo_MobileSubtype_LTE_CA = 19,
    NetworkConnectionInfo_MobileSubtype_COMBINED = 100
} NetworkConnectionInfo_MobileSubtype;
#define _NetworkConnectionInfo_MobileSubtype_MIN NetworkConnectionInfo_MobileSubtype_UNKNOWN_MOBILE_SUBTYPE
#define _NetworkConnectionInfo_MobileSubtype_MAX NetworkConnectionInfo_MobileSubtype_COMBINED
#define _NetworkConnectionInfo_MobileSubtype_ARRAYSIZE ((NetworkConnectionInfo_MobileSubtype)(NetworkConnectionInfo_MobileSubtype_COMBINED+1))

/* Struct definitions */
typedef struct _NetworkConnectionInfo {
    bool has_network_type;
    NetworkConnectionInfo_NetworkType network_type;
    bool has_mobile_subtype;
    NetworkConnectionInfo_MobileSubtype mobile_subtype;
/* @@protoc_insertion_point(struct:NetworkConnectionInfo) */
} NetworkConnectionInfo;

/* Default values for struct fields */
extern const NetworkConnectionInfo_NetworkType NetworkConnectionInfo_network_type_default;
extern const NetworkConnectionInfo_MobileSubtype NetworkConnectionInfo_mobile_subtype_default;

/* Initializer values for message structs */
#define NetworkConnectionInfo_init_default       {false, NetworkConnectionInfo_NetworkType_NONE, false, NetworkConnectionInfo_MobileSubtype_UNKNOWN_MOBILE_SUBTYPE}
#define NetworkConnectionInfo_init_zero          {false, _NetworkConnectionInfo_NetworkType_MIN, false, _NetworkConnectionInfo_MobileSubtype_MIN}

/* Field tags (for use in manual encoding/decoding) */
#define NetworkConnectionInfo_network_type_tag   1
#define NetworkConnectionInfo_mobile_subtype_tag 2

/* Struct field encoding specification for nanopb */
extern const pb_field_t NetworkConnectionInfo_fields[3];

/* Maximum encoded size of messages (where known) */
#define NetworkConnectionInfo_size               13

/* Message IDs (where set with "msgid" option) */
#ifdef PB_MSGID

#define CLIENTANALYTICS_MESSAGES \


#endif

/* @@protoc_insertion_point(eof) */

#endif
