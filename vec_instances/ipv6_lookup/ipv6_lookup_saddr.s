
ipv6_lookup_saddr.o:	file format elf64-bpf

Disassembly of section .text:

0000000000000000 <is_dst_one_one_one_one>:
       0:	71 12 17 00 00 00 00 00	r2 = *(u8 *)(r1 + 23)
       1:	67 02 00 00 08 00 00 00	r2 <<= 8
       2:	71 13 16 00 00 00 00 00	r3 = *(u8 *)(r1 + 22)
       3:	4f 32 00 00 00 00 00 00	r2 |= r3
       4:	71 13 15 00 00 00 00 00	r3 = *(u8 *)(r1 + 21)
       5:	67 03 00 00 08 00 00 00	r3 <<= 8
       6:	71 14 14 00 00 00 00 00	r4 = *(u8 *)(r1 + 20)
       7:	4f 43 00 00 00 00 00 00	r3 |= r4
       8:	71 15 13 00 00 00 00 00	r5 = *(u8 *)(r1 + 19)
       9:	67 05 00 00 08 00 00 00	r5 <<= 8
      10:	71 14 12 00 00 00 00 00	r4 = *(u8 *)(r1 + 18)
      11:	4f 45 00 00 00 00 00 00	r5 |= r4
      12:	71 10 11 00 00 00 00 00	r0 = *(u8 *)(r1 + 17)
      13:	67 00 00 00 08 00 00 00	r0 <<= 8
      14:	71 14 10 00 00 00 00 00	r4 = *(u8 *)(r1 + 16)
      15:	4f 40 00 00 00 00 00 00	r0 |= r4
      16:	71 16 0f 00 00 00 00 00	r6 = *(u8 *)(r1 + 15)
      17:	67 06 00 00 08 00 00 00	r6 <<= 8
      18:	71 14 0e 00 00 00 00 00	r4 = *(u8 *)(r1 + 14)
      19:	4f 46 00 00 00 00 00 00	r6 |= r4
      20:	71 18 0d 00 00 00 00 00	r8 = *(u8 *)(r1 + 13)
      21:	67 08 00 00 08 00 00 00	r8 <<= 8
      22:	71 14 0c 00 00 00 00 00	r4 = *(u8 *)(r1 + 12)
      23:	4f 48 00 00 00 00 00 00	r8 |= r4
      24:	71 17 08 00 00 00 00 00	r7 = *(u8 *)(r1 + 8)
      25:	71 14 09 00 00 00 00 00	r4 = *(u8 *)(r1 + 9)
      26:	67 04 00 00 08 00 00 00	r4 <<= 8
      27:	4f 74 00 00 00 00 00 00	r4 |= r7
      28:	65 04 31 00 25 06 00 00	if r4 s> 1573 goto +49 <LBB0_3>
      29:	b7 07 00 00 00 00 00 00	r7 = 0
      30:	7b 7a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r7
      31:	15 04 56 00 20 01 00 00	if r4 == 288 goto +86 <LBB0_13>
      32:	b7 07 00 00 00 00 00 00	r7 = 0
      33:	b7 09 00 00 00 00 00 00	r9 = 0
      34:	15 04 01 00 2a 03 00 00	if r4 == 810 goto +1 <LBB0_28>
      35:	05 00 22 00 00 00 00 00	goto +34 <LBB0_35>

0000000000000120 <LBB0_28>:
      36:	71 14 0a 00 00 00 00 00	r4 = *(u8 *)(r1 + 10)
      37:	71 11 0b 00 00 00 00 00	r1 = *(u8 *)(r1 + 11)
      38:	67 01 00 00 08 00 00 00	r1 <<= 8
      39:	4f 41 00 00 00 00 00 00	r1 |= r4
      40:	b7 04 00 00 00 00 00 00	r4 = 0
      41:	7b 4a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r4
      42:	b7 07 00 00 00 00 00 00	r7 = 0
      43:	b7 09 00 00 00 00 00 00	r9 = 0
      44:	55 01 19 00 28 80 00 00	if r1 != 32808 goto +25 <LBB0_35>
      45:	57 08 00 00 ff ff 00 00	r8 &= 65535
      46:	b7 07 00 00 00 00 00 00	r7 = 0
      47:	b7 09 00 00 00 00 00 00	r9 = 0
      48:	55 08 15 00 f2 1a 00 00	if r8 != 6898 goto +21 <LBB0_35>
      49:	57 06 00 00 ff ff 00 00	r6 &= 65535
      50:	b7 07 00 00 00 00 00 00	r7 = 0
      51:	b7 09 00 00 00 00 00 00	r9 = 0
      52:	55 06 11 00 00 83 00 00	if r6 != 33536 goto +17 <LBB0_35>
      53:	57 00 00 00 ff ff 00 00	r0 &= 65535
      54:	b7 07 00 00 00 00 00 00	r7 = 0
      55:	b7 09 00 00 00 00 00 00	r9 = 0
      56:	55 00 0d 00 fa ce 00 00	if r0 != 52986 goto +13 <LBB0_35>
      57:	57 05 00 00 ff ff 00 00	r5 &= 65535
      58:	b7 07 00 00 00 00 00 00	r7 = 0
      59:	b7 09 00 00 00 00 00 00	r9 = 0
      60:	55 05 09 00 b0 0b 00 00	if r5 != 2992 goto +9 <LBB0_35>
      61:	57 03 00 00 ff ff 00 00	r3 &= 65535
      62:	b7 07 00 00 00 00 00 00	r7 = 0
      63:	b7 09 00 00 00 00 00 00	r9 = 0
      64:	55 03 05 00 03 60 00 00	if r3 != 24579 goto +5 <LBB0_35>
      65:	b7 00 00 00 01 00 00 00	r0 = 1
      66:	57 02 00 00 ff ff 00 00	r2 &= 65535
      67:	b7 07 00 00 00 00 00 00	r7 = 0
      68:	b7 09 00 00 00 00 00 00	r9 = 0
      69:	15 02 05 00 25 de 00 00	if r2 == 56869 goto +5 <LBB0_36>

