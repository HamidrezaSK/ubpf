import re
import matplotlib.pyplot as plt
from statistics import mean 
import numpy as np


def plot(vanila_jit, modified_jit, aot, x86, cache, md):
    keys = list(vanila_jit.keys())
    bar_width = 0.2  # Adjust the bar width as needed

    fig, axs = plt.subplots(1, 3, figsize=(15, 5))

    x_values = np.arange(len(keys))

    mean_base = np.array([mean(vanila_jit[key]) for key in keys])
    min_base = np.array([mean(vanila_jit[key]) for key in keys])
    max_base = np.array([mean(vanila_jit[key]) for key in keys])



    # Bar chart for each mode
    for i, (mode, data) in enumerate([("vanilla_jit times", vanila_jit), ("x86 times", x86), ("modified_jit times", modified_jit)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[0].bar(x_values + i * bar_width, y_values, bar_width, label=mode)
        y_values = np.array([min(data[key]) for key in keys])
        axs[1].bar(x_values + i * bar_width, y_values, bar_width, label=mode)
        y_values = np.array([max(data[key]) for key in keys])
        axs[2].bar(x_values + i * bar_width, y_values, bar_width, label=mode)

    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel(md)
    axs[0].set_title('Mean Execution Times for Different Modes ' + cache)
    axs[0].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[0].set_xticklabels(keys)
    axs[0].legend()
    axs[0].grid(True)

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel(md)
    axs[1].set_title('Min Execution Times for Different Modes ' + cache)
    axs[1].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[1].set_xticklabels(keys)
    axs[1].legend()
    axs[1].grid(True)

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel(md)
    axs[2].set_title('Max Execution Times for Different Modes ' + cache)
    axs[2].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[2].set_xticklabels(keys)
    axs[2].legend()
    axs[2].grid(True)

    # Show the plot
    plt.tight_layout()
    plt.show()


def extract_times(path):
    with open(path) as my_file:

        content = my_file.read()
        
        cycles = re.findall(r'Total cycles: (\d+)', content)
        insts = re.findall(r'Total instructions: (\d+)', content)

        cycles = [int(time) for time in cycles]
        insts = [int(time) for time in insts]

        return cycles, insts

def list_to_dict (data, keys):
    temp = {}
    num_exp = 20

    for i in range(len(keys)):
        temp[keys[i]] = data[i*num_exp:(i+1)*num_exp]
    
    return temp



if __name__ == "__main__":

    vanila_cycles_hot, vanila_inst_hot = extract_times("bpf/log_perf_vanila_jit_hot.log")

    modified_cycles_hot, modified_inst_hot = extract_times("bpf/log_perf_modified_jit_hot.log") 

    aot_cycles_hot, aot_inst_hot = extract_times("bpf/log_perf_aot_hot.log")

    x86_cycles_hot, x86_inst_hot = extract_times("x86/log_perf_hot.log")


    keys = [8, 16, 32, 64]


    vanila_cycles_hot = list_to_dict(vanila_cycles_hot,keys)
    vanila_inst_hot = list_to_dict(vanila_inst_hot,keys)

    modified_cycles_hot = list_to_dict(modified_cycles_hot,keys)
    modified_inst_hot = list_to_dict(modified_inst_hot,keys)

    aot_cycles_hot = list_to_dict(aot_cycles_hot,keys)
    aot_inst_hot = list_to_dict(aot_inst_hot,keys)

    x86_cycles_hot = list_to_dict(x86_cycles_hot,keys)
    x86_inst_hot = list_to_dict(x86_inst_hot,keys)




    vanila_cycles_cold, vanila_inst_cold = extract_times("bpf/log_perf_vanila_jit_cold.log")

    modified_cycles_cold, modified_inst_cold = extract_times("bpf/log_perf_modified_jit_cold.log") 

    aot_cycles_cold, aot_inst_cold = extract_times("bpf/log_perf_aot_cold.log")

    x86_cycles_cold, x86_inst_cold = extract_times("x86/log_perf_cold.log")





    vanila_cycles_cold = list_to_dict(vanila_cycles_cold,keys)
    vanila_inst_cold = list_to_dict(vanila_inst_cold,keys)

    modified_cycles_cold = list_to_dict(modified_cycles_cold,keys)
    modified_inst_cold = list_to_dict(modified_inst_cold,keys)

    aot_cycles_cold = list_to_dict(aot_cycles_cold,keys)
    aot_inst_cold = list_to_dict(aot_inst_cold,keys)

    x86_cycles_cold = list_to_dict(x86_cycles_cold,keys)
    x86_inst_cold = list_to_dict(x86_inst_cold,keys)
    
    #plot

    plot(vanila_cycles_hot, modified_cycles_hot, aot_cycles_hot, x86_cycles_hot, "Hot", "Cycles")
    plot(vanila_cycles_cold, modified_cycles_cold, aot_cycles_cold, x86_cycles_cold, "Cold", "Cycles")

    plot(vanila_inst_hot, modified_inst_hot, aot_inst_hot, x86_inst_hot, "Hot", "Insturctions")
    plot(vanila_inst_cold, modified_inst_cold, aot_inst_cold, x86_inst_cold, "Cold", "Insturctions")

    # print(mean(x86_cycles_hot[64]) - mean(x86_inst_hot[64]))
    # print(mean(modified_cycles_hot[64]) - mean(modified_inst_hot[64]))
    # print(mean(vanila_cycles_hot[64]) - mean(vanila_inst_hot[64]))






