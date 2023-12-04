#!/bin/bash

# Set CPU governor to performance for CPU core 9
for i in {1..15}; do
  sudo cpufreq-set -c $i -g performance
done

# Change directory
cd ../

# Define the commands to run
commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/katran/lib/bpf/balancer.bpf.o -s xdp_load_balancer -d -j -m vec_instances/eBPF/katran/lib/bpf/ipv6_in_1.mem"
)

# Log file
log_file="log_vanila_jit.log"

rm vec_instances/eBPF/katran/$log_file

# Loop to run the commands 20 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/katran/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done


commands=(
  "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/katran/lib/bpf/balancer.bpf.o -s xdp_load_balancer -c -d -j -m vec_instances/eBPF/katran/lib/bpf/ipv6_in_1.mem"
)

# Log file
log_file="log_memcpy_jit.log"

rm vec_instances/eBPF/katran/$log_file
# Loop to run the commands 20 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "vec_instances/eBPF/katran/$log_file" 2>&1
    echo "Exit code: $?" >> "$log_file"
    echo "--------------------" >> "$log_file"
  done
done

# commands=(
#   "taskset 0x200 build/bin/ubpf_test vec_instances/eBPF/katran/lib/bpf/balancer.bpf.o -s xdp_load_balancer  -d  -m vec_instances/eBPF/katran/lib/bpf/ipv6_in_1.mem"
# )

# # Log file
# log_file="log_aot.log"

# rm vec_instances/eBPF/encap/bpf/$log_file
# # Loop to run the commands 5 times and log their return values
# for command in "${commands[@]}"; do
#   for i in {1..20}; do
#     echo "Running: $command"
#     $command >> "vec_instances/eBPF/encap/bpf/$log_file" 2>&1
#     echo "Exit code: $?" >> "$log_file"
#     echo "--------------------" >> "$log_file"
#   done
# done


commands=(
  "taskset 0x200 ./vec_instances/eBPF/katran_x86/lib/bpf/balancer.x86 ipv6_in.mem"
)

# Log file
log_file="log_x86.log"

rm vec_instances/eBPF/katran_x86/$log_file
# Loop to run the commands 5 times and log their return values
for command in "${commands[@]}"; do
  for i in {1..20}; do
    echo "Running: $command"
    $command >> "$log_file" 2>&1
    $command >> "vec_instances/eBPF/katran_x86/$log_file" 2>&1
    echo "--------------------" >> "$log_file"
  done
done