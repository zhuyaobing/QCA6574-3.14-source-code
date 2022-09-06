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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdint.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>
#include <linux/if_ether.h>
#include <linux/if.h>
#include <errno.h>
#include <inttypes.h>
#include "dsrc_util.h"
#include "dsrc_sock.h"
#include "crc.h"   /* crc16 is computed on the payload */

#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KNRM  "\x1B[0m"

int rx_error_count = 0;
int rx_count = 0;

/* last sequence number recieved from the tx */
uint32_t rx_seq_num;
/* last timestamp received from the tx */
uint64_t rx_timestamp;

#define PAYLOAD_BUFFER_SIZE 1500
uint8_t payload_contents[PAYLOAD_BUFFER_SIZE];
uint16_t payload_contents_len = 0;

/*******************************************************************************
 * Usage message
 ******************************************************************************/
static
void dsrc_rx_usage(void)
{
    printf("Usage: dsrc_rx [-i <interface>] [-d] [-f <output file>\n");
    printf("Defaults: interface wlanocb0, no dump\n");
    printf("-d : dump raw packet\n");
    printf("-i <interface> : interface name as found in listing by ifconfig\n");
    printf("-f : output file\n");
    printf("-e : expect to receive 802.3 frames. If not present expect to receive 802.11 frames.\n");
}

/*******************************************************************************
 * break the command arguments in to params.
 *
 * @param argc
 * @param argv
 * @param interface
 * @param dump_opt
 *
 * @return int 0 on success; -1 on error
 ******************************************************************************/
static
int dsrc_rx_getopts(int argc, char *argv[],
                    char **interface, uint8_t *dump_opt, char **output_file,
                    uint8_t *eth_mode)
{
    int c;
    int rc = 0;

    /* defaults */
    *interface = "wlanocb0";
    *dump_opt  = 0;
    *output_file = NULL;
    *eth_mode = 0;

    while ((c = getopt(argc, argv, "i:dhf:e?")) != -1) {
        switch(c) {
        case 'i':
            *interface = optarg;
            break;
        case 'd':
            *dump_opt = 1;
            break;
        case 'f':
            *output_file = optarg;
            break;
        case 'e':
            *eth_mode = 1;
            break;
        case '?':
        case 'h':
        default:
            rc = -1;
            dsrc_rx_usage();
            goto bail;
        }
    }
  bail:
    return rc;
}

void print_rx_status(void) {
    printf("<%" PRIu64 "> Seq: %d, timestamp: %" PRIu64 ", %s%d errors%s out of %d packets\n",
           timestamp_now(),
           rx_seq_num,
           rx_timestamp,
           rx_error_count == 0 ? KGRN : KRED,
           rx_error_count,
           KNRM,
           rx_count);
    printf("\n\n");
}

/*******************************************************************************
 * Verify the snap header is WSMP ether type
 *
 * @param llc_snap
 *
 * @return bool : true if wsmp ether type
 ******************************************************************************/
static
bool llc_snap_is_wsmp(const llc_snap_hdr_t *llc_snap)
{
    printf("LLC SNAP: DSAP: %02x, SSAP: %02x, Control: %02x, "
           "OUI: %02x %02x %02x, Type: %04x",
           llc_snap->dsap, llc_snap->ssap, llc_snap->cntl,
           llc_snap->org_code[0], llc_snap->org_code[1],
           llc_snap->org_code[2], ntohs(llc_snap->ether_type));

    if (ntohs(llc_snap->ether_type) != LOCAL_ETH_P_WSMP ||
        llc_snap->dsap != 0xAA || llc_snap->ssap != 0xAA ||
        llc_snap->cntl != 0x03) {
        return false;
    }

    return true;
}

static
void signal_handler(int sig_num)
{

    if(rx_error_count == 0) {
        printf("********** %sPASS%s **********\n", KGRN, KNRM);
    }
    else {
        printf("********** %sFAIL%s **********\n", KRED, KNRM);
    }
    print_rx_status();
    exit(sig_num);
}

/*******************************************************************************
 * Verify the wsmp payload matches the one sent by dsrc_tx application.
 *        4                    2
 *    ,--------+------------+-----,
 *    |seq_num |  payload   |crc16|
 *    `--------+------------+-----`
 * @param pkt
 * @return int
 ******************************************************************************/
static int verify_wsmp_packet(uint8_t *pkt)
{
    uint8_t *payload;
    uint16_t payload_len;
    uint8_t rate;
    uint8_t chan;
    uint8_t pwr;

    rx_seq_num = 0;
    rx_timestamp = 0;
    payload_contents_len = 0;

    if (pkt == NULL) {
        printf("Invalid pointer to WSMP packet\n");
        return -1;
    }

    /* extract the wsmp data payload in addition to the rate, channel
       and power info */
    dsrc_decode_wsmp_packet(pkt, &payload, &payload_len, &rate, &chan, &pwr);

    /* verify the checksum on the payload */
    if (CRC_16_L_OK != crc_16_l_calc(payload, payload_len)) {
        printf("WSMP payload mismatch!\n");
        return -1;
    }

    /* valid payload contain a 4 byte sequence number */
    memcpy(&rx_seq_num, payload, SEQ_NUM_LEN);
    memcpy(&rx_timestamp, payload + SEQ_NUM_LEN, TIMESTAMP_LEN);
    payload_contents_len = payload_len - SEQ_NUM_LEN - TIMESTAMP_LEN - 2;
    memcpy(payload_contents, payload + SEQ_NUM_LEN + TIMESTAMP_LEN,
           payload_contents_len);

    return 0;
}


