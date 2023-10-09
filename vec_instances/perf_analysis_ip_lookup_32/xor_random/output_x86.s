
obj_x86.o:	file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <is_dst_one_one_one_one>:
       0: 55                           	pushq	%rbp
       1: 48 89 e5                     	movq	%rsp, %rbp
       4: 41 57                        	pushq	%r15
       6: 41 56                        	pushq	%r14
       8: 41 54                        	pushq	%r12
       a: 53                           	pushq	%rbx
       b: 48 83 ec 10                  	subq	$16, %rsp
       f: 48 89 f3                     	movq	%rsi, %rbx
      12: 49 89 fe                     	movq	%rdi, %r14
      15: c7 45 dc 00 00 00 00         	movl	$0, -36(%rbp)
      1c: 31 c0                        	xorl	%eax, %eax
      1e: 45 31 ff                     	xorl	%r15d, %r15d
      21: 45 31 e4                     	xorl	%r12d, %r12d
      24: 84 c0                        	testb	%al, %al
      26: 74 25                        	je	0x4d <is_dst_one_one_one_one+0x4d>
      28: 0f 1f 84 00 00 00 00 00      	nopl	(%rax,%rax)
      30: e8 00 00 00 00               	callq	0x35 <is_dst_one_one_one_one+0x35>
		0000000000000031:  R_X86_64_PLT32	rand-0x4
      35: 8d 48 03                     	leal	3(%rax), %ecx
      38: 85 c0                        	testl	%eax, %eax
      3a: 0f 49 c8                     	cmovnsl	%eax, %ecx
      3d: 83 e1 fc                     	andl	$-4, %ecx
      40: 29 c8                        	subl	%ecx, %eax
      42: 48 98                        	cltq
      44: 80 7c 05 dc 00               	cmpb	$0, -36(%rbp,%rax)
      49: 75 e5                        	jne	0x30 <is_dst_one_one_one_one+0x30>
      4b: eb 02                        	jmp	0x4f <is_dst_one_one_one_one+0x4f>
      4d: 31 c0                        	xorl	%eax, %eax
      4f: c6 44 05 dc 01               	movb	$1, -36(%rbp,%rax)
      54: 48 8d 04 80                  	leaq	(%rax,%rax,4), %rax
      58: 66 41 0f 6e c4               	movd	%r12d, %xmm0
      5d: 66 41 0f 6e 4c c6 08         	movd	8(%r14,%rax,8), %xmm1   # xmm1 = mem[0],zero,zero,zero
      64: 66 44 0f 70 c1 00            	pshufd	$0, %xmm1, %xmm8        # xmm8 = xmm1[0,0,0,0]
      6a: 66 41 0f 6e 54 c6 0c         	movd	12(%r14,%rax,8), %xmm2  # xmm2 = mem[0],zero,zero,zero
      71: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
      77: 66 41 0f 6e 5c c6 10         	movd	16(%r14,%rax,8), %xmm3  # xmm3 = mem[0],zero,zero,zero
      7e: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
      83: 66 41 0f 6e 64 c6 14         	movd	20(%r14,%rax,8), %xmm4  # xmm4 = mem[0],zero,zero,zero
      8a: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
      8f: b8 8c 00 00 00               	movl	$140, %eax
      94: 66 45 0f ef d2               	pxor	%xmm10, %xmm10
      99: 0f 1f 80 00 00 00 00         	nopl	(%rax)
      a0: 66 0f 6e 6c 03 f4            	movd	-12(%rbx,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      a6: 66 0f 6e 74 03 cc            	movd	-52(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      ac: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
      b0: 66 0f 6e 6c 03 a4            	movd	-92(%rbx,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
      b6: 66 0f 6e bc 03 7c ff ff ff   	movd	-132(%rbx,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
      bf: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
      c3: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
      c7: 66 41 0f ef f8               	pxor	%xmm8, %xmm7
      cc: 66 0f 6e 6c 03 f8            	movd	-8(%rbx,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
      d2: 66 0f 6e 74 03 d0            	movd	-48(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
      d8: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
      dc: 66 0f 6e 4c 03 a8            	movd	-88(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
      e2: 66 0f 6e 6c 03 80            	movd	-128(%rbx,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
      e8: 66 0f 62 e9                  	punpckldq	%xmm1, %xmm5    # xmm5 = xmm5[0],xmm1[0],xmm5[1],xmm1[1]
      ec: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
      f0: 66 41 0f ef e9               	pxor	%xmm9, %xmm5
      f5: 66 0f eb ef                  	por	%xmm7, %xmm5
      f9: 66 0f 6e 4c 03 fc            	movd	-4(%rbx,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
      ff: 66 0f 6e 74 03 d4            	movd	-44(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     105: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     109: 66 0f 6e 4c 03 ac            	movd	-84(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     10f: 66 0f 6e 7c 03 84            	movd	-124(%rbx,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     115: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     119: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     11d: 66 0f ef fb                  	pxor	%xmm3, %xmm7
     121: 66 0f 6e 0c 03               	movd	(%rbx,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     126: 66 0f 6e 74 03 d8            	movd	-40(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     12c: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     130: 66 0f 6e 4c 03 b0            	movd	-80(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     136: 66 0f 6e 54 03 88            	movd	-120(%rbx,%rax), %xmm2  # xmm2 = mem[0],zero,zero,zero
     13c: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     140: 66 0f 6c d6                  	punpcklqdq	%xmm6, %xmm2    # xmm2 = xmm2[0],xmm6[0]
     144: 66 0f ef d4                  	pxor	%xmm4, %xmm2
     148: 66 0f eb d7                  	por	%xmm7, %xmm2
     14c: 66 0f eb d5                  	por	%xmm5, %xmm2
     150: 66 41 0f 76 d2               	pcmpeqd	%xmm10, %xmm2
     155: 66 0f fa c2                  	psubd	%xmm2, %xmm0
     159: 48 05 a0 00 00 00            	addq	$160, %rax
     15f: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     165: 0f 85 35 ff ff ff            	jne	0xa0 <is_dst_one_one_one_one+0xa0>
     16b: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     170: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     174: 66 0f 70 c1 55               	pshufd	$85, %xmm1, %xmm0       # xmm0 = xmm1[1,1,1,1]
     179: 66 0f fe c1                  	paddd	%xmm1, %xmm0
     17d: 66 41 0f 7e c4               	movd	%xmm0, %r12d
     182: 41 83 c7 01                  	addl	$1, %r15d
     186: 41 83 ff 04                  	cmpl	$4, %r15d
     18a: 74 10                        	je	0x19c <is_dst_one_one_one_one+0x19c>
     18c: 8a 45 dc                     	movb	-36(%rbp), %al
     18f: 84 c0                        	testb	%al, %al
     191: 0f 85 99 fe ff ff            	jne	0x30 <is_dst_one_one_one_one+0x30>
     197: e9 b1 fe ff ff               	jmp	0x4d <is_dst_one_one_one_one+0x4d>
     19c: 49 63 c4                     	movslq	%r12d, %rax
     19f: 48 83 c4 10                  	addq	$16, %rsp
     1a3: 5b                           	popq	%rbx
     1a4: 41 5c                        	popq	%r12
     1a6: 41 5e                        	popq	%r14
     1a8: 41 5f                        	popq	%r15
     1aa: 5d                           	popq	%rbp
     1ab: c3                           	retq
     1ac: 0f 1f 40 00                  	nopl	(%rax)

00000000000001b0 <main>:
     1b0: 55                           	pushq	%rbp
     1b1: 48 89 e5                     	movq	%rsp, %rbp
     1b4: 41 57                        	pushq	%r15
     1b6: 41 56                        	pushq	%r14
     1b8: 41 54                        	pushq	%r12
     1ba: 53                           	pushq	%rbx
     1bb: 48 83 ec 10                  	subq	$16, %rsp
     1bf: 31 db                        	xorl	%ebx, %ebx
     1c1: 31 ff                        	xorl	%edi, %edi
     1c3: e8 00 00 00 00               	callq	0x1c8 <main+0x18>
		00000000000001c4:  R_X86_64_PLT32	time-0x4
     1c8: 89 c7                        	movl	%eax, %edi
     1ca: e8 00 00 00 00               	callq	0x1cf <main+0x1f>
		00000000000001cb:  R_X86_64_PLT32	srand-0x4
     1cf: bf 00 00 00 00               	movl	$0, %edi
		00000000000001d0:  R_X86_64_32	.rodata.str1.1
     1d4: be 00 00 00 00               	movl	$0, %esi
		00000000000001d5:  R_X86_64_32	.rodata.str1.1+0x1e
     1d9: e8 00 00 00 00               	callq	0x1de <main+0x2e>
		00000000000001da:  R_X86_64_PLT32	fopen-0x4
     1de: 49 89 c7                     	movq	%rax, %r15
     1e1: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     1e6: be 01 00 00 00               	movl	$1, %esi
     1eb: e8 00 00 00 00               	callq	0x1f0 <main+0x40>
		00000000000001ec:  R_X86_64_PLT32	calloc-0x4
     1f0: 49 89 c6                     	movq	%rax, %r14
     1f3: 66 2e 0f 1f 84 00 00 00 00 00	nopw	%cs:(%rax,%rax)
     1fd: 0f 1f 00                     	nopl	(%rax)
     200: 49 8d 3c 1e                  	leaq	(%r14,%rbx), %rdi
     204: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     209: 48 29 da                     	subq	%rbx, %rdx
     20c: be 01 00 00 00               	movl	$1, %esi
     211: 4c 89 f9                     	movq	%r15, %rcx
     214: e8 00 00 00 00               	callq	0x219 <main+0x69>
		0000000000000215:  R_X86_64_PLT32	fread-0x4
     219: 48 01 c3                     	addq	%rax, %rbx
     21c: 48 85 c0                     	testq	%rax, %rax
     21f: 75 df                        	jne	0x200 <main+0x50>
     221: 4c 89 ff                     	movq	%r15, %rdi
     224: e8 00 00 00 00               	callq	0x229 <main+0x79>
		0000000000000225:  R_X86_64_PLT32	fclose-0x4
     229: bf 00 00 00 00               	movl	$0, %edi
		000000000000022a:  R_X86_64_32	.rodata.str1.1+0xc
     22e: be 00 00 00 00               	movl	$0, %esi
		000000000000022f:  R_X86_64_32	.rodata.str1.1+0x1e
     233: e8 00 00 00 00               	callq	0x238 <main+0x88>
		0000000000000234:  R_X86_64_PLT32	fopen-0x4
     238: 49 89 c7                     	movq	%rax, %r15
     23b: bf 00 00 10 00               	movl	$1048576, %edi          # imm = 0x100000
     240: be 01 00 00 00               	movl	$1, %esi
     245: e8 00 00 00 00               	callq	0x24a <main+0x9a>
		0000000000000246:  R_X86_64_PLT32	calloc-0x4
     24a: 48 89 c3                     	movq	%rax, %rbx
     24d: 45 31 e4                     	xorl	%r12d, %r12d
     250: 4a 8d 3c 23                  	leaq	(%rbx,%r12), %rdi
     254: ba 00 00 10 00               	movl	$1048576, %edx          # imm = 0x100000
     259: 4c 29 e2                     	subq	%r12, %rdx
     25c: be 01 00 00 00               	movl	$1, %esi
     261: 4c 89 f9                     	movq	%r15, %rcx
     264: e8 00 00 00 00               	callq	0x269 <main+0xb9>
		0000000000000265:  R_X86_64_PLT32	fread-0x4
     269: 49 01 c4                     	addq	%rax, %r12
     26c: 48 85 c0                     	testq	%rax, %rax
     26f: 75 df                        	jne	0x250 <main+0xa0>
     271: 4c 89 ff                     	movq	%r15, %rdi
     274: e8 00 00 00 00               	callq	0x279 <main+0xc9>
		0000000000000275:  R_X86_64_PLT32	fclose-0x4
     279: c7 45 dc 00 00 00 00         	movl	$0, -36(%rbp)
     280: 31 c0                        	xorl	%eax, %eax
     282: 45 31 ff                     	xorl	%r15d, %r15d
     285: 45 31 e4                     	xorl	%r12d, %r12d
     288: 84 c0                        	testb	%al, %al
     28a: 74 21                        	je	0x2ad <main+0xfd>
     28c: 0f 1f 40 00                  	nopl	(%rax)
     290: e8 00 00 00 00               	callq	0x295 <main+0xe5>
		0000000000000291:  R_X86_64_PLT32	rand-0x4
     295: 8d 48 03                     	leal	3(%rax), %ecx
     298: 85 c0                        	testl	%eax, %eax
     29a: 0f 49 c8                     	cmovnsl	%eax, %ecx
     29d: 83 e1 fc                     	andl	$-4, %ecx
     2a0: 29 c8                        	subl	%ecx, %eax
     2a2: 48 98                        	cltq
     2a4: 80 7c 05 dc 00               	cmpb	$0, -36(%rbp,%rax)
     2a9: 75 e5                        	jne	0x290 <main+0xe0>
     2ab: eb 02                        	jmp	0x2af <main+0xff>
     2ad: 31 c0                        	xorl	%eax, %eax
     2af: c6 44 05 dc 01               	movb	$1, -36(%rbp,%rax)
     2b4: 48 8d 04 80                  	leaq	(%rax,%rax,4), %rax
     2b8: 66 41 0f 6e c4               	movd	%r12d, %xmm0
     2bd: 66 41 0f 6e 4c c6 08         	movd	8(%r14,%rax,8), %xmm1   # xmm1 = mem[0],zero,zero,zero
     2c4: 66 44 0f 70 c1 00            	pshufd	$0, %xmm1, %xmm8        # xmm8 = xmm1[0,0,0,0]
     2ca: 66 41 0f 6e 54 c6 0c         	movd	12(%r14,%rax,8), %xmm2  # xmm2 = mem[0],zero,zero,zero
     2d1: 66 44 0f 70 ca 00            	pshufd	$0, %xmm2, %xmm9        # xmm9 = xmm2[0,0,0,0]
     2d7: 66 41 0f 6e 5c c6 10         	movd	16(%r14,%rax,8), %xmm3  # xmm3 = mem[0],zero,zero,zero
     2de: 66 0f 70 db 00               	pshufd	$0, %xmm3, %xmm3        # xmm3 = xmm3[0,0,0,0]
     2e3: 66 41 0f 6e 64 c6 14         	movd	20(%r14,%rax,8), %xmm4  # xmm4 = mem[0],zero,zero,zero
     2ea: 66 0f 70 e4 00               	pshufd	$0, %xmm4, %xmm4        # xmm4 = xmm4[0,0,0,0]
     2ef: b8 8c 00 00 00               	movl	$140, %eax
     2f4: 66 45 0f ef d2               	pxor	%xmm10, %xmm10
     2f9: 0f 1f 80 00 00 00 00         	nopl	(%rax)
     300: 66 0f 6e 6c 03 f4            	movd	-12(%rbx,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     306: 66 0f 6e 74 03 cc            	movd	-52(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     30c: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     310: 66 0f 6e 6c 03 a4            	movd	-92(%rbx,%rax), %xmm5   # xmm5 = mem[0],zero,zero,zero
     316: 66 0f 6e bc 03 7c ff ff ff   	movd	-132(%rbx,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     31f: 66 0f 62 fd                  	punpckldq	%xmm5, %xmm7    # xmm7 = xmm7[0],xmm5[0],xmm7[1],xmm5[1]
     323: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     327: 66 41 0f ef f8               	pxor	%xmm8, %xmm7
     32c: 66 0f 6e 6c 03 f8            	movd	-8(%rbx,%rax), %xmm5    # xmm5 = mem[0],zero,zero,zero
     332: 66 0f 6e 74 03 d0            	movd	-48(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     338: 66 0f 62 f5                  	punpckldq	%xmm5, %xmm6    # xmm6 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
     33c: 66 0f 6e 4c 03 a8            	movd	-88(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     342: 66 0f 6e 6c 03 80            	movd	-128(%rbx,%rax), %xmm5  # xmm5 = mem[0],zero,zero,zero
     348: 66 0f 62 e9                  	punpckldq	%xmm1, %xmm5    # xmm5 = xmm5[0],xmm1[0],xmm5[1],xmm1[1]
     34c: 66 0f 6c ee                  	punpcklqdq	%xmm6, %xmm5    # xmm5 = xmm5[0],xmm6[0]
     350: 66 41 0f ef e9               	pxor	%xmm9, %xmm5
     355: 66 0f eb ef                  	por	%xmm7, %xmm5
     359: 66 0f 6e 4c 03 fc            	movd	-4(%rbx,%rax), %xmm1    # xmm1 = mem[0],zero,zero,zero
     35f: 66 0f 6e 74 03 d4            	movd	-44(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     365: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     369: 66 0f 6e 4c 03 ac            	movd	-84(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     36f: 66 0f 6e 7c 03 84            	movd	-124(%rbx,%rax), %xmm7  # xmm7 = mem[0],zero,zero,zero
     375: 66 0f 62 f9                  	punpckldq	%xmm1, %xmm7    # xmm7 = xmm7[0],xmm1[0],xmm7[1],xmm1[1]
     379: 66 0f 6c fe                  	punpcklqdq	%xmm6, %xmm7    # xmm7 = xmm7[0],xmm6[0]
     37d: 66 0f ef fb                  	pxor	%xmm3, %xmm7
     381: 66 0f 6e 0c 03               	movd	(%rbx,%rax), %xmm1      # xmm1 = mem[0],zero,zero,zero
     386: 66 0f 6e 74 03 d8            	movd	-40(%rbx,%rax), %xmm6   # xmm6 = mem[0],zero,zero,zero
     38c: 66 0f 62 f1                  	punpckldq	%xmm1, %xmm6    # xmm6 = xmm6[0],xmm1[0],xmm6[1],xmm1[1]
     390: 66 0f 6e 4c 03 b0            	movd	-80(%rbx,%rax), %xmm1   # xmm1 = mem[0],zero,zero,zero
     396: 66 0f 6e 54 03 88            	movd	-120(%rbx,%rax), %xmm2  # xmm2 = mem[0],zero,zero,zero
     39c: 66 0f 62 d1                  	punpckldq	%xmm1, %xmm2    # xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
     3a0: 66 0f 6c d6                  	punpcklqdq	%xmm6, %xmm2    # xmm2 = xmm2[0],xmm6[0]
     3a4: 66 0f ef d4                  	pxor	%xmm4, %xmm2
     3a8: 66 0f eb d7                  	por	%xmm7, %xmm2
     3ac: 66 0f eb d5                  	por	%xmm5, %xmm2
     3b0: 66 41 0f 76 d2               	pcmpeqd	%xmm10, %xmm2
     3b5: 66 0f fa c2                  	psubd	%xmm2, %xmm0
     3b9: 48 05 a0 00 00 00            	addq	$160, %rax
     3bf: 48 3d 8c 05 00 00            	cmpq	$1420, %rax             # imm = 0x58C
     3c5: 0f 85 35 ff ff ff            	jne	0x300 <main+0x150>
     3cb: 66 0f 70 c8 ee               	pshufd	$238, %xmm0, %xmm1      # xmm1 = xmm0[2,3,2,3]
     3d0: 66 0f fe c8                  	paddd	%xmm0, %xmm1
     3d4: 66 0f 70 c1 55               	pshufd	$85, %xmm1, %xmm0       # xmm0 = xmm1[1,1,1,1]
     3d9: 66 0f fe c1                  	paddd	%xmm1, %xmm0
     3dd: 66 41 0f 7e c4               	movd	%xmm0, %r12d
     3e2: 41 83 c7 01                  	addl	$1, %r15d
     3e6: 41 83 ff 04                  	cmpl	$4, %r15d
     3ea: 74 10                        	je	0x3fc <main+0x24c>
     3ec: 8a 45 dc                     	movb	-36(%rbp), %al
     3ef: 84 c0                        	testb	%al, %al
     3f1: 0f 85 99 fe ff ff            	jne	0x290 <main+0xe0>
     3f7: e9 b1 fe ff ff               	jmp	0x2ad <main+0xfd>
     3fc: 49 63 f4                     	movslq	%r12d, %rsi
     3ff: bf 00 00 00 00               	movl	$0, %edi
		0000000000000400:  R_X86_64_32	.rodata.str1.1+0x18
     404: 31 c0                        	xorl	%eax, %eax
     406: e8 00 00 00 00               	callq	0x40b <main+0x25b>
		0000000000000407:  R_X86_64_PLT32	printf-0x4
     40b: 31 c0                        	xorl	%eax, %eax
     40d: 48 83 c4 10                  	addq	$16, %rsp
     411: 5b                           	popq	%rbx
     412: 41 5c                        	popq	%r12
     414: 41 5e                        	popq	%r14
     416: 41 5f                        	popq	%r15
     418: 5d                           	popq	%rbp
     419: c3                           	retq
