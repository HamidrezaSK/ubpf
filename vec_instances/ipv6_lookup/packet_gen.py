from scapy.all import IPv6,raw
p = IPv6(src='2a03:2880:f21a:0083:face:b00b:0360:25de', dst='2001:db8:85a3::98ab:370:7334')
a = p.show(dump=True)
print (a)

with open('ipv6_in.mem', 'wb') as f:
    f.write(raw(p))
