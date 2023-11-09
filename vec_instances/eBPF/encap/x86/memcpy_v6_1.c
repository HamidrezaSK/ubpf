#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <linux/bpf.h>
#include <linux/in.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <string.h>
#include <netinet/ether.h>

#define NUM_PCKTS 1

#ifndef IPIP_V6_PREFIX1
#define IPIP_V6_PREFIX1 1
#endif

#ifndef IPIP_V6_PREFIX2
#define IPIP_V6_PREFIX2 0
#endif

#ifndef IPIP_V6_PREFIX3
#define IPIP_V6_PREFIX3 0
#endif

// default tos/tclass value
#ifndef DEFAULT_TOS
#define DEFAULT_TOS 0
#endif

#ifndef DEFAULT_TTL
#define DEFAULT_TTL 64
#endif

#define BE_ETH_P_IP 8
#define BE_ETH_P_IPV6 56710

typedef __signed__ char __s8;
typedef unsigned char __u8;

typedef __signed__ short __s16;
typedef unsigned short __u16;

typedef __signed__ int __s32;
typedef unsigned int __u32;


struct ctl_value {
  union {
    __u64 value;
    __u32 ifindex;
    __u8 mac[6];
  };
};

struct flow_key {
  union {
    __be32 src;
    __be32 srcv6[4];
  };
  union {
    __be32 dst;
    __be32 dstv6[4];
  };
  union {
    __u32 ports;
    __u16 port16[2];
  };
  __u8 proto;
};
// client's packet metadata
struct packet_description {
  struct flow_key flow;
  __u32 real_index;
  __u8 flags;
  // dscp / ToS value in client's packet
  __u8 tos;
};

struct real_definition {
  union {
    __be32 dst;
    __be32 dstv6[4];
  };
  __u8 flags;
};

struct ctl_value cval = {
    .mac = {'a','b','c','d','e','f'}
};



struct packet_description pckt = {
    .flow = {
    .srcv6 = {2917007612, 16842442, 0, 33554432},
    .port16 = {223,443}
    },
    .tos =  2,
};

struct real_definition dst = {
    .dstv6 = {2917007612, 16842442, 0, 33554432},
};

struct real_definition src = {
    .dstv6 = {2917007612, 16842442, 0, 58744},
};

__attribute__((__always_inline__)) static inline void create_v6_hdr(
    struct ipv6hdr* ip6h,
    __u8 tc,
    __u32* saddr,
    __u32* daddr,
    __u16 payload_len,
    __u8 proto) {
  ip6h->version = 6;

  ip6h->priority = DEFAULT_TOS;

  ip6h->nexthdr = proto;
  ip6h->payload_len = bpf_htons(payload_len);
  ip6h->hop_limit = DEFAULT_TTL;
  memcpy(ip6h->saddr.s6_addr32, saddr, 16);
  memcpy(ip6h->daddr.s6_addr32, daddr, 16);
}


int xdp_load_balancer(void *xdp, size_t xdp_len){
  // void** packets = (void**)xdp;
    void* data;
    void* data_end;
  	struct ipv6hdr* ip6h;
  	struct ethhdr* new_eth;
	int action = XDP_ABORTED;

	__u16 payload_len;
	__u8 proto;

  	int i;
  	#pragma unroll
  	for(i = 0; i < NUM_PCKTS; i++){ 
        data = xdp;
        data_end = xdp + xdp_len/NUM_PCKTS;
        new_eth = data;
        ip6h = data + sizeof(struct ethhdr);
        if (new_eth + 1 > data_end || ip6h + 1 > data_end) 
        goto out;

        memcpy(new_eth->h_dest, cval.mac, 6);

        new_eth->h_proto = BE_ETH_P_IPV6;


        proto = IPPROTO_IPV6;
        payload_len = data_end - data;

        create_v6_hdr(ip6h, pckt.tos,  src.dstv6, dst.dstv6, payload_len, proto);
        }
        if(ip6h->saddr.s6_addr32[0] == src.dstv6[0]){
            action = XDP_PASS;
            goto out;
    }
	action = XDP_DROP;

out:
	return action;
}


static void*
readfile(const char* path, size_t maxlen, size_t* len)
{
    FILE* file;

    file = fopen(path, "r");


    char* data = calloc(maxlen, 1);
    size_t offset = 0;
    size_t rv;
    while ((rv = fread(data + offset, 1, maxlen - offset, file)) > 0) {
        offset += rv;
    }

    fclose(file);
    if (len) {
        *len = offset;
    }
    return (void*)data;
}


int main(int argc, char *argv[])
{
    size_t mem_len = 0;
    char *path = argv[1];

    void* mem = readfile(path, 1024 * 1024, &mem_len);
    int i;
    bool ret;
    // size_t packet_len[NUM_PCKTS];
    // for(i =0;i<NUM_PCKTS;i++)
    //   packet_len[i] = mem_len/8;

    ret = xdp_load_balancer(mem, mem_len);

    printf("ret: %d\n",ret);

    return 0;
}

