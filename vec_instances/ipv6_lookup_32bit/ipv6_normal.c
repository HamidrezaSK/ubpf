#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <bpf/bpf_endian.h>
#include <string.h>

#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

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

struct IPv6Rule lookups[RULES_NUM] = {
    {
        // Rule 1
        .src_ip.s6_addr32 = {0x20110db7, 0x85b38000, 0x50218a2e, 0x03707334},
    },
    {
        // Rule 2
        .src_ip.s6_addr32 = {0x20010db8, 0x85a30700, 0x09008a1e, 0x13701234},
    },
    {
        // Rule 3
        .src_ip.s6_addr32 = {0x26062800, 0x22000001, 0x02481893, 0x25c81946},
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

// static void populate_ipv6_rule(struct IPv6Rule val[], size_t size)
// {
//         uint16_t addressBytes_0[8] = {
//         0x2011, 0x0db7, 0x85b3, 0x8000, 0x5021, 0x8a2e, 0x0370, 0x7334
//         };
        
//         memcpy(val[0].src_ip.s6_addr16,addressBytes_0,sizeof(addressBytes_0));

//         uint16_t addressBytes_1[8] = {
//         0x2001, 0x0db8, 0x85a3, 0x0700, 0x0900, 0x8a1e, 0x1370, 0x1234
//         };
        
//         memcpy(val[1].src_ip.s6_addr16,addressBytes_1,sizeof(addressBytes_1));

//         uint16_t addressBytes_2[8] = {
//         0x2606, 0x2800, 0x220, 0x1, 0x248, 0x1893, 0x25c8, 0x1946
//         };
        
//         memcpy(val[2].src_ip.s6_addr16,addressBytes_2,sizeof(addressBytes_2));

//         uint16_t addressBytes_3[8] = {
//         0x2a03, 0x2880, 0xf21a, 0x83, 0xface, 0xb00b, 0x0360, 0x25de
//         };
        
//         memcpy(val[3].src_ip.s6_addr16,addressBytes_3,sizeof(addressBytes_3));

//     return;
// }

int main() {

    int fd = open("ipv6_in.mem", O_RDONLY);
    if (fd == -1) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }
    off_t file_size = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    struct ip6_hdr *ipv6_header = mmap(NULL, file_size, PROT_READ, MAP_SHARED, fd, 0);
    if (ipv6_header == MAP_FAILED) {
        perror("Error mapping file into memory");
        close(fd);
        exit(EXIT_FAILURE);
    }
    int sum = 0;
    printf("input packet src ip: %u::%u::%u::%u \n",ipv6_header->ip6_src.s6_addr32[0],ipv6_header->ip6_src.s6_addr32[1],ipv6_header->ip6_src.s6_addr32[2],ipv6_header->ip6_src.s6_addr32[3]);
    printf("input packet src ip ntohl: %u::%u::%u::%u \n",ntohl(ipv6_header->ip6_src.s6_addr32[0]),ntohl(ipv6_header->ip6_src.s6_addr32[1]),ntohl(ipv6_header->ip6_src.s6_addr32[2]),ntohl(ipv6_header->ip6_src.s6_addr32[3]));

    printf("input packet src ip: %hu::%hu::%hu::%hu::%hu::%hu::%hu::%hu \n",ipv6_header->ip6_src.s6_addr16[0],ipv6_header->ip6_src.s6_addr16[1],ipv6_header->ip6_src.s6_addr16[2],ipv6_header->ip6_src.s6_addr16[3],ipv6_header->ip6_src.s6_addr16[4],ipv6_header->ip6_src.s6_addr16[5],ipv6_header->ip6_src.s6_addr16[6],ipv6_header->ip6_src.s6_addr16[7]);
    printf("input packet src ip ntohs: %hu::%hu::%hu::%hu::%hu::%hu::%hu::%hu \n",ntohs(ipv6_header->ip6_src.s6_addr16[0]),ntohs(ipv6_header->ip6_src.s6_addr16[1]),ntohs(ipv6_header->ip6_src.s6_addr16[2]),ntohs(ipv6_header->ip6_src.s6_addr16[3]),ntohs(ipv6_header->ip6_src.s6_addr16[4]),ntohs(ipv6_header->ip6_src.s6_addr16[5]),ntohs(ipv6_header->ip6_src.s6_addr16[6]),ntohs(ipv6_header->ip6_src.s6_addr16[7]));

    // printf("Lookup ip[0]: %u::%u::%u::%u \n",lookups[0].src_ip.s6_addr32[0],lookups[0].src_ip.s6_addr32[1],lookups[0].src_ip.s6_addr32[2],lookups[0].src_ip.s6_addr32[3]);
    // printf("Lookups ip[1]: %u::%u::%u::%u \n",lookups[1].src_ip.s6_addr32[1],lookups[1].src_ip.s6_addr32[1],lookups[1].src_ip.s6_addr32[2],lookups[1].src_ip.s6_addr32[3]);
    // printf("Lookups ip[2]: %u::%u::%u::%u \n",lookups[2].src_ip.s6_addr32[2],lookups[2].src_ip.s6_addr32[1],lookups[2].src_ip.s6_addr32[2],lookups[2].src_ip.s6_addr32[3]);
    printf("Lookups ip[3]: %u::%u::%u::%u \n",lookups[3].src_ip.s6_addr32[0],lookups[3].src_ip.s6_addr32[1],lookups[3].src_ip.s6_addr32[2],lookups[3].src_ip.s6_addr32[3]);
    printf("%d %d\n",0 != 0, 0 != 1);
    for (size_t i = 0; i<RULES_NUM;i++)
        sum += check_ipv6_rule(lookups[i],*ipv6_header);
    printf("%d/n",sum);
    return 0;
}