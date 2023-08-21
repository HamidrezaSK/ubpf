#include <linux/bpf.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdio.h>
#include <netinet/ip6.h>
#include <bpf/bpf_endian.h>
#include <string.h>

#define ADD_SIZE 4

static uint64_t hash_calculator(const struct ip6_hdr ipv6_header,size_t size){
    uint64_t hash_value = 0;
    for (size_t i = 0; i < size; i++) {
        hash_value  += ntohs(ipv6_header.ip6_src.s6_addr32[i]) * 31; // A common prime number multiplier
    }
    return hash_value;
}


uint64_t hash(void* packet) {
    struct ip6_hdr *ipv6_header = (struct ip6_hdr *)(packet);

    uint64_t result = 0;
    
    result = hash_calculator(*ipv6_header, ADD_SIZE);

    // printf("%l",result);

    // return 0;
    
    return result;
}