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
    with open('ipv6_in.mem', 'wb') as f:
        # for i in range(3):
        #     p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
        #     f.write(raw(p))
        p = Ether(src='BB:AA:12:34:67:98',dst='BB:AA:12:34:67:99')/IPv6(src='fc00:dead:cafe:1:0:0:0:2', dst='2001:db8:85a3::98ab:370:7334')
        a = p.show(dump=True)
        print (a)
        f.write(raw(p))