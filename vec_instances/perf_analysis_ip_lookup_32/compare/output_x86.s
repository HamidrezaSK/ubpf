
obj_x86.o:	file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <is_dst_one_one_one_one>:
       0: 55                           	pushq	%rbp
       1: 48 89 e5                     	movq	%rsp, %rbp
       4: 66 0f 6e 47 08               	movd	8(%rdi), %xmm0          # xmm0 = mem[0],zero,zero,zero
       9: 66 44 0f 70 c0 00            	pshufd	$0, %xmm0, %xmm8        # xmm8 = xmm0[0,0,0,0]
       f: 66 0f 6e 4f 0c               	movd	12(%rdi), %xmm1         # xmm1 = mem[0],zero,zero,zero
      14: 66 44 0f 70 c9 00            	pshufd	$0, %xmm1, %xmm9        # xmm9 = xmm1[0,0,0,0]
      1a: 66 0f 6e 57 10               	movd	16(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
      1f: 66 0f 70 da 00               	pshufd	$0, %xmm2, %xmm3        # xmm3 = xmm2[0,0,0,0]
      24: 66 0f 6e 57 14               	movd	20(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
      29: 66 0f 70 e2 00               	pshufd	$0, %xmm2, %xmm4        # xmm4 = xmm2[0,0,0,0]
      2e: 66 0f ef d2                  	pxor	%xmm2, %xmm2
      32: b8 8c 00 00 00               	movl	$140, %eax
      37: 66 0f 1f 84 00 00 00 00 00   	nopw	(%rax,%rax)
      40: 66 0f 6e 6c 06 f4            	movd	-12(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      46: 66 0f 6e 74 06 cc            	movd	-52(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      4c: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
      50: 66 0f 6e 6c 06 a4            	movd	-92(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      56: 66 0f 6e bc 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
      5f: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
      63: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
      67: 66 41 0f 76 f8               	pcmpeqd	%xmm8, %xmm7
      6c: 66 0f 6e 6c 06 f8            	movd	-8(%rsi,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
      72: 66 0f 6e 74 06 d0            	movd	-48(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      78: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
      7c: 66 0f 6e 44 06 a8            	movd	-88(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      82: 66 0f 6e 6c 06 80            	movd	-128(%rsi,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
      88: 66 0f 62 e8                  	punpckldq	%xmm0, %xmm5    # xmm5 = xmm5[0],xmm0[0],xmm5[1],xmm0[1]
      8c: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
      90: 66 41 0f 76 e9               	pcmpeqd	%xmm9, %xmm5
      95: 66 0f db ef                  	pand	%xmm7, %xmm5
      99: 66 0f 6e 44 06 fc            	movd	-4(%rsi,%rax), %xmm0    # xmm0 = mem[0],zero,zero,zero
      9f: 66 0f 6e 74 06 d4            	movd	-44(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      a5: 66 0f 62 f0                  	punpckldq	%xmm0, %xmm6    # xmm6 = xmm6[0],xmm0[0],xmm6[1],xmm0[1]
      a9: 66 0f 6e 44 06 ac            	movd	-84(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      af: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
      b5: 66 0f 62 f8                  	punpckldq	%xmm0, %xmm7    # xmm7 = xmm7[0],xmm0[0],xmm7[1],xmm0[1]
      b9: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
      bd: 66 0f 76 fb                  	pcmpeqd	%xmm3, %xmm7
      c1: 66 0f 6e 04 06               	movd	(%rsi,%rax), %xmm0      # xmm0 = mem[0],zero,zero,zero
      c6: 66 0f 6e 74 06 d8            	movd	-40(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      cc: 66 0f 62 f0                  	punpckldq	%xmm0, %xmm6    # xmm6 = xmm6[0],xmm0[0],xmm6[1],xmm0[1]
      d0: 66 0f 6e 44 06 b0            	movd	-80(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      d6: 66 0f 6e 4c 06 88            	movd	-120(%rsi,%rax), %xmm1  # xmm1 = mem[0],zero,zero,zero
      dc: 66 0f 62 c8                  	punpckldq	%xmm0, %xmm1    # xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
      e0: 66 0f 6c ce                  	punpcklqdq	%xmm6, %xmm1    # xmm1 = xmm1[0],xmm6[0]
      e4: 66 0f 76 cc                  	pcmpeqd	%xmm4, %xmm1
      e8: 66 0f db cf                  	pand	%xmm7, %xmm1
      ec: 66 0f db cd                  	pand	%xmm5, %xmm1
      f0: 66 0f fa d1                  	psubd	%xmm1, %xmm2
      f4: 48 05 a0 00 00 00            	addq	$160, %rax
      fa: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     100: 0f 85 3a ff ff ff            	jne	0x40 <is_dst_one_one_one_one+0x40>
     106: 66 0f 70 c2 ee               	pshufd	$238, %xmm2, %xmm0      # xmm0 = xmm2[2,3,2,3]
     10b: 66 0f fe c2                  	paddd	%xmm2, %xmm0
     10f: 66 0f 70 c8 55               	pshufd	$85, %xmm0, %xmm1       # xmm1 = xmm0[1,1,1,1]
     114: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     118: 66 0f ef c0                  	pxor	%xmm0, %xmm0
     11c: f3 0f 10 c1                  	movss	%xmm1, %xmm0            # xmm0 = xmm1[0],xmm0[1,2,3]
     120: 66 0f 6e 4f 30               	movd	48(%rdi), %xmm1         # xmm1 = mem[0],zero,zero,zero
     125: 66 44 0f 70 c1 00            	pshufd	$0, %xmm1, %xmm8        # xmm8 = xmm1[0,0,0,0]
     12b: 66 0f 6e 57 34               	movd	52(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
     130: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     136: 66 0f 6e 5f 38               	movd	56(%rdi), %xmm3         # xmm3 = mem[0],zero,zero,zero
     13b: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
     140: 66 0f 6e 67 3c               	movd	60(%rdi), %xmm4         # xmm4 = mem[0],zero,zero,zero
     145: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     14a: b8 8c 00 00 00               	movl	$140, %eax
     14f: 90                           	nop
     150: 66 0f 6e 6c 06 f4            	movd	-12(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     156: 66 0f 6e 74 06 cc            	movd	-52(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     15c: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     160: 66 0f 6e 6c 06 a4            	movd	-92(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     166: 66 0f 6e bc 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     16f: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
     173: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     177: 66 41 0f 76 f8               	pcmpeqd	%xmm8, %xmm7
     17c: 66 0f 6e 6c 06 f8            	movd	-8(%rsi,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
     182: 66 0f 6e 74 06 d0            	movd	-48(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     188: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     18c: 66 0f 6e 4c 06 a8            	movd	-88(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     192: 66 0f 6e 6c 06 80            	movd	-128(%rsi,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
     198: 66 0f 62 e9                  	punpckldq	%xmm1, %xmm5    # xmm5 = xmm5[0],xmm1[0],xmm5[1],xmm1[1]
     19c: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
     1a0: 66 41 0f 76 e9               	pcmpeqd	%xmm9, %xmm5
     1a5: 66 0f db ef                  	pand	%xmm7, %xmm5
     1a9: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     1af: 66 0f 6e 74 06 d4            	movd	-44(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     1b5: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     1b9: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     1bf: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     1c5: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     1c9: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     1cd: 66 0f 76 fb                  	pcmpeqd	%xmm3, %xmm7
     1d1: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     1d6: 66 0f 6e 74 06 d8            	movd	-40(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     1dc: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     1e0: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     1e6: 66 0f 6e 54 06 88            	movd	-120(%rsi,%rax), %xmm2  # xmm2 = mem[0],zero,zero,zero
     1ec: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     1f0: 66 0f 6c d6                  	punpcklqdq	%xmm6, %xmm2    # xmm2 = xmm2[0],xmm6[0]
     1f4: 66 0f 76 d4                  	pcmpeqd	%xmm4, %xmm2
     1f8: 66 0f db d7                  	pand	%xmm7, %xmm2
     1fc: 66 0f db d5                  	pand	%xmm5, %xmm2
     200: 66 0f fa c2                  	psubd	%xmm2, %xmm0
     204: 48 05 a0 00 00 00            	addq	$160, %rax
     20a: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     210: 0f 85 3a ff ff ff            	jne	0x150 <is_dst_one_one_one_one+0x150>
     216: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     21b: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     21f: 66 0f 70 d1 55               	pshufd	$85, %xmm1, %xmm2       # xmm2 = xmm1[1,1,1,1]
     224: 66 0f fe d1                  	paddd	%xmm1, %xmm2
     228: 0f 57 c0                     	xorps	%xmm0, %xmm0
     22b: f3 0f 10 c2                  	movss	%xmm2, %xmm0            # xmm0 = xmm2[0],xmm0[1,2,3]
     22f: 66 0f 6e 4f 58               	movd	88(%rdi), %xmm1         # xmm1 = mem[0],zero,zero,zero
     234: 66 44 0f 70 c1 00            	pshufd	$0, %xmm1, %xmm8        # xmm8 = xmm1[0,0,0,0]
     23a: 66 0f 6e 57 5c               	movd	92(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
     23f: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     245: 66 0f 6e 5f 60               	movd	96(%rdi), %xmm3         # xmm3 = mem[0],zero,zero,zero
     24a: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
     24f: 66 0f 6e 67 64               	movd	100(%rdi), %xmm4        # xmm4 = mem[0],zero,zero,zero
     254: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     259: b8 8c 00 00 00               	movl	$140, %eax
     25e: 66 90                        	nop
     260: 66 0f 6e 6c 06 f4            	movd	-12(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     266: 66 0f 6e 74 06 cc            	movd	-52(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     26c: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     270: 66 0f 6e 6c 06 a4            	movd	-92(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     276: 66 0f 6e bc 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     27f: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
     283: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     287: 66 41 0f 76 f8               	pcmpeqd	%xmm8, %xmm7
     28c: 66 0f 6e 6c 06 f8            	movd	-8(%rsi,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
     292: 66 0f 6e 74 06 d0            	movd	-48(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     298: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     29c: 66 0f 6e 4c 06 a8            	movd	-88(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     2a2: 66 0f 6e 6c 06 80            	movd	-128(%rsi,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
     2a8: 66 0f 62 e9                  	punpckldq	%xmm1, %xmm5    # xmm5 = xmm5[0],xmm1[0],xmm5[1],xmm1[1]
     2ac: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
     2b0: 66 41 0f 76 e9               	pcmpeqd	%xmm9, %xmm5
     2b5: 66 0f db ef                  	pand	%xmm7, %xmm5
     2b9: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     2bf: 66 0f 6e 74 06 d4            	movd	-44(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     2c5: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     2c9: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     2cf: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     2d5: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     2d9: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     2dd: 66 0f 76 fb                  	pcmpeqd	%xmm3, %xmm7
     2e1: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     2e6: 66 0f 6e 74 06 d8            	movd	-40(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     2ec: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     2f0: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     2f6: 66 0f 6e 54 06 88            	movd	-120(%rsi,%rax), %xmm2  # xmm2 = mem[0],zero,zero,zero
     2fc: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     300: 66 0f 6c d6                  	punpcklqdq	%xmm6, %xmm2    # xmm2 = xmm2[0],xmm6[0]
     304: 66 0f 76 d4                  	pcmpeqd	%xmm4, %xmm2
     308: 66 0f db d7                  	pand	%xmm7, %xmm2
     30c: 66 0f db d5                  	pand	%xmm5, %xmm2
     310: 66 0f fa c2                  	psubd	%xmm2, %xmm0
     314: 48 05 a0 00 00 00            	addq	$160, %rax
     31a: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     320: 0f 85 3a ff ff ff            	jne	0x260 <is_dst_one_one_one_one+0x260>
     326: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     32b: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     32f: 66 0f 70 d1 55               	pshufd	$85, %xmm1, %xmm2       # xmm2 = xmm1[1,1,1,1]
     334: 66 0f fe d1                  	paddd	%xmm1, %xmm2
     338: 0f 57 c0                     	xorps	%xmm0, %xmm0
     33b: f3 0f 10 c2                  	movss	%xmm2, %xmm0            # xmm0 = xmm2[0],xmm0[1,2,3]
     33f: 66 0f 6e 8f 80 00 00 00      	movd	128(%rdi), %xmm1        # xmm1 = mem[0],zero,zero,zero
     347: 66 44 0f 70 c1 00            	pshufd	$0, %xmm1, %xmm8        # xmm8 = xmm1[0,0,0,0]
     34d: 66 0f 6e 97 84 00 00 00      	movd	132(%rdi), %xmm2        # xmm2 = mem[0],zero,zero,zero
     355: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     35b: 66 0f 6e 9f 88 00 00 00      	movd	136(%rdi), %xmm3        # xmm3 = mem[0],zero,zero,zero
     363: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
     368: 66 0f 6e a7 8c 00 00 00      	movd	140(%rdi), %xmm4        # xmm4 = mem[0],zero,zero,zero
     370: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     375: b8 8c 00 00 00               	movl	$140, %eax
     37a: 66 0f 1f 44 00 00            	nopw	(%rax,%rax)
     380: 66 0f 6e 6c 06 f4            	movd	-12(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     386: 66 0f 6e 74 06 cc            	movd	-52(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     38c: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     390: 66 0f 6e 6c 06 a4            	movd	-92(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     396: 66 0f 6e bc 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     39f: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
     3a3: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     3a7: 66 41 0f 76 f8               	pcmpeqd	%xmm8, %xmm7
     3ac: 66 0f 6e 6c 06 f8            	movd	-8(%rsi,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
     3b2: 66 0f 6e 74 06 d0            	movd	-48(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     3b8: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     3bc: 66 0f 6e 4c 06 a8            	movd	-88(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     3c2: 66 0f 6e 6c 06 80            	movd	-128(%rsi,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
     3c8: 66 0f 62 e9                  	punpckldq	%xmm1, %xmm5    # xmm5 = xmm5[0],xmm1[0],xmm5[1],xmm1[1]
     3cc: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
     3d0: 66 41 0f 76 e9               	pcmpeqd	%xmm9, %xmm5
     3d5: 66 0f db ef                  	pand	%xmm7, %xmm5
     3d9: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     3df: 66 0f 6e 74 06 d4            	movd	-44(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     3e5: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     3e9: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     3ef: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     3f5: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     3f9: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     3fd: 66 0f 76 fb                  	pcmpeqd	%xmm3, %xmm7
     401: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     406: 66 0f 6e 74 06 d8            	movd	-40(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     40c: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     410: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     416: 66 0f 6e 54 06 88            	movd	-120(%rsi,%rax), %xmm2  # xmm2 = mem[0],zero,zero,zero
     41c: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     420: 66 0f 6c d6                  	punpcklqdq	%xmm6, %xmm2    # xmm2 = xmm2[0],xmm6[0]
     424: 66 0f 76 d4                  	pcmpeqd	%xmm4, %xmm2
     428: 66 0f db d7                  	pand	%xmm7, %xmm2
     42c: 66 0f db d5                  	pand	%xmm5, %xmm2
     430: 66 0f fa c2                  	psubd	%xmm2, %xmm0
     434: 48 05 a0 00 00 00            	addq	$160, %rax
     43a: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     440: 0f 85 3a ff ff ff            	jne	0x380 <is_dst_one_one_one_one+0x380>
     446: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     44b: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     44f: 66 0f 70 c1 55               	pshufd	$85, %xmm1, %xmm0       # xmm0 = xmm1[1,1,1,1]
     454: 66 0f fe c1                  	paddd	%xmm1, %xmm0
     458: 66 0f 7e c0                  	movd	%xmm0, %eax
     45c: 48 98                        	cltq
     45e: 5d                           	popq	%rbp
     45f: c3                           	retq

0000000000000460 <main>:
     460: 55                           	pushq	%rbp
     461: 48 89 e5                     	movq	%rsp, %rbp
     464: 41 57                        	pushq	%r15
     466: 41 56                        	pushq	%r14
     468: 41 54                        	pushq	%r12
     46a: 53                           	pushq	%rbx
     46b: 31 db                        	xorl	%ebx, %ebx
     46d: 31 ff                        	xorl	%edi, %edi
     46f: e8 00 00 00 00               	callq	0x474 <main+0x14>
		0000000000000470:  R_X86_64_PLT32	time-0x4
     474: 89 c7                        	movl	%eax, %edi
     476: e8 00 00 00 00               	callq	0x47b <main+0x1b>
		0000000000000477:  R_X86_64_PLT32	srand-0x4
     47b: bf 00 00 00 00               	movl	$0, %edi
		000000000000047c:  R_X86_64_32	.rodata.str1.1
     480: be 00 00 00 00               	movl	$0, %esi
		0000000000000481:  R_X86_64_32	.rodata.str1.1+0x1e
     485: e8 00 00 00 00               	callq	0x48a <main+0x2a>
		0000000000000486:  R_X86_64_PLT32	fopen-0x4
     48a: 49 89 c7                     	movq	%rax, %r15
     48d: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     492: be 01 00 00 00               	movl	$1, %esi
     497: e8 00 00 00 00               	callq	0x49c <main+0x3c>
		0000000000000498:  R_X86_64_PLT32	calloc-0x4
     49c: 49 89 c6                     	movq	%rax, %r14
     49f: 90                           	nop
     4a0: 49 8d 3c 1e                  	leaq	(%r14,%rbx), %rdi
     4a4: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     4a9: 48 29 da                     	subq	%rbx, %rdx
     4ac: be 01 00 00 00               	movl	$1, %esi
     4b1: 4c 89 f9                     	movq	%r15, %rcx
     4b4: e8 00 00 00 00               	callq	0x4b9 <main+0x59>
		00000000000004b5:  R_X86_64_PLT32	fread-0x4
     4b9: 48 01 c3                     	addq	%rax, %rbx
     4bc: 48 85 c0                     	testq	%rax, %rax
     4bf: 75 df                        	jne	0x4a0 <main+0x40>
     4c1: 4c 89 ff                     	movq	%r15, %rdi
     4c4: e8 00 00 00 00               	callq	0x4c9 <main+0x69>
		00000000000004c5:  R_X86_64_PLT32	fclose-0x4
     4c9: bf 00 00 00 00               	movl	$0, %edi
		00000000000004ca:  R_X86_64_32	.rodata.str1.1+0xc
     4ce: be 00 00 00 00               	movl	$0, %esi
		00000000000004cf:  R_X86_64_32	.rodata.str1.1+0x1e
     4d3: e8 00 00 00 00               	callq	0x4d8 <main+0x78>
		00000000000004d4:  R_X86_64_PLT32	fopen-0x4
     4d8: 49 89 c7                     	movq	%rax, %r15
     4db: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     4e0: be 01 00 00 00               	movl	$1, %esi
     4e5: e8 00 00 00 00               	callq	0x4ea <main+0x8a>
		00000000000004e6:  R_X86_64_PLT32	calloc-0x4
     4ea: 49 89 c4                     	movq	%rax, %r12
     4ed: 31 db                        	xorl	%ebx, %ebx
     4ef: 90                           	nop
     4f0: 49 8d 3c 1c                  	leaq	(%r12,%rbx), %rdi
     4f4: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     4f9: 48 29 da                     	subq	%rbx, %rdx
     4fc: be 01 00 00 00               	movl	$1, %esi
     501: 4c 89 f9                     	movq	%r15, %rcx
     504: e8 00 00 00 00               	callq	0x509 <main+0xa9>
		0000000000000505:  R_X86_64_PLT32	fread-0x4
     509: 48 01 c3                     	addq	%rax, %rbx
     50c: 48 85 c0                     	testq	%rax, %rax
     50f: 75 df                        	jne	0x4f0 <main+0x90>
     511: 4c 89 ff                     	movq	%r15, %rdi
     514: e8 00 00 00 00               	callq	0x519 <main+0xb9>
		0000000000000515:  R_X86_64_PLT32	fclose-0x4
     519: 4c 89 f7                     	movq	%r14, %rdi
     51c: 4c 89 e6                     	movq	%r12, %rsi
     51f: e8 00 00 00 00               	callq	0x524 <main+0xc4>
		0000000000000520:  R_X86_64_PLT32	is_dst_one_one_one_one-0x4
     524: bf 00 00 00 00               	movl	$0, %edi
		0000000000000525:  R_X86_64_32	.rodata.str1.1+0x18
     529: 48 89 c6                     	movq	%rax, %rsi
     52c: 31 c0                        	xorl	%eax, %eax
     52e: e8 00 00 00 00               	callq	0x533 <main+0xd3>
		000000000000052f:  R_X86_64_PLT32	printf-0x4
     533: 31 c0                        	xorl	%eax, %eax
     535: 5b                           	popq	%rbx
     536: 41 5c                        	popq	%r12
     538: 41 5e                        	popq	%r14
     53a: 41 5f                        	popq	%r15
     53c: 5d                           	popq	%rbp
     53d: c3                           	retq