0000000000000230 <LBB0_35>:
      70:	0f 79 00 00 00 00 00 00	r9 += r7
      71:	79 a1 f8 ff 00 00 00 00	r1 = *(u64 *)(r10 - 8)
      72:	0f 91 00 00 00 00 00 00	r1 += r9
      73:	7b 1a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r1
      74:	b7 00 00 00 00 00 00 00	r0 = 0

0000000000000258 <LBB0_36>:
      75:	79 a1 f8 ff 00 00 00 00	r1 = *(u64 *)(r10 - 8)
      76:	0f 10 00 00 00 00 00 00	r0 += r1
      77:	95 00 00 00 00 00 00 00	exit

0000000000000270 <LBB0_3>:
      78:	15 04 48 00 26 06 00 00	if r4 == 1574 goto +72 <LBB0_20>
      79:	b7 07 00 00 00 00 00 00	r7 = 0
      80:	7b 7a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r7
      81:	b7 07 00 00 00 00 00 00	r7 = 0
      82:	b7 09 00 00 00 00 00 00	r9 = 0
      83:	55 04 f2 ff 20 11 00 00	if r4 != 4384 goto -14 <LBB0_35>
      84:	71 14 0a 00 00 00 00 00	r4 = *(u8 *)(r1 + 10)
      85:	71 11 0b 00 00 00 00 00	r1 = *(u8 *)(r1 + 11)
      86:	67 01 00 00 08 00 00 00	r1 <<= 8
      87:	4f 41 00 00 00 00 00 00	r1 |= r4
      88:	b7 07 00 00 00 00 00 00	r7 = 0
      89:	b7 09 00 00 00 00 00 00	r9 = 0
      90:	55 01 eb ff 0d b7 00 00	if r1 != 46861 goto -21 <LBB0_35>
      91:	57 08 00 00 ff ff 00 00	r8 &= 65535
      92:	b7 07 00 00 00 00 00 00	r7 = 0
      93:	b7 09 00 00 00 00 00 00	r9 = 0
      94:	55 08 e7 ff 85 b3 00 00	if r8 != 45957 goto -25 <LBB0_35>
      95:	57 06 00 00 ff ff 00 00	r6 &= 65535
      96:	b7 07 00 00 00 00 00 00	r7 = 0
      97:	b7 09 00 00 00 00 00 00	r9 = 0
      98:	55 06 e3 ff 80 00 00 00	if r6 != 128 goto -29 <LBB0_35>
      99:	57 00 00 00 ff ff 00 00	r0 &= 65535
     100:	b7 07 00 00 00 00 00 00	r7 = 0
     101:	b7 09 00 00 00 00 00 00	r9 = 0
     102:	55 00 df ff 50 21 00 00	if r0 != 8528 goto -33 <LBB0_35>
     103:	57 05 00 00 ff ff 00 00	r5 &= 65535
     104:	b7 07 00 00 00 00 00 00	r7 = 0
     105:	b7 09 00 00 00 00 00 00	r9 = 0
     106:	55 05 db ff 8a 2e 00 00	if r5 != 11914 goto -37 <LBB0_35>
     107:	57 03 00 00 ff ff 00 00	r3 &= 65535
     108:	b7 07 00 00 00 00 00 00	r7 = 0
     109:	b7 09 00 00 00 00 00 00	r9 = 0
     110:	55 03 d7 ff 03 70 00 00	if r3 != 28675 goto -41 <LBB0_35>
     111:	57 02 00 00 ff ff 00 00	r2 &= 65535
     112:	b7 07 00 00 00 00 00 00	r7 = 0
     113:	b7 09 00 00 00 00 00 00	r9 = 0
     114:	55 02 d3 ff 73 34 00 00	if r2 != 13427 goto -45 <LBB0_35>
     115:	b7 07 00 00 01 00 00 00	r7 = 1
     116:	b7 09 00 00 00 00 00 00	r9 = 0
     117:	05 00 d0 ff 00 00 00 00	goto -48 <LBB0_35>

