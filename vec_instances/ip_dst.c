#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <bpf/bpf_endian.h>
#include <string.h>
#define ONE_ONE_ONE_ONE 0x2001
#define RULES_NUM 4

struct IPv6Rule {
    struct in6_addr src_ip;
    struct in6_addr src_ip_wildcard_mask;
    struct in6_addr dst_ip;
    struct in6_addr dst_ip_wildcard_mask;
    __be16 min_src_port;
    __be16 max_src_port;
    __be16 min_dst_port;
    __be16 max_dst_port;
    __u8 protocol;
    _Bool allow;
};

static __u32 check_ipv6_rule(const struct IPv6Rule lookup, const struct ip6_hdr ipv6_header)
{
    if((ntohs(ipv6_header.ip6_src.s6_addr16[0]) == lookup.src_ip.s6_addr16[0])
    && (ntohs(ipv6_header.ip6_src.s6_addr16[1]) == lookup.src_ip.s6_addr16[1])
    && (ntohs(ipv6_header.ip6_src.s6_addr16[2]) == lookup.src_ip.s6_addr16[2])
    && (ntohs(ipv6_header.ip6_src.s6_addr16[3]) == lookup.src_ip.s6_addr16[3]))
        return 1;
    return 0;
}

static void populate_ipv6_rule(struct IPv6Rule val[], size_t size)
{
        uint16_t addressBytes_0[8] = {
        0x2001, 0x0db8, 0x85a3, 0x0000, 0x0000, 0x8a2e, 0x0370, 0x7334
        };
        
        memcpy(val[0].src_ip.s6_addr16,addressBytes_0,sizeof(addressBytes_0));

        uint16_t addressBytes_1[8] = {
        0x2001, 0x0db8, 0x85a3, 0x0000, 0x0000, 0x8a2e, 0x0370, 0x1234
        };
        
        memcpy(val[1].src_ip.s6_addr16,addressBytes_1,sizeof(addressBytes_1));

        uint16_t addressBytes_2[8] = {
        0x2606, 0x2800, 0x220, 0x1, 0x248, 0x1893, 0x25c8, 0x1946
        };
        
        memcpy(val[2].src_ip.s6_addr16,addressBytes_2,sizeof(addressBytes_2));

        uint16_t addressBytes_3[8] = {
        0x2a03, 0x2880, 0xf21a, 0x83, 0xface, 0xb00b, 0x0370, 0x25de
        };
        
        memcpy(val[3].src_ip.s6_addr16,addressBytes_3,sizeof(addressBytes_3));

    return;
}

uint64_t is_dst_one_one_one_one(void *opaque) {
    // struct ipv6_header *ipv6_header = (struct ipv6_header*)opaque;
    struct ip6_hdr *ipv6_header = (struct ip6_hdr *)(opaque);

    struct IPv6Rule lookups[RULES_NUM];
    populate_ipv6_rule(lookups,RULES_NUM);

    for (size_t i = 0; i<RULES_NUM;i++)
    {
        
    }

    // return 0;
    return lookups[0].src_ip.s6_addr16[0];
}