from scapy.all import IPv6,raw
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
    with open(f'ipv6_in_'+count+'.mem', 'wb') as f:
        for i in range(int(count)):
            p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
            f.write(raw(p))