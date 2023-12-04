from scapy.all import IPv6,raw,Ether,TCP
import random
import string
import sys

def generate_random_ip():
    result = ""
    for i in range(8):
        section = ''.join(random.choice('a' + 'b' + 'c' + 'c' + 'd' + 'e' + 'f' + string.digits) for _ in range(4))
        result += section + ':'
    return result[:-1]

if __name__ == "__main__":
    count = 0
    if len(sys.argv) < 2:
        count = 1
    else:
        try:
            count = int(sys.argv[1])
        except ValueError:
            print("Error: Invalid integer provided.")
            sys.exit(1)

    with open('ipv6_in_'+str(count)+'.mem', 'wb') as f:
        for i in range(count):
            p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
            eth_frame = Ether(dst="00:11:22:33:44:55", src="a1:b2:c3:d4:e5:f6")
            tcp_seg = TCP(sport=12345, dport=80)
            packet = eth_frame / p / tcp_seg
            f.write(raw(packet))