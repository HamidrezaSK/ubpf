from scapy.all import IPv6,raw,Ether
import random
import string

def generate_random_ip():
    result = ""
    for i in range(8):
        section = ''.join(random.choice('a' + 'b' + 'c' + 'c' + 'd' + 'e' + 'f' + string.digits) for _ in range(4))
        result += section + ':'
    return result[:-1]

if __name__ == "__main__":
    count = input("how many packets do you want in a batch: ")
    with open('ipv6_in_'+count+'.mem', 'wb') as f:
        for i in range(int(count)):
            p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
            eth_frame = Ether(dst="00:11:22:33:44:55", src="a1:b2:c3:d4:e5:f6")
            packet = eth_frame / p
            f.write(raw(packet))