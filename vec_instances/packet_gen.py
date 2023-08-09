from scapy.all import IPv6,raw
p = IPv6(src='2001:db8:85a3::8a2e:370:7334', dst='2001:db8:85a3::98ab:370:7334')
a = p.show(dump=True)
print (a)

with open('ip_1_1_1_1.mem', 'wb') as f:
    f.write(raw(p))
