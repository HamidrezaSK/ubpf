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
    with open('rule_in.mem', 'wb') as f:
        for i in range(32):
            p = IPv6(src=generate_random_ip(), dst=generate_random_ip())
            f.write(raw(p))