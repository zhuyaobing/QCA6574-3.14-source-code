/*
 * Copyright (c) 2014-2016, The Linux Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of The Linux Foundation nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * This file was originally distributed by Qualcomm Atheros, Inc.
 * under proprietary terms before Copyright ownership was assigned
 * to the Linux Foundation.
 */

#ifndef _DSRC_UTIL_H_
#define _DSRC_UTIL_H_


#ifdef __cplusplus
extern "C" {
#endif


#include <stddef.h>
#include <sys/socket.h>
#include <linux/if_ether.h>
#include <linux/if.h>
#include <netpacket/packet.h>
#include <sys/time.h>
#include <arpa/inet.h>

#include "dsrc_ocb.h"


#define NUM_TEST_PACKETS            100
#define NUM_TEST_RECV_TRIES         5
#define NUM_INIT_RETRIES            10
#define NUM_INIT_RECV_TRIES         10
#define STR_INIT_REQ                "QCOMDSRCINITREQ"
#define STR_INIT_REQ_LEN            15
#define STR_INIT_RESP               "QCOMDSRCINITRESP"
#define STR_INIT_RESP_LEN           16
#define STR_CHANGE_CHAN_REQ         "REQCHAN "
#define STR_CHANGE_CHAN_REQ_LEN     8
#define STR_CHANGE_CHAN_RESP        "RESPCHAN "
#define STR_CHANGE_CHAN_RESP_LEN    9
#define PAYLOAD_LEN                 16
#define SEQ_NUM_LEN                 4
#define TIMESTAMP_LEN               8
#define PSID_LEN_MAX                4
#define LOCAL_ETH_P_WSMP            (0x88DC)
#define LOCAL_ETH_P_ETSI            (0x8947)
#define LOCAL_ETH_P_QCOM_TX         (0x8151)
#define LOCAL_ETH_P_QCOM_RX         (0x8152)

#define CHAN_FREQ_TO_NUM(x)         (((x) - 5000) / 5)

#define NUM_CHANNELS                7

#define PACKED __attribute__ ((packed))


typedef enum {
    TX_PKT_INIT_REQ = -2,
    TX_PKT_INIT_RESP = -1,
    TX_PKT_WSMP_ONLY = 0,
    TX_PKT_WSMP_CTRL = 1,
    TX_PKT_CHANGE_CHAN_REQ = 2,
    TX_PKT_CHANGE_CHAN_RESP = 3,
} tx_pkt_e;

typedef enum {
    RX_PKT_INIT_REQ = 0,
    RX_PKT_INIT_RESP,
    RX_PKT_WSMP_ONLY,
    RX_PKT_WSMP_STATS,
    RX_PKT_CHANGE_CHAN_REQ,
    RX_PKT_CHANGE_CHAN_RESP,
    RX_PKT_OTHER,
} rx_pkt_e;

// todo: use the standard linux defines. Shouldn't be redefining packet constants
// that are already defined by the OS.  if_ether.h defines the eth header, if_fddi.h defines llc snap hdr
typedef struct eth_hdr {
    uint8_t  ether_dhost[ETH_ALEN];
    uint8_t  ether_shost[ETH_ALEN];
    uint16_t ether_type;
} PACKED eth_hdr_t;

typedef struct dot3_hdr {
    uint8_t  ether_dhost[ETH_ALEN];
    uint8_t  ether_shost[ETH_ALEN];
    uint16_t length;
} PACKED dot3_hdr_t;

typedef struct llc_snap_hdr {
    uint8_t dsap;
    uint8_t ssap;
    uint8_t cntl;
    uint8_t org_code[3];
    uint16_t ether_type;
} PACKED llc_snap_hdr_t;

// see IEEE 1609.3 annex E
#define WAVE_ELEM_ID_DATA   128
#define WAVE_ELEM_ID_RATE   16
#define WAVE_ELEM_ID_CHAN   15
#define WAVE_ELEM_ID_PWR    4

#define MAX_WAVE_ELEMENTS   4

typedef enum {
    EXT_FIELD_RATE = 0,
    EXT_FIELD_CHAN,
    EXT_FIELD_PWR,
    EXT_FIELD_MAX
} ext_field_e;


// Macro's for unpacking a WSMP message
#define WSMP_EXT_FIELD_SIZE(x)  (sizeof((x)->wave_element_id) + sizeof((x)->length) +(x)->length)
// determine size of PSID based on the first octet of the PSID
// 0xxx        1
// 10xx        2
// 110x        3
// 1110        4
#define WSMP_PSID_FIELD_SIZE(val) (((val) & 0xe0) == 0xe0 ? 4 : ((val) & 0xc0) == 0xc0 ? 3 : ((val) & 0x80) == 0x80 ? 2 : 1 )
#define WSMP_EXT_FIELD_START(pkt) ( (pkt) + sizeof(uint8_t) +  WSMP_PSID_FIELD_SIZE(*(pkt + offsetof(struct wsmp_hdr,psid))))


// IEEE 1609.3, 8.3.4
// extension fields are optional, and intended for the recipient
// Valid fields are data-rate, channel, and tx-power, and are intended to
// be specified on a per-packet basis.  These fields are optional and not
// required but may be sent, and are valid for WSA and WSMP headers
typedef struct wsmp_ext_field {
    uint8_t wave_element_id;
    uint8_t length;             // length of the data field
    union {
        uint8_t data[0];        // generic data, of length "length"
        uint8_t data_rate;      // these are predefined in Annex H
        uint8_t tx_power;
        uint8_t channel;
    } data ;
} PACKED wsmp_ext_field_t;

typedef struct wave_element_field {
    uint8_t wave_element_id;
    uint16_t data_len;
    uint8_t  data[0];               //variable length data field
} PACKED wave_element_field_t;

// IEEE 1609.3, 8.3.1.
// WSMP header consists of version, PSID, optional extension fields, a wave element ID
// and length. Following length is the data itself, which is not part of the header
// PSID length is determined via the value of the PSID itself, see section 8.1.3 of 1609.3
// Length is determined by 4 MSB's of the first value
// Bits     PSID length (bytes)
// 0xxx        1
// 10xx        2
// 110x        3
// 1110        4
// 1111        reserved
//
// TODO:  fix this, this header is not as defined in 1609.3
typedef struct wsmp_hdr {
    uint8_t version;
    uint8_t psid[PSID_LEN_MAX];
} PACKED wsmp_hdr_t;

#define GET_OCB_SCHED_VERSION 1

typedef struct ocb_get_sched {
    uint32_t length;       /* Length of structure passed in and data passed out
                              including this length field */
    uint32_t version;      /* Version of this driver ocb_get_sched structure */
    uint32_t num_channels; /* Number of channels in schedule */
    struct dsrc_ocb_channel channels[DSRC_OCB_CHANNEL_MAX]; /* Schedule */
    // Add items here and increase version number as appropriate
} PACKED ocb_get_sched_t;

#define PACKED __attribute__ ((packed))
#define IEEE80211_ADDR_LEN 6

/*
 * IEEE 802.11 section 8.2.4.1, Frame Control Field
 */
#define IEEE80211_FCTL_VER_MASK                 0x0003
#define IEEE80211_FCTL_TYPE_MASK                0x000C
#define IEEE80211_FCTL_SUBTYPE_MASK             0x00F0

#define IEEE80211_FCTL_VERSION_0                0x0000

#define IEEE80211_FCTL_TYPE_MANAGEMENT          0x0000
#define IEEE80211_FCTL_TYPE_CONTROL             0x0004
#define IEEE80211_FCTL_TYPE_DATA                0x0008

/* Management subtypes */
#define IEEE80211_FCTL_SUBTYPE_ACTION           0x00D0
#define IEEE80211_FCTL_SUBTYPE_ACTION_NO_ACK    0x00E0

/* Data subtypes */
#define IEEE80211_FCTL_SUBTYPE_QOS_DATA         0x0080

/*
 * IEEE 802.11 section 8.2.4.5, QoS Control Field
 */
#define IEEE80211_QOS_CTL_ACK_POLICY_NORMAL             0x0000
#define IEEE80211_QOS_CTL_ACK_POLICY_NO_ACK             0x0020
#define IEEE80211_QOS_CTL_ACK_POLICY_NO_EXPLICIT_ACK    0x0040
#define IEEE80211_QOS_CTL_ACK_POLICY_BLOCK_ACK          0x0060
#define IEEE80211_QOS_CTL_ACK_POLICY_MASK               0x0003
#define IEEE80211_QOS_CTL_ACK_POLICY_SHIFT              5
#define IEEE80211_QOS_CTL_ACK_POLICY_SET(val) \
    ((val & IEEE80211_QOS_CTL_ACK_POLICY_MASK) << \
      IEEE80211_QOS_CTL_ACK_POLICY_SHIFT)

typedef struct ieee80211_hdr {
    uint16_t frame_control;
    uint16_t duration;
    uint8_t address_1[6];
    uint8_t address_2[6];
    uint8_t address_3[6];
    uint16_t sequence;
} PACKED ieee80211_hdr_t;

typedef struct ieee80211_qos_hdr {
    uint16_t frame_control;
    uint16_t duration;
    uint8_t address_1[IEEE80211_ADDR_LEN];
    uint8_t address_2[IEEE80211_ADDR_LEN];
    uint8_t address_3[IEEE80211_ADDR_LEN];
    uint16_t sequence;
    uint16_t qos;
} PACKED ieee80211_qos_hdr_t;

typedef struct ieee80211_epd_hdr {
    uint16_t ethertype;
} PACKED ieee80211_epd_hdr_t;

/*******************************************************************************
 * Function: dsrc_get_if_index
 * Description: Get interface index
 * Input Parameters:
 *      socket: Socket descriptor
 *      interface: Interface name
 *      if_idx: Pointer to ifreq struct
 * Return Value:
 *      0 on success. Negative value on failure
 * Side Effects: ifreq struct will contain interface index value on success
 ******************************************************************************/
int dsrc_get_if_index(int socket, char *interface, struct ifreq *if_idx);

/*******************************************************************************
 * Function: dsrc_get_if_mac
 * Description: Get MAC address
 * Input Parameters:
 *      socket: Socket descriptor
 *      interface: Interface name
 *      if_mac: Pointer to ifreq struct
 * Return Value:
 *      0 on success. Negative value on failure
 * Side Effects: ifreq struct will contain MAC address on success
 ******************************************************************************/
int dsrc_get_if_mac(int socket, char *interface, struct ifreq *if_mac);

/*******************************************************************************
 * Function: dsrc_set_channel
 * Description: Set the channel
 * Input Parameters:
 *      socket: Socket descriptor
 *      interface: Interface name
 *      channel: Channel Number
 * Return Value:
 *      0 on success. Negative value on failure
 * Side Effects: None
 ******************************************************************************/
int dsrc_set_channel(int socket, char *interface, uint32_t channel);

/*******************************************************************************
 * Function: dsrc_populate_sockaddr
 * Description: Populate the sockaddr struct
 * Input Parameters:
 *      sockaddr: Pointer to sockaddr struct
 *      if_idx: Pointer to interface index struct
 *      if_mac: Pointer to MAC address struct
 * Side Effects: None
 ******************************************************************************/
void dsrc_populate_sockaddr(struct sockaddr_ll *sockaddr,
                            struct ifreq *if_idx,
                            struct ifreq *if_mac);

/*******************************************************************************
 * Function: dsrc_populate_wsmp_tx_ctrl_hdr
 * Description: Populate the WSMP TX Control header
 * Input Parameters:
 *      hdr: Pointer to header
 *      channel: Channel Number
 * Side Effects: WSMP TX control header will get populated with default values
 ******************************************************************************/
void dsrc_populate_wsmp_tx_ctrl_hdr(struct dsrc_ocb_tx_ctrl_hdr *hdr,
                                    uint16_t channel_freq);

/*******************************************************************************
 * Function: dsrc_populate_eth_hdr
 * Description: Populate the Ethernet header
 * Input Parameters:
 *      hdr: Pointer to header
 *      src_addr: Pointer to source MAC address, must not be NULL
 *      dst_addr: Pointer to destination MAC address, use broadcast address if
 *                it is NULL
 *      ether_type: Ethernet type to use in header
 * Side Effects: Ethernet header will get populated
 ******************************************************************************/
void dsrc_populate_eth_hdr(eth_hdr_t *hdr, uint8_t src_addr[],
                           uint8_t dst_addr[], uint16_t ether_type);

/*******************************************************************************
 * Function: dsrc_populate_qos_wifi_hdr
 * Description: Populate the Ethernet header
 * Input Parameters:
 *      hdr: Pointer to header
 *      src_addr: Pointer to source MAC address, must not be NULL
 *      dst_addr: Pointer to destination MAC address, use broadcast address if
 *                it is NULL
 *      tid: Traffic ID
 *      ack_policy: ack policy in 802.11 QoS control
 * Side Effects: Ethernet header will get populated
 ******************************************************************************/
void dsrc_populate_qos_wifi_hdr(ieee80211_qos_hdr_t *hdr, uint8_t src_addr[],
                                uint8_t dst_addr[], uint8_t tid,
                                uint8_t ack_policy);

/*******************************************************************************
 * Function: dsrc_populate_action_wifi_hdr
 * Description: Populate an action Ethernet header
 * Input Parameters:
 *      hdr: Pointer to header
 *      src_addr: Pointer to source MAC address, must not be NULL
 *      dst_addr: Pointer to destination MAC address, use broadcast address if
 *                it is NULL
 * Side Effects: Ethernet header will get populated
 ******************************************************************************/
void dsrc_populate_action_wifi_hdr(ieee80211_hdr_t *hdr, uint8_t src_addr[],
                                   uint8_t dst_addr[]);

/*******************************************************************************
 * Function: dsrc_populate_llc_hdr
 * Description: Populate the Ethernet header
 * Input Parameters:
 *      hdr: Pointer to header
 *      ether_type: Ethernet type to use in header
 * Side Effects: Ethernet header will get populated
 ******************************************************************************/
void dsrc_populate_llc_hdr(llc_snap_hdr_t *hdr, uint16_t ether_type);

/*******************************************************************************
 * Function: dsrc_populate_802dot3_hdr
 * Description: Populate the 802.3 header
 * Input Parameters:
 *      hdr: Pointer to header
 *      if_mac: Pointer to MAC address struct
 *      dst_addr: Pointer to destination MAC address, use broadcast address if
 *                it is NULL
 *      length: Length of the packet
 * Side Effects: 802.3 header will get populated
 ******************************************************************************/
void dsrc_populate_802dot3_hdr(dot3_hdr_t *hdr, struct ifreq *if_mac,
                               uint8_t dst_addr[], uint16_t length);

/*******************************************************************************
 * Function: dsrc_populate_llc_snap_hdr
 * Description: Populate the LLC SNAP header
 * Input Parameters:
 *      hdr: Pointer to header
 *      ether_type: Ethernet type to use in header
 * Side Effects: LLC SNAP header will get populated
 ******************************************************************************/
void dsrc_populate_llc_snap_hdr(llc_snap_hdr_t *hdr, uint16_t ether_type);

/*******************************************************************************
 * Function: dsrc_populate_wsmp_hdr
 * Description: Populate the WSMP header
 * Input Parameters:
 *      hdr: Pointer to header
 * Side Effects: WSMP header will get populated
 ******************************************************************************/
void dsrc_populate_wsmp_hdr(wsmp_hdr_t *hdr);

/*******************************************************************************
 * Function: dsrc_populate_wsmp_data_hdr
 * Description: Populate the WSMP data header
 * Input Parameters:
 *      hdr: Pointer to header
 *      len: Length of WSMP data
 * Side Effects: WSMP data header will get populated
 ******************************************************************************/
void dsrc_populate_wsmp_data_hdr(wave_element_field_t *hdr, uint16_t len);

/*******************************************************************************
 * Function: dsrc_populate_ext_field
 * Description: Populate a WSMP extension field
 * Input Parameters:
 *      ext_field: Pointer to extension field
 *      type: Type of extension field
 *      value: Value of extension field
 * Side Effects: WSMP Extension field will get populated
 ******************************************************************************/
void dsrc_populate_ext_field(wsmp_ext_field_t *ext_field, ext_field_e type,
                             uint8_t value);

/*******************************************************************************
 * Function: dsrc_create_payload
 * Description: Populate the payload
 * Input Parameters:
 *      len: Length of payload
 *      seq: Sequence Number of payload
 * Return Value: Pointer to new payload on success. NULL on failure.
 * Side Effects: Creates payload of specified length with sequence number
 *      repeated through the payload
 ******************************************************************************/
uint8_t *dsrc_create_payload(uint16_t len, uint8_t seq);

/*******************************************************************************
 * Function: dsrc_create_init_req_payload
 * Description: Populate the init request payload
 * Return Value: Pointer to new payload on success. NULL on failure.
 * Side Effects: Creates the init request payload containing the special string
 ******************************************************************************/
uint8_t *dsrc_create_init_req_payload(void);

/*******************************************************************************
 * Function: dsrc_create_init_resp_payload
 * Description: Populate the init request payload
 * Return Value: Pointer to new payload on success. NULL on failure.
 * Side Effects: Creates the init request payload containing the special string
 ******************************************************************************/
uint8_t *dsrc_create_init_resp_payload(void);

/*******************************************************************************
 * Function: dsrc_create_packet
 * Description: Create a complete packet
 * Input Parameters:
 *      pkt_type: Packet type
 *      if_mac: MAC Address struct
 *      len: Length of payload
 *      seq: Sequence number of payload
 *      channel: Channel number
 *      pkt_len: Pointer to total packet length
 *      ext_rate: Rate to be used in WSMP extension field (optional)
 *      ext_chan: Channel to be used in WSMP extension field (optional)
 *      ext_pwr: Power to be used in WSMP extension field (optional)
 * Return Value: Pointer to new packet on success. NULL on failure.
 * Side Effects: Creates a new packet of specified type. pkt_len will contain
 *      actual length of created packet
 ******************************************************************************/
uint8_t *dsrc_create_packet(tx_pkt_e pkt_type, struct ifreq *if_mac,
                            int len, int seq, uint16_t channel,
                            int *pkt_len, uint8_t ext_rate,
                            uint8_t ext_chan, uint8_t ext_pwr);

/*******************************************************************************
 * Function: dsrc_receive_packet
 * Description: Receive a packet
 * Input Parameters:
 *      socket: Socket descriptor
 *      packet_buffer: Pointer to packet buffer
 *      packet_len: Length of packet buffer
 *      if_max: MAC address struct
 * Return Value: Number of bytes received on success. Negative on failure.
 * Side Effects: Receives a pakcet and puts it in packet_buffer
 ******************************************************************************/
int dsrc_receive_packet(int socket, uint8_t *packet_buffer, int packet_len,
                        struct ifreq *if_mac, int timeout);

/*******************************************************************************
 * Function: dsrc_get_packet_type
 * Description: Get the packet type
 * Input Parameters:
 *      packet: Pointer to the packet buffer
 * Return Value: Type of packet
 ******************************************************************************/
rx_pkt_e dsrc_get_packet_type(uint8_t *packet);

/*******************************************************************************
 * Function: dsrc_create_echo_packet
 * Description: Creates an echo packet to return to sender
 *      with identical payload
 * Input Parameters:
 *      packet_in: Pointer to the incoming packet buffer
 *      pkt_in_len: Length of incoming packet
 *      if_mac: MAC address struct
 *      pkt_len: Pointer to length of created packet
 * Return Value: Pointer to new packet on success. NULL on failure.
 * Side Effects: pkt_len will contain length of newly created packet
 ******************************************************************************/
uint8_t *dsrc_create_echo_packet(uint8_t *packet_in, int pkt_in_len,
                                 struct ifreq *if_mac, int *pkt_len);

/*******************************************************************************
 * Function: dsrc_verify_echo_packet
 * Description: Verify a echoed packet
 * Input Parameters:
 *      packet: Pointer to the packet buffer
 *      len: Expected length of payload
 *      seq: Expected sequence number in payload
 * Return Value: 1 on successful verification. 0 on failure.
 ******************************************************************************/
int dsrc_verify_echo_packet(uint8_t *packet, int len, int seq);

/*******************************************************************************
 * Function: dsrc_decode_wsmp_packet
 * Description: Decode a WSMP packet
 * Input Parameters:
 *      wsmp_packet: Pointer to the packet buffer
 *      payload: Pointer to payload buffer
 *      payload_len: Pointer to payload len
 *      rate: Pointer for data rate (optional)
 *      chan: Pointer for channel (optional)
 *      pwr: Pointer for power (optional)
 * Side Effects: payload, payload_len, rate, chan and pwr will get filled in
 *      as necessary.
 ******************************************************************************/
void dsrc_decode_wsmp_packet(uint8_t *wsmp_packet,
                             uint8_t **payload, uint16_t *payload_len,
                             uint8_t *rate, uint8_t *chan, uint8_t *pwr);

/*******************************************************************************
 * Function: print_buffer
 * Description: Print out a buffer in hex
 * Input Parameters:
 *      buffer: buffer to print
 *      buffer_len: number of bytes in buffer
 ******************************************************************************/
extern void print_buffer (uint8_t *buffer, int buffer_len);

/*******************************************************************************
 * return current time stamp in milliseconds
 * @return long long
 ******************************************************************************/
static __inline uint64_t timestamp_now(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec*1000LL + tv.tv_usec/1000;
}

static inline int dsrc_mac_string_to_hex(uint8_t *mac_addr, char *addr_str)
{
    int i;
    char *s, *p= addr_str;

    if ((mac_addr == NULL) || (addr_str == NULL))
        return -1;

    for (i = 0;  i < 6; i++) {
        mac_addr[i] = p ? strtoul(p, &s, 16) : 0;
        if (s != NULL)
            p = (*s) ? (s + 1) : s;
    }

    return 0;
}

/*******************************************************************************
 * Function: convert_mhz_to_chan
 * Description: Convert MHz to Channel Number
 * Input Parameters:
 *      mhz: MHz frequency value
 ******************************************************************************/
int convert_mhz_to_chan(int mhz);

/*******************************************************************************
 * Function: print_eth_header
 * Description: Print out the contents of an 802.3 Ethernet header
 * Input Parameters:
 *      eth: the 802.3 header
 ******************************************************************************/
void print_eth_header(const eth_hdr_t *eth);

/*******************************************************************************
 * Function: print_epd_header
 * Description: Print out the contents of an EPD header
 * Input Parameters:
 *      epd_header: the 802.11 epd header
 ******************************************************************************/
void print_epd_header(const ieee80211_epd_hdr_t *epd_header);

/*******************************************************************************
 * Function: print_rx_stats
 * Description: Print out the contents of an RX Stats Header
 * Input Parameters:
 *      rx_stats: the RX Stats Header
 ******************************************************************************/
void print_rx_stats(const struct dsrc_ocb_rx_stats_hdr* rx_stats);

/*******************************************************************************
 * Function: print_wifi_qos_header
 * Description: Print out the contents of an 802.11 QOS header
 * Input Parameters:
 *      wifi_header: the 802.11 header
 ******************************************************************************/
void print_wifi_qos_header(const ieee80211_qos_hdr_t *wifi_header);

#ifdef __cplusplus
}
#endif

#endif /* _DSRC_UTIL_H_ */
