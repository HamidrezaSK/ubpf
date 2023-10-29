# uBPF

Userspace eBPF VM

[![Main](https://github.com/iovisor/ubpf/actions/workflows/main.yml/badge.svg)](https://github.com/iovisor/ubpf/actions/workflows/main.yml)
[![Coverage Status](https://coveralls.io/repos/iovisor/ubpf/badge.svg?branch=main&service=github)](https://coveralls.io/github/iovisor/ubpf?branch=main)

## About

This project aims to create an Apache-licensed library for executing eBPF programs. The primary implementation of eBPF lives in the Linux kernel, but due to its GPL license it can't be used in many projects. 
This project incorporates a customized JIT compiler process aimed at integrating SIMD support into the uBPF regular JIT, catering to various use cases such as vectorized comparisons.

[Linux documentation for the eBPF instruction set](https://www.kernel.org/doc/Documentation/networking/filter.txt)

[Instruction set reference](https://github.com/iovisor/bpf-docs/blob/master/eBPF.md)

[API Documentation](https://iovisor.github.io/ubpf)

This project includes an eBPF assembler, disassembler, interpreter (for all platforms),
and JIT compiler (for x86-64 and Arm64 targets).

## Checking Out

Before following any of the instructions below for [building](#building-with-cmake),
[testing](#running-the-tests), [contributing](#contributing), etc, please be
sure to properly check out the source code which requires properly initializing submodules:

```
git submodule init
git submodule update --recursive
```

## Building with CMake
A build system for compiling and testing ubpf is generated for Windows, Linux and macOS platforms using [`cmake`](https://cmake.org/):

```
cmake -S . -B build -DUBPF_ENABLE_TESTS=true
cmake --build build --config Debug
```

In order to prepare your system to successfully generate the build system using CMake, follow the platform-specific instructions below.

### Windows

Building, compiling and testing on Windows requires an installation of Visual Studio (*not* VS Code -- the MSVC compiler is necessary!).

> Note: There are free-to-use versions of Visual Studio for individual developers. These versions are known as the [community version](https://visualstudio.microsoft.com/vs/community/).

You *can* build, compile and test uBPF using [VS Code but Visual Studio is still required](https://code.visualstudio.com/docs/cpp/config-msvc).

The other requirement is that you have [`nuget.exe`](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools) in your `PATH`. You can determine if your host meets this criteria by testing whether

```console
> nuget.exe
```

produces output about how to execute the program. With `nuget.exe` installed, the `cmake` configuration system will download all the required developer libraries as it configures the build system.

### macOS
First, make sure that you have the XCode Command Line Tools installed:

```console
$ xcode-select -install
```

Installing the XCode Command Linux Tools will install Apple's version of the Clang compiler and other developer-support tools.

uBpf requires that your host have several support libraries installed. The easiest way to configure your host to meet these requirements,

1. Install [homebrew](https://brew.sh/)
2. Install [boost](https://www.boost.org/):
```console
$ brew install boost
```
3. Install [LLVM](https://llvm.org/) (and related tools):
```console
$ brew install llvm cmake
$ brew install clang-format
```

Installing LLVM from Homebrew is optional for developing and using uBPF on macOS. It is required if you plan on compiling/creating eBPF programs by compiling LLVM and storing them in ELF files. If you *do* install LLVM from Homebrew, add `-DUBPF_ALTERNATE_LLVM_PATH=/opt/homebrew/opt/llvm/bin` to the `cmake` configuration command:

```console
cmake -S . -B build -DUBPF_ENABLE_TESTS=true -DUBPF_ALTERNATE_LLVM_PATH=/opt/homebrew/opt/llvm/bin
```

### Linux
TBD

## Running the tests

### Linux and MacOS
```
cmake --build build --target test --
```

### Windows
```
ctest --test-dir build
```

## Contributing

We *love* contributions!

### Preparing Code Contributions

We aim to maintain code coverage with every code change. The CI/CD pipeline will verify this invariant as part of the contribution process. However, you can calculate code coverage locally by

```console
coveralls --gcov-options '\-lp' -i $PWD/vm/ubpf_vm.c -i $PWD/vm/ubpf_jit_x86_64.c -i $PWD/vm/ubpf_loader.c
```

We also aim to maintain a consistent code format. The pre-commit git hooks configured for the uBPF repository will guarantee that code changes match the format we expect. In order for those hooks to work effectively, you must have `clang-format` installed and available on your system.

## Compiling C to eBPF

You'll need [Clang 3.7](http://llvm.org/releases/download.html#3.7.0).

    clang-3.7 -O2 -target bpf -c prog.c -o prog.o

You can then pass the contents of `prog.o` to `ubpf_load_elf`, or to the stdin of
the `vm/test` binary.

## Vectorized Comparison

To use the modified JIT compilation you neet to add option -v to your uBPF test

```console
build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem
```

Inside the ipv6_in.mem file is a IP packet which is created with scapy, the script to creat such packet is here

```console
/PATHTOYOURREP/vec_instances/eBPF/compare/bpf/packet_gen_random.py
```

The use cases can be found within the "vec_instances/eBPF/" folder. These applications have undergone prior validation by the eBPF verifier to ensure their legitimacy as eBPF applications

We aim to optimize code at the assembly level. When we examine the assembly generated by our use case object files, which you can create using the following command:
```console
llvm-objdump -d -r --section .text xdp_prog_16 > xdp_prog_16.s
```
We observe repeated patterns like the following:
```assembly
      57:	18 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00	r5 = 0 ll
		00000000000001c8:  R_BPF_64_64	lookups
      59:	61 57 00 00 00 00 00 00	r7 = *(u32 *)(r5 + 0)
      60:	bf 46 00 00 00 00 00 00	r6 = r4
      61:	5d 76 09 00 00 00 00 00	if r6 != r7 goto +9 <LBB0_20>
      62:	61 57 04 00 00 00 00 00	r7 = *(u32 *)(r5 + 4)
      63:	bf 38 00 00 00 00 00 00	r8 = r3
      64:	5d 78 06 00 00 00 00 00	if r8 != r7 goto +6 <LBB0_20>
      65:	61 57 08 00 00 00 00 00	r7 = *(u32 *)(r5 + 8)
      66:	bf 28 00 00 00 00 00 00	r8 = r2
      67:	5d 78 03 00 00 00 00 00	if r8 != r7 goto +3 <LBB0_20>
      68:	61 57 0c 00 00 00 00 00	r7 = *(u32 *)(r5 + 12)
      69:	bf 18 00 00 00 00 00 00	r8 = r1
      70:	1d 78 b7 00 00 00 00 00	if r8 == r7 goto +183 <LBB0_81>
```
Our goal is to identify these patterns and replace them with SIMD operations.

## License

Copyright 2015, Big Switch Networks, Inc. Licensed under the Apache License, Version 2.0
<LICENSE.txt or http://www.apache.org/licenses/LICENSE-2.0>.
