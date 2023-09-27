#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <bpf/bpf_endian.h>
#include <string.h>

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

// struct IPv6Rule lookups[RULES_NUM] = {
//     {
//         // Rule 1
//         .src_ip.s6_addr32 = {0x20110db7, 0x85b38000, 0x50218a2e, 0x03707334},
//     },
//     {
//         // Rule 2
//         .src_ip.s6_addr32 = {0x20010db8, 0x85a30700, 0x09008a1e, 0x13701234},
//     },
//     {
//         // Rule 3
//         .src_ip.s6_addr32 = {0x26062800, 0x22000001, 0x02481893, 0x25c81946},
//     },
//     {
//         // Rule 4
//         .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x036025de},
//     },
// };

struct IPv6Rule lookups[RULES_NUM] = {
    {
        // Rule 1
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707334},
    },
    {
        // Rule 2
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701234},
    },
    {
        // Rule 3
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x25c81946},
    },
    {
        // Rule 4
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x036025de},
    },
};


static __u32 check_ipv6_rule(const struct IPv6Rule lookup, const struct ip6_hdr ipv6_header)
{
    if((ntohl(ipv6_header.ip6_src.s6_addr32[0]) == lookup.src_ip.s6_addr32[0])
    && (ntohl(ipv6_header.ip6_src.s6_addr32[1]) == lookup.src_ip.s6_addr32[1])
    && (ntohl(ipv6_header.ip6_src.s6_addr32[2]) == lookup.src_ip.s6_addr32[2])
    && (ntohl(ipv6_header.ip6_src.s6_addr32[3]) == lookup.src_ip.s6_addr32[3]))
        return 1;
    return 0;
}



uint64_t is_dst_one_one_one_one(void *opaque) {
    int sum = 0;
    struct ip6_hdr *ipv6_header = (struct ip6_hdr *)(opaque);

    // struct IPv6Rule lookups[RULES_NUM];
    // populate_ipv6_rule(lookups,RULES_NUM);

    
    sum += check_ipv6_rule(lookups[0],*ipv6_header);
    sum += check_ipv6_rule(lookups[1],*ipv6_header);
    sum += check_ipv6_rule(lookups[2],*ipv6_header);
    sum += check_ipv6_rule(lookups[3],*ipv6_header);


    return sum;
}