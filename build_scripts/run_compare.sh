#!/bin/bash

# Set CPU governor to performance for CPU core 9
for i in {1..15}; do
  sudo cpufreq-set -c $i -g performance
done

# Change directory
cd ../

# Define the commands to run
commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

# Log file
log_file="log_vanila_jit_hot.log"

rm vec_instances/eBPF/compare/bpf/$log_file

# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done


commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

# Log file
log_file="log_modified_jit_hot.log"

rm vec_instances/eBPF/compare/bpf/$log_file
# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done

commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

# Log file
log_file="log_aot_hot.log"

rm vec_instances/eBPF/compare/bpf/$log_file
# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done

cd vec_instances/eBPF/compare/x86

commands=(
  "taskset 0x200 ./xdp_prog_8 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_16 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_32 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_64 ipv6_in.mem"
)

# Log file
log_file="log_hot.log"

rm $log_file
# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done

# Define the commands to run
commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

cd -

# Log file
log_file="log_vanila_jit_cold.log"

rm vec_instances/eBPF/compare/bpf/$log_file
touch vec_instances/eBPF/compare/bpf/$log_file


# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
    sleep 5
  done
done


commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -v -d -j -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

# Log file
log_file="log_modified_jit_cold.log"

rm vec_instances/eBPF/compare/bpf/$log_file
touch vec_instances/eBPF/compare/bpf/$log_file

# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
    sleep 5
  done
done

commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_8.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_16.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_32.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/compare/bpf/xdp_prog_64.o -d -m vec_instances/eBPF/compare/bpf/ipv6_in.mem"
)

# Log file
log_file="log_aot_cold.log"

rm vec_instances/eBPF/compare/bpf/$log_file
touch vec_instances/eBPF/compare/bpf/$log_file

# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/compare/bpf/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
    sleep 5
  done
done

cd vec_instances/eBPF/compare/x86

commands=(
  "taskset 0x200 ./xdp_prog_8 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_16 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_32 ipv6_in.mem"
  "taskset 0x200 ./xdp_prog_64 ipv6_in.mem"
)

# Log file
log_file="log_cold.log"

rm $log_file
touch $log_file

# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
    sleep 5
  done
done