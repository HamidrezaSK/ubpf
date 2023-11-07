import re
import matplotlib.pyplot as plt
from statistics import mean 
import numpy as np



def extract_times_cy(path):
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

def extract_times(path):
    with open(path) as my_file:

        content = my_file.read()
        
        average_times = re.findall(r'Average execution time: (\d+\.\d+)', content)

        average_times = [float(time) for time in average_times]

        return average_times



if __name__ == "__main__":

    vanila_cycles_hot, vanila_inst_hot = extract_times_cy("logs/log_perf_c8220_vanila_jit_hot.log")

    modified_cycles_hot, modified_inst_hot = extract_times_cy("logs/log_perf_c8220_modified_jit_hot.log") 

    # aot_cycles_hot, aot_inst_hot = extract_times_cy("bpf/log_perf_c8220_aot_hot.log")

    x86_cycles_hot, x86_inst_hot = extract_times_cy("logs/log_perf_c8220_hot.log")


    keys = [8, 16, 32, 64]


    vanila_cycles_hot = list_to_dict(vanila_cycles_hot,keys)
    vanila_inst_hot = list_to_dict(vanila_inst_hot,keys)

    modified_cycles_hot = list_to_dict(modified_cycles_hot,keys)
    modified_inst_hot = list_to_dict(modified_inst_hot,keys)

    # aot_cycles_hot = list_to_dict(aot_cycles_hot,keys)
    # aot_inst_hot = list_to_dict(aot_inst_hot,keys)

    x86_cycles_hot = list_to_dict(x86_cycles_hot,keys)
    x86_inst_hot = list_to_dict(x86_inst_hot,keys)


    vanila_jit_hot = extract_times("logs/log_perf_c8220_vanila_jit_hot.log")

    modified_jit_hot = extract_times("logs/log_perf_c8220_modified_jit_hot.log")  

    # aot_hot = extract_times("bpf/log_aot_hot.log")

    x86_hot = extract_times("logs/log_perf_c8220_hot.log")

    keys = [8, 16, 32, 64]



    vanila_jit_hot = list_to_dict(vanila_jit_hot,keys)

    modified_jit_hot = list_to_dict(modified_jit_hot,keys)

    # aot_hot = list_to_dict(aot_hot,keys)

    x86_hot = list_to_dict(x86_hot,keys)
    
    #plot

    # plot(vanila_cycles_hot, modified_cycles_hot, aot_cycles_hot, x86_cycles_hot, "Cycles")

    # plot(vanila_inst_hot, modified_inst_hot, aot_inst_hot, x86_inst_hot, "Insturctions")


    # print(mean(x86_cycles_hot[64]) - mean(x86_inst_hot[64]))
    # print(mean(modified_cycles_hot[64]) - mean(modified_inst_hot[64]))
    # print(mean(vanila_cycles_hot[64]) - mean(vanila_inst_hot[64]))


    bar_width = 0.2  # Adjust the bar width as needed

    fig, axs = plt.subplots(1, 3, figsize=(15, 5))

    x_values = np.arange(len(keys))

    mean_base = np.array([mean(vanila_jit_hot[key]) for key in keys])


    # Bar chart for each mode
    print("lets see the amout of Time:")
    for i, (mode, data) in enumerate([("vanilla_jit times", vanila_jit_hot), ("x86 times", x86_hot), ("modified_jit times", modified_jit_hot)]):
        y_values = np.array([mean(data[key]) for key in keys])
        print(mode,y_values)
        axs[0].bar(x_values + i * bar_width, y_values/mean_base, bar_width, label=mode)


    for i, (mode, data) in enumerate([("vanilla_jit", vanila_cycles_hot), ("x86", x86_cycles_hot), ("modified_jit", modified_cycles_hot)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[1].bar(x_values + i * bar_width, y_values, bar_width, label=mode)
    print("lets see the amout of instruction:")
    for i, (mode, data) in enumerate([("vanilla_jit", vanila_inst_hot), ("x86", x86_inst_hot), ("modified_jit", modified_inst_hot)]):
        y_values = np.array([mean(data[key]) for key in keys])
        print(mode,y_values)
        axs[2].bar(x_values + i * bar_width, y_values, bar_width, label=mode)

    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel("Execution Time")
    axs[0].set_title('Mean Execution Times for Different Modes')
    axs[0].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[0].set_xticklabels(keys)
    axs[0].legend()
    axs[0].grid(True)

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel("Cycles")
    axs[1].set_title('Mean Cycles for Different Modes')
    axs[1].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[1].set_xticklabels(keys)
    axs[1].legend()
    axs[1].grid(True)

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel("Insturctions")
    axs[2].set_title('Mean Instruction Count for Different Modes')
    axs[2].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[2].set_xticklabels(keys)
    axs[2].legend()
    axs[2].grid(True)

    # Show the plot
    plt.tight_layout()
    plt.show()