/*******************************************************************************
 * parse the 802.3 headers from the packets,
 * print the contents of the headers, parse the payload, and verify
 * the contents of the payload match what was expected.
 *
 * @param pkt : 802.3 pkt
 *
 * @return bool : true on success, false on bad frame
 ******************************************************************************/
static
bool dsrc_rx_verify_frame(uint8_t *pkt, uint8_t eth_mode)
{
    if (!eth_mode)
    {
        ieee80211_epd_hdr_t *epd_hdr;

        print_wifi_qos_header((ieee80211_qos_hdr_t *)pkt);
        pkt += sizeof(ieee80211_qos_hdr_t);
        epd_hdr = (ieee80211_epd_hdr_t *)pkt;
        pkt += sizeof(ieee80211_epd_hdr_t);
        print_epd_header(epd_hdr);

        if (ntohs(epd_hdr->ethertype) != LOCAL_ETH_P_WSMP) {
            printf("Not a WSMP packet\n");
            goto print_error;
        }
    }
    else
    {
        eth_hdr_t *eh;

        /* The first header is the ethernet header. */
        eh = (eth_hdr_t *)pkt;
        print_eth_header(eh);
        pkt += sizeof(eth_hdr_t);

        /* if the ether type is less than 0x600, that indicates that the
           ethernet header is followed immediatedly by the LLC SNAP header. */
        if (ntohs(eh->ether_type) < 0x600) {
            llc_snap_hdr_t *llc_snap = (llc_snap_hdr_t*) pkt;
            pkt += sizeof(llc_snap_hdr_t);

            if (!llc_snap_is_wsmp(llc_snap)) {
                printf("Not a WSMP packet\n");
                goto print_error;
            }
        } else if (ntohs(eh->ether_type) != LOCAL_ETH_P_WSMP) {
            printf("Not a WSMP packet\n");
            goto print_error;
        }
    }

    /* Now we have the WSMP packet. */
    if (verify_wsmp_packet(pkt)) {
        printf("WSMP packet verification failed!\n");
        goto print_error;
    } else {
        printf("WSMP packet verification successful!\n");
    }

    return true;

  print_error:
    printf("%s Failed\n", KRED);
    printf("%s", KNRM);
    return false;
}

int main(int argc, char *argv[])
{
    int raw_socket = -1;   /* invalid socket */
    struct sockaddr_ll sockaddr;
    int bytes_recd;
    uint8_t packet_buffer[ETH_FRAME_LEN];
    int rc = 0;
    char *interface;
    uint8_t dump_opt = 0;
    int output_fd = -1;
    char *output_file = 0;
    uint8_t eth_mode = 0;

    signal(SIGINT, signal_handler);

    rc = dsrc_rx_getopts(argc, argv, &interface, &dump_opt, &output_file,
                         &eth_mode);
    if (rc < 0) {
        goto exit;
    }

    if (output_file) {
        if (strcmp(output_file, "stdout") == 0)
            output_fd = STDOUT_FILENO;
        else if (strcmp(output_file, "stderr") == 0)
            output_fd = STDERR_FILENO;
        else {
            output_fd = open(output_file, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
            if (output_fd == -1) {
                printf("Error opening the output file.\n");
                goto exit;
            }
        }
    }

    /* Open a raw socket */
    rc = dsrc_socket_open(interface, &raw_socket, &sockaddr);
    if (rc < 0) {
        switch (-rc) {
        case EAFNOSUPPORT:
            printf("Error getting interface index\n");
            break;
        case EACCES:
            printf("Error getting source MAC address\n");
            break;
        case 1:
        default:
            perror("socket()");
            printf ("Need sudo?\n");
        }
        goto exit;
    }

    /* Bind to the socket */
    rc = bind(raw_socket,
              (struct sockaddr *)&sockaddr,
              sizeof(struct sockaddr_ll));
    if (rc < 0) {
        printf("Error binding to socket!\n");
        rc = -1;
        goto exit;
    }

    printf("Successfully bound to interface: %s, "
           "MAC address = %02x:%02x:%02x:%02x:%02x:%02x\n",
           interface, sockaddr.sll_addr[0], sockaddr.sll_addr[1],
           sockaddr.sll_addr[2], sockaddr.sll_addr[3], sockaddr.sll_addr[4],
           sockaddr.sll_addr[5]);

    memset(packet_buffer, 0, sizeof(packet_buffer));

    /* Listen for incoming packets */
    while (1) {
        struct dsrc_ocb_rx_stats_hdr *rx_stats;
        uint8_t* rx_frame;
        ssize_t  rx_frame_len;

        bytes_recd = dsrc_socket_recv_eth_frame_and_stats(
            raw_socket, packet_buffer, sizeof(packet_buffer), 0,
            &rx_stats, &rx_frame, &rx_frame_len);

        if (bytes_recd < 0) {
            rc = -1;
            goto exit;
        }

        if (dump_opt) {
            print_buffer(packet_buffer, bytes_recd);
        }

        if (0 != rx_stats) {
            print_rx_stats(rx_stats);
        }

        if(!dsrc_rx_verify_frame(rx_frame, eth_mode)) {
            rx_error_count++;
        } else {
            if (output_fd != -1) {
                rc = write(output_fd, payload_contents, payload_contents_len);
                if (rc < 0) {
                    printf("Error writing to output!\n");
                    rc = -1;
                    goto exit;
                }
            }
        }
        rx_count++;

        print_rx_status();
    }

exit:
    if (output_fd != -1)
        close(output_fd);
    (void)dsrc_socket_closeif(&raw_socket);
    return rc;
}
