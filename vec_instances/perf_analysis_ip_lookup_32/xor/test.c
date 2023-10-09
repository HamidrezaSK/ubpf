#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <bpf/bpf_endian.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

#define RULES_NUM 32
#define BATCH_SIZE 4

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


static __u32 check_ipv6_rule(const struct ip6_hdr lookup, const struct ip6_hdr ipv6_header)
{

    uint32_t result = 0;
    for(int i = 0; i<4; i++)
       result |= ipv6_header.ip6_src.s6_addr32[i] ^ lookup.ip6_src.s6_addr32[i];
    if (result)
        return 0;
    return 1;
}

uint64_t is_dst_one_one_one_one(void *opaque, void *r) {
    int sum = 0;
    bool check[BATCH_SIZE] = {false};
    struct ip6_hdr *ipv6_headers = (struct ip6_hdr *)(opaque);
    struct ip6_hdr *lookups = (struct ip6_hdr *)(r);
    for (int i=0; i<BATCH_SIZE; ++i)
        for (int j = 0; j<RULES_NUM;++j)
            sum += check_ipv6_rule(lookups[j],ipv6_headers[i]);
    return sum;
}

int main()
{
    size_t mem_len = 0;
    
    void* mem = readfile("ipv6_in.mem", 1024 * 1024, &mem_len);
    void* r_mem = readfile("rule_in.mem", 1024 * 1024, &mem_len);

    
    long ret = is_dst_one_one_one_one(mem, r_mem);
    printf("%ld \n",ret);
    return 0;
}