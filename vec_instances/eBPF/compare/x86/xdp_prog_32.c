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
#include <time.h>
#include <stdbool.h>


#include "../../common/parsing_helpers.h"


#define RULES_NUM 32

#define TRIAL_NUM 1000000



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
	    {
        // Rule 5
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707335},
    },
    {
        // Rule 6
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701236},
    },
    {
        // Rule 7
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
    {
        // Rule 8
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707334},
    },
    {
        // Rule 9
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701234},
    },
    {
        // Rule 10
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x25c81946},
    },
    {
        // Rule 11
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x036025de},
    },
	    {
        // Rule 12
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707335},
    },
    {
        // Rule 13
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701236},
    },
    {
        // Rule 14
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
	{
        // Rule 15
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
    {
        // Rule 16
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
    {
        // Rule 17
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707334},
    },
    {
        // Rule 18
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701234},
    },
    {
        // Rule 19
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x25c81946},
    },
    {
        // Rule 20
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x036025de},
    },
	    {
        // Rule 21
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707335},
    },
    {
        // Rule 22
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701236},
    },
    {
        // Rule 23
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
    {
        // Rule 24
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707334},
    },
    {
        // Rule 25
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701234},
    },
    {
        // Rule 26
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x25c81946},
    },
    {
        // Rule 27
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x036025de},
    },
	    {
        // Rule 28
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x03707335},
    },
    {
        // Rule 29
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x13701236},
    },
    {
        // Rule 30
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
	{
        // Rule 31
        .src_ip.s6_addr32 = {0x2a032880, 0xf21a0083, 0xfaceb00b, 0x15c81923},
    },
    {
        // Rule 32
        .src_ip.s6_addr32 = {2917007612, 16842442, 0, 33554432},
    },
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


int xdp_firewall_func(void *data, size_t data_len)
{
	void *data_end = data + data_len;
    
	struct ethhdr *eth;
	struct iphdr *iph;
	struct ipv6hdr *ip6h;

	int i;
	

	__u32 action = XDP_DROP; /* Default action */


	/* These keep track of the next header type and iterator pointer */
	struct hdr_cursor nh;
	int eth_type;
    
	/* Start next header cursor position at data start */
	nh.pos = data;
	eth_type = parse_ethhdr(&nh, data_end, &eth);


	if(eth_type < 0){
		action = XDP_ABORTED;
		goto out;
	}

	if (eth_type == bpf_htons(ETH_P_IP))
		parse_iphdr(&nh, data_end, &iph);
	else if (eth_type == bpf_htons(ETH_P_IPV6))
		parse_ip6hdr(&nh, data_end, &ip6h);
	else
		goto out;
	
	// Here I want to check if I can get the source and dest IP address to actually do the comparisons
    struct in6_addr saddr = ip6h->saddr;

	if (eth_type == bpf_htons(ETH_P_IPV6))
	{
		if(ip6h + 1 > data_end)//bourndary check to access the packet
		{
			action = XDP_ABORTED;
			goto out;
		}
		#pragma unroll
		for (i = 0; i < RULES_NUM; ++i)
		{
			if((saddr.s6_addr32[0] == lookups[i].src_ip.s6_addr32[0])
			&& (saddr.s6_addr32[1] == lookups[i].src_ip.s6_addr32[1])
			&& (saddr.s6_addr32[2] == lookups[i].src_ip.s6_addr32[2])
			&& (saddr.s6_addr32[3] == lookups[i].src_ip.s6_addr32[3]))
			{
				action = XDP_PASS;
				break;
			}
		}

	}

out:
	return action;
}



int main(int argc, char *argv[])
{
    size_t mem_len = 0;
    char *path = argv[1];
    
    void* mem = readfile(path, 1024 * 1024, &mem_len);
    int i;
    volatile int ret =0;
    clock_t begin = clock();

    for(i = 0; i < TRIAL_NUM ; ++i)
    {
        ret = xdp_firewall_func(mem, mem_len);
    }
    double time_spent = (double)(clock() - begin) / CLOCKS_PER_SEC;
    printf("ret: %d\n",ret);

    printf("Average execution time: %.7f\n",time_spent);

    return 0;
}