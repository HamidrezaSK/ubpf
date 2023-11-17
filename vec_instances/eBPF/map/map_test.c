#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>

// Define the BPF map structure
struct my_bpf_map_def {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __type(key, int);   // Example key type (adjust as needed)
    __type(value, long); // Example value type (adjust as needed)
    __uint(max_entries, 1024);
};

// Define the BPF map instance
struct my_bpf_map_def my_map SEC(".maps");

SEC("bpf_program")
int my_bpf_program() {
    int key = 42;       // Example key
    long value = 12345; // Example value

    // Use bpf_map_update_elem to create or update the entry in the map
    int res = bpf_map_update_elem(&my_map, &key, &value, BPF_ANY);

    if (res != 0) {
        // Handle error, if any
        return res;
    }

    // Your eBPF program logic here

    return 0;
}