
obj_x86.o:	file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <is_dst_one_one_one_one>:
       0: 55                           	pushq	%rbp
       1: 48 89 e5                     	movq	%rsp, %rbp
       4: 66 0f 6e 47 08               	movd	8(%rdi), %xmm0          # xmm0 = mem[0],zero,zero,zero
       9: 66 44 0f 70 c8 00            	pshufd	$0, %xmm0, %xmm9        # xmm9 = xmm0[0,0,0,0]
       f: 66 0f 6e 4f 0c               	movd	12(%rdi), %xmm1         # xmm1 = mem[0],zero,zero,zero
      14: 66 44 0f 70 d1 00            	pshufd	$0, %xmm1, %xmm10       # xmm10 = xmm1[0,0,0,0]
      1a: 66 0f 6e 57 10               	movd	16(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
      1f: 66 0f 70 d2 00               	pshufd	$0, %xmm2, %xmm2        # xmm2 = xmm2[0,0,0,0]
      24: 66 0f 6e 5f 14               	movd	20(%rdi), %xmm3         # xmm3 = mem[0],zero,zero,zero
      29: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
      2e: 66 45 0f ef c0               	pxor	%xmm8, %xmm8
      33: b8 8c 00 00 00               	movl	$140, %eax
      38: 66 0f ef e4                  	pxor	%xmm4, %xmm4
      3c: 0f 1f 40 00                  	nopl	(%rax)
      40: 66 0f 6e 74 06 f4            	movd	-12(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      46: 66 0f 6e 7c 06 cc            	movd	-52(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
      4c: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
      50: 66 0f 6e 74 06 a4            	movd	-92(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      56: 66 0f 6e ac 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
      5f: 66 0f 62 ee                  	punpckldq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0],xmm5[1],xmm6[1]
      63: 66 0f 6c ef                  	punpcklqdq	%xmm7, %xmm5    # xmm5 = xmm5[0],xmm7[0]
      67: 66 41 0f ef e9               	pxor	%xmm9, %xmm5
      6c: 66 0f 6e 74 06 f8            	movd	-8(%rsi,%rax), %xmm6    # xmm6 = mem[0],zero,zero,zero
      72: 66 0f 6e 7c 06 d0            	movd	-48(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
      78: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
      7c: 66 0f 6e 44 06 a8            	movd	-88(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      82: 66 0f 6e 74 06 80            	movd	-128(%rsi,%rax), %xmm6  # xmm6 = mem[0],zero,zero,zero
      88: 66 0f 62 f0                  	punpckldq	%xmm0, %xmm6    # xmm6 = xmm6[0],xmm0[0],xmm6[1],xmm0[1]
      8c: 66 0f 6c f7                  	punpcklqdq	%xmm7, %xmm6    # xmm6 = xmm6[0],xmm7[0]
      90: 66 41 0f ef f2               	pxor	%xmm10, %xmm6
      95: 66 0f eb f5                  	por	%xmm5, %xmm6
      99: 66 0f 6e 44 06 fc            	movd	-4(%rsi,%rax), %xmm0    # xmm0 = mem[0],zero,zero,zero
      9f: 66 0f 6e 6c 06 d4            	movd	-44(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      a5: 66 0f 62 e8                  	punpckldq	%xmm0, %xmm5    # xmm5 = xmm5[0],xmm0[0],xmm5[1],xmm0[1]
      a9: 66 0f 6e 44 06 ac            	movd	-84(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      af: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
      b5: 66 0f 62 f8                  	punpckldq	%xmm0, %xmm7    # xmm7 = xmm7[0],xmm0[0],xmm7[1],xmm0[1]
      b9: 66 0f 6c fd                  	punpcklqdq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0]
      bd: 66 0f ef fa                  	pxor	%xmm2, %xmm7
      c1: 66 0f 6e 04 06               	movd	(%rsi,%rax), %xmm0      # xmm0 = mem[0],zero,zero,zero
      c6: 66 0f 6e 6c 06 d8            	movd	-40(%rsi,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      cc: 66 0f 62 e8                  	punpckldq	%xmm0, %xmm5    # xmm5 = xmm5[0],xmm0[0],xmm5[1],xmm0[1]
      d0: 66 0f 6e 44 06 b0            	movd	-80(%rsi,%rax), %xmm0   # xmm0 = mem[0],zero,zero,zero
      d6: 66 0f 6e 4c 06 88            	movd	-120(%rsi,%rax), %xmm1  # xmm1 = mem[0],zero,zero,zero
      dc: 66 0f 62 c8                  	punpckldq	%xmm0, %xmm1    # xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
      e0: 66 0f 6c cd                  	punpcklqdq	%xmm5, %xmm1    # xmm1 = xmm1[0],xmm5[0]
      e4: 66 0f ef cb                  	pxor	%xmm3, %xmm1
      e8: 66 0f eb cf                  	por	%xmm7, %xmm1
      ec: 66 0f eb ce                  	por	%xmm6, %xmm1
      f0: 66 41 0f 76 c8               	pcmpeqd	%xmm8, %xmm1
      f5: 66 0f fa e1                  	psubd	%xmm1, %xmm4
      f9: 48 05 a0 00 00 00            	addq	$160, %rax
      ff: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     105: 0f 85 35 ff ff ff            	jne	0x40 <is_dst_one_one_one_one+0x40>
     10b: 66 0f 70 c4 ee               	pshufd	$238, %xmm4, %xmm0      # xmm0 = xmm4[2,3,2,3]
     110: 66 0f fe c4                  	paddd	%xmm4, %xmm0
     114: 66 0f 70 d0 55               	pshufd	$85, %xmm0, %xmm2       # xmm2 = xmm0[1,1,1,1]
     119: 66 0f fe d0                  	paddd	%xmm0, %xmm2
     11d: 66 45 0f ef c0               	pxor	%xmm8, %xmm8
     122: 66 0f ef c0                  	pxor	%xmm0, %xmm0
     126: f3 0f 10 c2                  	movss	%xmm2, %xmm0            # xmm0 = xmm2[0],xmm0[1,2,3]
     12a: 66 0f 6e 57 30               	movd	48(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
     12f: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     135: 66 0f 6e 5f 34               	movd	52(%rdi), %xmm3         # xmm3 = mem[0],zero,zero,zero
     13a: 66 44 0f 70 d3 00            	pshufd	$0, %xmm3, %xmm10       # xmm10 = xmm3[0,0,0,0]
     140: 66 0f 6e 67 38               	movd	56(%rdi), %xmm4         # xmm4 = mem[0],zero,zero,zero
     145: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     14a: 66 0f 6e 6f 3c               	movd	60(%rdi), %xmm5         # xmm5 = mem[0],zero,zero,zero
     14f: 66 0f 70 ed 00               	pshufd	$0, %xmm5, %xmm5        # xmm5 = xmm5[0,0,0,0]
     154: b8 8c 00 00 00               	movl	$140, %eax
     159: 0f 1f 80 00 00 00 00         	nopl	(%rax)
     160: 66 0f 6e 74 06 f4            	movd	-12(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     166: 66 0f 6e 7c 06 cc            	movd	-52(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     16c: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     170: 66 0f 6e 74 06 a4            	movd	-92(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     176: 66 0f 6e 8c 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm1  # xmm1 = mem[0],zero,zero,zero
     17f: 66 0f 62 ce                  	punpckldq	%xmm6, %xmm1    # xmm1 = xmm1[0],xmm6[0],xmm1[1],xmm6[1]
     183: 66 0f 6c cf                  	punpcklqdq	%xmm7, %xmm1    # xmm1 = xmm1[0],xmm7[0]
     187: 66 41 0f ef c9               	pxor	%xmm9, %xmm1
     18c: 66 0f 6e 74 06 f8            	movd	-8(%rsi,%rax), %xmm6    # xmm6 = mem[0],zero,zero,zero
     192: 66 0f 6e 7c 06 d0            	movd	-48(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     198: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     19c: 66 0f 6e 54 06 a8            	movd	-88(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     1a2: 66 0f 6e 74 06 80            	movd	-128(%rsi,%rax), %xmm6  # xmm6 = mem[0],zero,zero,zero
     1a8: 66 0f 62 f2                  	punpckldq	%xmm2, %xmm6    # xmm6 = xmm6[0],xmm2[0],xmm6[1],xmm2[1]
     1ac: 66 0f 6c f7                  	punpcklqdq	%xmm7, %xmm6    # xmm6 = xmm6[0],xmm7[0]
     1b0: 66 41 0f ef f2               	pxor	%xmm10, %xmm6
     1b5: 66 0f eb f1                  	por	%xmm1, %xmm6
     1b9: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     1bf: 66 0f 6e 54 06 d4            	movd	-44(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     1c5: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     1c9: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     1cf: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     1d5: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     1d9: 66 0f 6c fa                  	punpcklqdq	%xmm2, %xmm7    # xmm7 = xmm7[0],xmm2[0]
     1dd: 66 0f ef fc                  	pxor	%xmm4, %xmm7
     1e1: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     1e6: 66 0f 6e 54 06 d8            	movd	-40(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     1ec: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     1f0: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     1f6: 66 0f 6e 5c 06 88            	movd	-120(%rsi,%rax), %xmm3  # xmm3 = mem[0],zero,zero,zero
     1fc: 66 0f 62 d9                  	punpckldq	%xmm1, %xmm3    # xmm3 = xmm3[0],xmm1[0],xmm3[1],xmm1[1]
     200: 66 0f 6c da                  	punpcklqdq	%xmm2, %xmm3    # xmm3 = xmm3[0],xmm2[0]
     204: 66 0f ef dd                  	pxor	%xmm5, %xmm3
     208: 66 0f eb df                  	por	%xmm7, %xmm3
     20c: 66 0f eb de                  	por	%xmm6, %xmm3
     210: 66 41 0f 76 d8               	pcmpeqd	%xmm8, %xmm3
     215: 66 0f fa c3                  	psubd	%xmm3, %xmm0
     219: 48 05 a0 00 00 00            	addq	$160, %rax
     21f: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     225: 0f 85 35 ff ff ff            	jne	0x160 <is_dst_one_one_one_one+0x160>
     22b: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     230: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     234: 66 0f 70 d1 55               	pshufd	$85, %xmm1, %xmm2       # xmm2 = xmm1[1,1,1,1]
     239: 66 0f fe d1                  	paddd	%xmm1, %xmm2
     23d: 66 45 0f ef c0               	pxor	%xmm8, %xmm8
     242: 0f 57 c0                     	xorps	%xmm0, %xmm0
     245: f3 0f 10 c2                  	movss	%xmm2, %xmm0            # xmm0 = xmm2[0],xmm0[1,2,3]
     249: 66 0f 6e 57 58               	movd	88(%rdi), %xmm2         # xmm2 = mem[0],zero,zero,zero
     24e: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     254: 66 0f 6e 5f 5c               	movd	92(%rdi), %xmm3         # xmm3 = mem[0],zero,zero,zero
     259: 66 44 0f 70 d3 00            	pshufd	$0, %xmm3, %xmm10       # xmm10 = xmm3[0,0,0,0]
     25f: 66 0f 6e 67 60               	movd	96(%rdi), %xmm4         # xmm4 = mem[0],zero,zero,zero
     264: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     269: 66 0f 6e 6f 64               	movd	100(%rdi), %xmm5        # xmm5 = mem[0],zero,zero,zero
     26e: 66 0f 70 ed 00               	pshufd	$0, %xmm5, %xmm5        # xmm5 = xmm5[0,0,0,0]
     273: b8 8c 00 00 00               	movl	$140, %eax
     278: 0f 1f 84 00 00 00 00 00      	nopl	(%rax,%rax)
     280: 66 0f 6e 74 06 f4            	movd	-12(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     286: 66 0f 6e 7c 06 cc            	movd	-52(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     28c: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     290: 66 0f 6e 74 06 a4            	movd	-92(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     296: 66 0f 6e 8c 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm1  # xmm1 = mem[0],zero,zero,zero
     29f: 66 0f 62 ce                  	punpckldq	%xmm6, %xmm1    # xmm1 = xmm1[0],xmm6[0],xmm1[1],xmm6[1]
     2a3: 66 0f 6c cf                  	punpcklqdq	%xmm7, %xmm1    # xmm1 = xmm1[0],xmm7[0]
     2a7: 66 41 0f ef c9               	pxor	%xmm9, %xmm1
     2ac: 66 0f 6e 74 06 f8            	movd	-8(%rsi,%rax), %xmm6    # xmm6 = mem[0],zero,zero,zero
     2b2: 66 0f 6e 7c 06 d0            	movd	-48(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     2b8: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     2bc: 66 0f 6e 54 06 a8            	movd	-88(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     2c2: 66 0f 6e 74 06 80            	movd	-128(%rsi,%rax), %xmm6  # xmm6 = mem[0],zero,zero,zero
     2c8: 66 0f 62 f2                  	punpckldq	%xmm2, %xmm6    # xmm6 = xmm6[0],xmm2[0],xmm6[1],xmm2[1]
     2cc: 66 0f 6c f7                  	punpcklqdq	%xmm7, %xmm6    # xmm6 = xmm6[0],xmm7[0]
     2d0: 66 41 0f ef f2               	pxor	%xmm10, %xmm6
     2d5: 66 0f eb f1                  	por	%xmm1, %xmm6
     2d9: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     2df: 66 0f 6e 54 06 d4            	movd	-44(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     2e5: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     2e9: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     2ef: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     2f5: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     2f9: 66 0f 6c fa                  	punpcklqdq	%xmm2, %xmm7    # xmm7 = xmm7[0],xmm2[0]
     2fd: 66 0f ef fc                  	pxor	%xmm4, %xmm7
     301: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     306: 66 0f 6e 54 06 d8            	movd	-40(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     30c: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     310: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     316: 66 0f 6e 5c 06 88            	movd	-120(%rsi,%rax), %xmm3  # xmm3 = mem[0],zero,zero,zero
     31c: 66 0f 62 d9                  	punpckldq	%xmm1, %xmm3    # xmm3 = xmm3[0],xmm1[0],xmm3[1],xmm1[1]
     320: 66 0f 6c da                  	punpcklqdq	%xmm2, %xmm3    # xmm3 = xmm3[0],xmm2[0]
     324: 66 0f ef dd                  	pxor	%xmm5, %xmm3
     328: 66 0f eb df                  	por	%xmm7, %xmm3
     32c: 66 0f eb de                  	por	%xmm6, %xmm3
     330: 66 41 0f 76 d8               	pcmpeqd	%xmm8, %xmm3
     335: 66 0f fa c3                  	psubd	%xmm3, %xmm0
     339: 48 05 a0 00 00 00            	addq	$160, %rax
     33f: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     345: 0f 85 35 ff ff ff            	jne	0x280 <is_dst_one_one_one_one+0x280>
     34b: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     350: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     354: 66 0f 70 d1 55               	pshufd	$85, %xmm1, %xmm2       # xmm2 = xmm1[1,1,1,1]
     359: 66 0f fe d1                  	paddd	%xmm1, %xmm2
     35d: 66 45 0f ef c0               	pxor	%xmm8, %xmm8
     362: 0f 57 c0                     	xorps	%xmm0, %xmm0
     365: f3 0f 10 c2                  	movss	%xmm2, %xmm0            # xmm0 = xmm2[0],xmm0[1,2,3]
     369: 66 0f 6e 97 80 00 00 00      	movd	128(%rdi), %xmm2        # xmm2 = mem[0],zero,zero,zero
     371: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     377: 66 0f 6e 9f 84 00 00 00      	movd	132(%rdi), %xmm3        # xmm3 = mem[0],zero,zero,zero
     37f: 66 44 0f 70 d3 00            	pshufd	$0, %xmm3, %xmm10       # xmm10 = xmm3[0,0,0,0]
     385: 66 0f 6e a7 88 00 00 00      	movd	136(%rdi), %xmm4        # xmm4 = mem[0],zero,zero,zero
     38d: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     392: 66 0f 6e af 8c 00 00 00      	movd	140(%rdi), %xmm5        # xmm5 = mem[0],zero,zero,zero
     39a: 66 0f 70 ed 00               	pshufd	$0, %xmm5, %xmm5        # xmm5 = xmm5[0,0,0,0]
     39f: b8 8c 00 00 00               	movl	$140, %eax
     3a4: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
     3ae: 66 90                        	nop
     3b0: 66 0f 6e 74 06 f4            	movd	-12(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     3b6: 66 0f 6e 7c 06 cc            	movd	-52(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     3bc: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     3c0: 66 0f 6e 74 06 a4            	movd	-92(%rsi,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     3c6: 66 0f 6e 8c 06 7c ff ff ff   	movd	-132(%rsi,%rax), %xmm1  # xmm1 = mem[0],zero,zero,zero
     3cf: 66 0f 62 ce                  	punpckldq	%xmm6, %xmm1    # xmm1 = xmm1[0],xmm6[0],xmm1[1],xmm6[1]
     3d3: 66 0f 6c cf                  	punpcklqdq	%xmm7, %xmm1    # xmm1 = xmm1[0],xmm7[0]
     3d7: 66 41 0f ef c9               	pxor	%xmm9, %xmm1
     3dc: 66 0f 6e 74 06 f8            	movd	-8(%rsi,%rax), %xmm6    # xmm6 = mem[0],zero,zero,zero
     3e2: 66 0f 6e 7c 06 d0            	movd	-48(%rsi,%rax), %xmm7   # xmm7 = mem[0],zero,zero,zero
     3e8: 66 0f 62 fe                  	punpckldq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0],xmm7[1],xmm6[1]
     3ec: 66 0f 6e 54 06 a8            	movd	-88(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     3f2: 66 0f 6e 74 06 80            	movd	-128(%rsi,%rax), %xmm6  # xmm6 = mem[0],zero,zero,zero
     3f8: 66 0f 62 f2                  	punpckldq	%xmm2, %xmm6    # xmm6 = xmm6[0],xmm2[0],xmm6[1],xmm2[1]
     3fc: 66 0f 6c f7                  	punpcklqdq	%xmm7, %xmm6    # xmm6 = xmm6[0],xmm7[0]
     400: 66 41 0f ef f2               	pxor	%xmm10, %xmm6
     405: 66 0f eb f1                  	por	%xmm1, %xmm6
     409: 66 0f 6e 4c 06 fc            	movd	-4(%rsi,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     40f: 66 0f 6e 54 06 d4            	movd	-44(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     415: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     419: 66 0f 6e 4c 06 ac            	movd	-84(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     41f: 66 0f 6e 7c 06 84            	movd	-124(%rsi,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     425: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     429: 66 0f 6c fa                  	punpcklqdq	%xmm2, %xmm7    # xmm7 = xmm7[0],xmm2[0]
     42d: 66 0f ef fc                  	pxor	%xmm4, %xmm7
     431: 66 0f 6e 0c 06               	movd	(%rsi,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     436: 66 0f 6e 54 06 d8            	movd	-40(%rsi,%rax), %xmm2   # xmm2 = mem[0],zero,zero,zero
     43c: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     440: 66 0f 6e 4c 06 b0            	movd	-80(%rsi,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     446: 66 0f 6e 5c 06 88            	movd	-120(%rsi,%rax), %xmm3  # xmm3 = mem[0],zero,zero,zero
     44c: 66 0f 62 d9                  	punpckldq	%xmm1, %xmm3    # xmm3 = xmm3[0],xmm1[0],xmm3[1],xmm1[1]
     450: 66 0f 6c da                  	punpcklqdq	%xmm2, %xmm3    # xmm3 = xmm3[0],xmm2[0]
     454: 66 0f ef dd                  	pxor	%xmm5, %xmm3
     458: 66 0f eb df                  	por	%xmm7, %xmm3
     45c: 66 0f eb de                  	por	%xmm6, %xmm3
     460: 66 41 0f 76 d8               	pcmpeqd	%xmm8, %xmm3
     465: 66 0f fa c3                  	psubd	%xmm3, %xmm0
     469: 48 05 a0 00 00 00            	addq	$160, %rax
     46f: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     475: 0f 85 35 ff ff ff            	jne	0x3b0 <is_dst_one_one_one_one+0x3b0>
     47b: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     480: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     484: 66 0f 70 c1 55               	pshufd	$85, %xmm1, %xmm0       # xmm0 = xmm1[1,1,1,1]
     489: 66 0f fe c1                  	paddd	%xmm1, %xmm0
     48d: 66 0f 7e c0                  	movd	%xmm0, %eax
     491: 48 98                        	cltq
     493: 5d                           	popq	%rbp
     494: c3                           	retq
     495: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
     49f: 90                           	nop

00000000000004a0 <main>:
     4a0: 55                           	pushq	%rbp
     4a1: 48 89 e5                     	movq	%rsp, %rbp
     4a4: 41 57                        	pushq	%r15
     4a6: 41 56                        	pushq	%r14
     4a8: 41 54                        	pushq	%r12
     4aa: 53                           	pushq	%rbx
     4ab: bf 00 00 00 00               	movl	$0, %edi
		00000000000004ac:  R_X86_64_32	.rodata.str1.1
     4b0: be 00 00 00 00               	movl	$0, %esi
		00000000000004b1:  R_X86_64_32	.rodata.str1.1+0x1e
     4b5: e8 00 00 00 00               	callq	0x4ba <main+0x1a>
		00000000000004b6:  R_X86_64_PLT32	fopen-0x4
     4ba: 49 89 c7                     	movq	%rax, %r15
     4bd: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     4c2: be 01 00 00 00               	movl	$1, %esi
     4c7: e8 00 00 00 00               	callq	0x4cc <main+0x2c>
		00000000000004c8:  R_X86_64_PLT32	calloc-0x4
     4cc: 49 89 c6                     	movq	%rax, %r14
     4cf: 31 db                        	xorl	%ebx, %ebx
     4d1: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
     4db: 0f 1f 44 00 00               	nopl	(%rax,%rax)
     4e0: 49 8d 3c 1e                  	leaq	(%r14,%rbx), %rdi
     4e4: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     4e9: 48 29 da                     	subq	%rbx, %rdx
     4ec: be 01 00 00 00               	movl	$1, %esi
     4f1: 4c 89 f9                     	movq	%r15, %rcx
     4f4: e8 00 00 00 00               	callq	0x4f9 <main+0x59>
		00000000000004f5:  R_X86_64_PLT32	fread-0x4
     4f9: 48 01 c3                     	addq	%rax, %rbx
     4fc: 48 85 c0                     	testq	%rax, %rax
     4ff: 75 df                        	jne	0x4e0 <main+0x40>
     501: 4c 89 ff                     	movq	%r15, %rdi
     504: e8 00 00 00 00               	callq	0x509 <main+0x69>
		0000000000000505:  R_X86_64_PLT32	fclose-0x4
     509: bf 00 00 00 00               	movl	$0, %edi
		000000000000050a:  R_X86_64_32	.rodata.str1.1+0xc
     50e: be 00 00 00 00               	movl	$0, %esi
		000000000000050f:  R_X86_64_32	.rodata.str1.1+0x1e
     513: e8 00 00 00 00               	callq	0x518 <main+0x78>
		0000000000000514:  R_X86_64_PLT32	fopen-0x4
     518: 49 89 c7                     	movq	%rax, %r15
     51b: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     520: be 01 00 00 00               	movl	$1, %esi
     525: e8 00 00 00 00               	callq	0x52a <main+0x8a>
		0000000000000526:  R_X86_64_PLT32	calloc-0x4
     52a: 49 89 c4                     	movq	%rax, %r12
     52d: 31 db                        	xorl	%ebx, %ebx
     52f: 90                           	nop
     530: 49 8d 3c 1c                  	leaq	(%r12,%rbx), %rdi
     534: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     539: 48 29 da                     	subq	%rbx, %rdx
     53c: be 01 00 00 00               	movl	$1, %esi
     541: 4c 89 f9                     	movq	%r15, %rcx
     544: e8 00 00 00 00               	callq	0x549 <main+0xa9>
		0000000000000545:  R_X86_64_PLT32	fread-0x4
     549: 48 01 c3                     	addq	%rax, %rbx
     54c: 48 85 c0                     	testq	%rax, %rax
     54f: 75 df                        	jne	0x530 <main+0x90>
     551: 4c 89 ff                     	movq	%r15, %rdi
     554: e8 00 00 00 00               	callq	0x559 <main+0xb9>
		0000000000000555:  R_X86_64_PLT32	fclose-0x4
     559: 4c 89 f7                     	movq	%r14, %rdi
     55c: 4c 89 e6                     	movq	%r12, %rsi
     55f: e8 00 00 00 00               	callq	0x564 <main+0xc4>
		0000000000000560:  R_X86_64_PLT32	is_dst_one_one_one_one-0x4
     564: bf 00 00 00 00               	movl	$0, %edi
		0000000000000565:  R_X86_64_32	.rodata.str1.1+0x18
     569: 48 89 c6                     	movq	%rax, %rsi
     56c: 31 c0                        	xorl	%eax, %eax
     56e: e8 00 00 00 00               	callq	0x573 <main+0xd3>
		000000000000056f:  R_X86_64_PLT32	printf-0x4
     573: 31 c0                        	xorl	%eax, %eax
     575: 5b                           	popq	%rbx
     576: 41 5c                        	popq	%r12
     578: 41 5e                        	popq	%r14
     57a: 41 5f                        	popq	%r15
     57c: 5d                           	popq	%rbp
     57d: c3                           	retq
