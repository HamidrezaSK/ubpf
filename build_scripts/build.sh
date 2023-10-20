#!/bin/bash

sudo apt update
sudo apt install -y llvm clang python3-pip libboost-all-dev libbpf-dev cmake cpufrequtils libelf-dev libpcap-dev build-essential linux-tools-common linux-tools-generic tcpdump libc6-dev-i386 htop linux-tools-5.15.0-86-generic linux-cloud-tools-5.15.0-86-generic


cd ..

git submodule init
git submodule update --recursive

cd external/bpf_conformance/
git submodule init
git submodule update --recursive

cd -

cmake -S . -B build -DUBPF_ENABLE_TESTS=true
cmake --build build --config Debug

pip install scapy
# Change directory to vec_instances/eBPF/compare/bpf
cd vec_instances/eBPF/compare/bpf

# Run the Python script
python packet_gen_random.py

# Change back to the previous directory
cd -

# Compile eBPF programs
clang -O2 -target bpf -c vec_instances/eBPF/compare/bpf/xdp_prog_32.c -o vec_instances/eBPF/compare/bpf/xdp_prog_32.o
clang -O2 -target bpf -c vec_instances/eBPF/compare/bpf/xdp_prog_16.c -o vec_instances/eBPF/compare/bpf/xdp_prog_16.o
clang -O2 -target bpf -c vec_instances/eBPF/compare/bpf/xdp_prog_8.c -o vec_instances/eBPF/compare/bpf/xdp_prog_8.o
clang -O2 -target bpf -c vec_instances/eBPF/compare/bpf/xdp_prog_64.c -o vec_instances/eBPF/compare/bpf/xdp_prog_64.o

# Change directory to vec_instances/eBPF/compare/x86
cd vec_instances/eBPF/compare/x86

# Run the Python script
python packet_gen_random.py

# Compile x86 programs
clang -g -O2 xdp_prog_16.c -o xdp_prog_16
clang -g -O2 xdp_prog_32.c -o xdp_prog_32
clang -g -O2 xdp_prog_8.c -o xdp_prog_8
clang -g -O2 xdp_prog_64.c -o xdp_prog_64
