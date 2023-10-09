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
    with open('ipv6_in.mem', 'wb') as f:
        for i in range(3):
            p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
            f.write(raw(p))
        p = IPv6(src='2a03:2880:f21a:0083:face:b00b:0360:25de', dst='2001:db8:85a3::98ab:370:7334')
        f.write(raw(p))