00000000000003b0 <LBB0_13>:
     118:	71 14 0a 00 00 00 00 00	r4 = *(u8 *)(r1 + 10)
     119:	71 11 0b 00 00 00 00 00	r1 = *(u8 *)(r1 + 11)
     120:	67 01 00 00 08 00 00 00	r1 <<= 8
     121:	4f 41 00 00 00 00 00 00	r1 |= r4
     122:	b7 07 00 00 00 00 00 00	r7 = 0
     123:	b7 09 00 00 00 00 00 00	r9 = 0
     124:	55 01 c9 ff 0d b8 00 00	if r1 != 47117 goto -55 <LBB0_35>
     125:	57 08 00 00 ff ff 00 00	r8 &= 65535
     126:	b7 07 00 00 00 00 00 00	r7 = 0
     127:	b7 09 00 00 00 00 00 00	r9 = 0
     128:	55 08 c5 ff 85 a3 00 00	if r8 != 41861 goto -59 <LBB0_35>
     129:	57 06 00 00 ff ff 00 00	r6 &= 65535
     130:	b7 07 00 00 00 00 00 00	r7 = 0
     131:	b7 09 00 00 00 00 00 00	r9 = 0
     132:	55 06 c1 ff 07 00 00 00	if r6 != 7 goto -63 <LBB0_35>
     133:	57 00 00 00 ff ff 00 00	r0 &= 65535
     134:	b7 07 00 00 00 00 00 00	r7 = 0
     135:	b7 09 00 00 00 00 00 00	r9 = 0
     136:	55 00 bd ff 09 00 00 00	if r0 != 9 goto -67 <LBB0_35>
     137:	57 05 00 00 ff ff 00 00	r5 &= 65535
     138:	b7 07 00 00 00 00 00 00	r7 = 0
     139:	b7 09 00 00 00 00 00 00	r9 = 0
     140:	55 05 b9 ff 8a 1e 00 00	if r5 != 7818 goto -71 <LBB0_35>
     141:	57 03 00 00 ff ff 00 00	r3 &= 65535
     142:	b7 07 00 00 00 00 00 00	r7 = 0
     143:	b7 09 00 00 00 00 00 00	r9 = 0
     144:	55 03 b5 ff 13 70 00 00	if r3 != 28691 goto -75 <LBB0_35>
     145:	b7 01 00 00 01 00 00 00	r1 = 1
     146:	57 02 00 00 ff ff 00 00	r2 &= 65535
     147:	b7 07 00 00 00 00 00 00	r7 = 0
     148:	b7 09 00 00 00 00 00 00	r9 = 0
     149:	15 02 17 00 12 34 00 00	if r2 == 13330 goto +23 <LBB0_27>
     150:	05 00 af ff 00 00 00 00	goto -81 <LBB0_35>

00000000000004b8 <LBB0_20>:
     151:	71 14 0a 00 00 00 00 00	r4 = *(u8 *)(r1 + 10)
     152:	71 17 0b 00 00 00 00 00	r7 = *(u8 *)(r1 + 11)
     153:	67 07 00 00 08 00 00 00	r7 <<= 8
     154:	4f 47 00 00 00 00 00 00	r7 |= r4
     155:	b7 01 00 00 00 00 00 00	r1 = 0
     156:	55 07 10 00 28 00 00 00	if r7 != 40 goto +16 <LBB0_27>
     157:	57 08 00 00 ff ff 00 00	r8 &= 65535
     158:	55 08 0e 00 02 20 00 00	if r8 != 8194 goto +14 <LBB0_27>
     159:	57 06 00 00 ff ff 00 00	r6 &= 65535
     160:	55 06 0c 00 00 01 00 00	if r6 != 256 goto +12 <LBB0_27>
     161:	57 00 00 00 ff ff 00 00	r0 &= 65535
     162:	55 00 0a 00 02 48 00 00	if r0 != 18434 goto +10 <LBB0_27>
     163:	57 05 00 00 ff ff 00 00	r5 &= 65535
     164:	55 05 08 00 18 93 00 00	if r5 != 37656 goto +8 <LBB0_27>
     165:	57 03 00 00 ff ff 00 00	r3 &= 65535
     166:	55 03 06 00 25 c8 00 00	if r3 != 51237 goto +6 <LBB0_27>
     167:	b7 03 00 00 01 00 00 00	r3 = 1
     168:	7b 3a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r3
     169:	57 02 00 00 ff ff 00 00	r2 &= 65535
     170:	b7 07 00 00 00 00 00 00	r7 = 0
     171:	b7 09 00 00 00 00 00 00	r9 = 0
     172:	15 02 99 ff 19 46 00 00	if r2 == 17945 goto -103 <LBB0_35>

0000000000000568 <LBB0_27>:
     173:	b7 02 00 00 00 00 00 00	r2 = 0
     174:	7b 2a f8 ff 00 00 00 00	*(u64 *)(r10 - 8) = r2
     175:	b7 07 00 00 00 00 00 00	r7 = 0
     176:	bf 19 00 00 00 00 00 00	r9 = r1
     177:	05 00 94 ff 00 00 00 00	goto -108 <LBB0_35>
