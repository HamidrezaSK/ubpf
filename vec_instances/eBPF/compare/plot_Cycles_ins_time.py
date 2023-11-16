import re
import matplotlib.pyplot as plt
from statistics import mean 
import numpy as np




def list_to_dict (data, keys):
    temp = {}
    num_exp = 20

    for i in range(len(keys)):
        temp[keys[i]] = data[i*num_exp:(i+1)*num_exp]
    
    return temp

def extract_data(path):
    with open(path) as my_file:

        content = my_file.read()
        
        cycles = re.findall(r'Total cycles: (\d+)', content)
        insts = re.findall(r'Total instructions: (\d+)', content)
        average_times = re.findall(r'Average execution time: (\d+\.\d+)', content)

        cycles = [int(time) for time in cycles]
        insts = [int(time) for time in insts]
        average_times = [float(time) for time in average_times]


        return cycles, insts, average_times



if __name__ == "__main__":

    vanila_cycles, vanila_inst, vanila_times = extract_data("logs_c8220/log_vanila_jit.log")

    modified_cycles, modified_inst, modified_times = extract_data("logs_c8220/log_modified_jit.log") 

    x86_cycles, x86_inst, x86_times = extract_data("logs_c8220/log_x86.log")
    
    aot_cycles, aot_inst, aot_times = extract_data("logs_c8220/log_aot.log")


    keys = [8, 16, 32, 64]

    vanila_cycles = list_to_dict(vanila_cycles,keys)
    vanila_inst = list_to_dict(vanila_inst,keys)
    vanila_times = list_to_dict(vanila_times,keys)

    modified_cycles = list_to_dict(modified_cycles,keys)
    modified_inst = list_to_dict(modified_inst,keys)
    modified_times = list_to_dict(modified_times,keys)

    aot_cycles = list_to_dict(aot_cycles,keys)
    aot_inst = list_to_dict(aot_inst,keys)
    aot_times = list_to_dict(aot_times,keys)

    x86_cycles = list_to_dict(x86_cycles,keys)
    x86_inst = list_to_dict(x86_inst,keys)
    x86_times = list_to_dict(x86_times,keys)
    
    #plot

    bar_width = 0.2  # Adjust the bar width as needed

    fig, axs = plt.subplots(1, 3, figsize=(15, 5))

    x_values = np.arange(len(keys))

    # mean_base = np.array([mean(vanila_jit_hot[key]) for key in keys])

    print("times:")
    # Bar chart for each mode
    for i, (mode, data) in enumerate([("vanilla_jit times", vanila_times), ("x86 times", x86_times), ("modified_jit times", modified_times), ("AOT times", aot_times)]):
        y_values = np.array([mean(data[key]) for key in keys])
        print(mode,y_values)
        axs[0].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)

    print("cycles:")
    for i, (mode, data) in enumerate([("vanilla_jit cycles", vanila_cycles), ("x86 cycles", x86_cycles), ("modified_jit cycles", modified_cycles), ("AOT cycles", aot_cycles)]):
        y_values = np.array([mean(data[key]) for key in keys])
        print(mode,y_values)
        axs[1].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)
    
    print("instruction:")
    for i, (mode, data) in enumerate([("vanilla_jit inst", vanila_inst), ("x86 inst", x86_inst), ("modified_jit inst", modified_inst), ("AOT inst", aot_inst)]):
        y_values = np.array([mean(data[key]) for key in keys])
        print(mode,y_values)
        axs[2].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)

    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel("Execution Time")
    axs[0].set_title('Mean Execution Times for Different Modes')
    axs[0].grid(axis='y')
    axs[0].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[0].set_xticklabels(keys)
    axs[0].legend()

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel("Cycles")
    axs[1].set_title('Mean Cycle Count for Different Modes')
    axs[1].grid(axis='y')
    axs[1].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[1].set_xticklabels(keys)
    axs[1].legend()

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel("Insturctions")
    axs[2].set_title('Mean Instruction Count for Different Modes')
    axs[2].grid(axis='y')
    axs[2].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[2].set_xticklabels(keys)
    axs[2].legend()

    # Show the plot
    plt.tight_layout()
    plt.show()


    fig, axs = plt.subplots(1, 3, figsize=(15, 5))

    # mean_base = np.array([mean(vanila_jit_hot[key]) for key in keys])


    # Bar chart for each mode
    for i, (mode, data) in enumerate([("vanilla_jit times", vanila_times), ("x86 times", x86_times), ("modified_jit times", modified_times)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[0].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)

    for i, (mode, data) in enumerate([("vanilla_jit cycles", vanila_cycles), ("x86 cycles", x86_cycles), ("modified_jit cycles", modified_cycles)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[1].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)
 
    for i, (mode, data) in enumerate([("vanilla_jit inst", vanila_inst), ("x86 inst", x86_inst), ("modified_jit inst", modified_inst)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[2].bar(x_values + i * bar_width, y_values, bar_width, label=mode, zorder=2)

    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel("Execution Time")
    axs[0].set_title('Mean Execution Times for Different Modes')
    axs[0].grid(axis='y')
    axs[0].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[0].set_xticklabels(keys)
    axs[0].legend()

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel("Cycles")
    axs[1].set_title('Mean Cycle Count for Different Modes')
    axs[1].grid(axis='y')
    axs[1].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[1].set_xticklabels(keys)
    axs[1].legend()

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel("Insturctions")
    axs[2].set_title('Mean Instruction Count for Different Modes')
    axs[2].grid(axis='y')
    axs[2].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[2].set_xticklabels(keys)
    axs[2].legend()

    # Show the plot
    plt.tight_layout()
    plt.show()

    fig, axs = plt.subplots(1, 4, figsize=(15, 5))

    base_times = np.array([mean(vanila_times[key]) for key in keys])
    base_cycles = np.array([mean(vanila_cycles[key]) for key in keys])
    base_inst = np.array([mean(vanila_inst[key]) for key in keys])



    # Bar chart for each mode
    for i, (mode, data) in enumerate([("vanilla_jit times", vanila_times), ("x86 times", x86_times), ("modified_jit times", modified_times)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[0].bar(x_values + i * bar_width, y_values/ base_times, bar_width, zorder=2)

    for i, (mode, data) in enumerate([("vanilla_jit cycles", vanila_cycles), ("x86 cycles", x86_cycles), ("modified_jit cycles", modified_cycles)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[1].bar(x_values + i * bar_width, y_values/ base_cycles, bar_width, zorder=2)

    for i, (mode, data) in enumerate([("vanilla_jit inst", vanila_inst), ("x86 inst", x86_inst), ("modified_jit inst", modified_inst)]):
        y_values = np.array([mean(data[key]) for key in keys])
        axs[2].bar(x_values + i * bar_width, y_values/ base_inst, bar_width, label=mode, zorder=2)
    
    print("IPC:")
    for i, (mode, data, data1) in enumerate([("vanilla_jit inst", vanila_inst, vanila_cycles), ("x86 inst", x86_inst, x86_cycles), ("modified_jit inst", modified_inst,modified_cycles),("aot_jit inst", aot_inst,aot_cycles)]):
        y_values = np.array([mean(data[key]) for key in keys])
        y_values2 = np.array([mean(data1[key]) for key in keys])
        print(mode,y_values/y_values2)
        axs[3].bar(x_values + i * bar_width, y_values/y_values2, bar_width, zorder=2)

    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel("Execution Time")
    axs[0].set_title('Normalized Execution Times for Different Modes')
    axs[0].grid(axis='y')
    axs[0].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[0].set_xticklabels(keys)
    # axs[0].legend()

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel("Cycles")
    axs[1].set_title('Normalized Cycle Count for Different Modes')
    axs[1].grid(axis='y')
    axs[1].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[1].set_xticklabels(keys)
    # axs[1].legend()

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel("Insturctions")
    axs[2].set_title('Normalized Instruction Count for Different Modes')
    axs[2].grid(axis='y')
    axs[2].set_xticks(x_values + bar_width * (len(keys) - 1) / 2)
    axs[2].set_xticklabels(keys)
    axs[2].legend()

    axs[3].set_xlabel('Rules Number')
    axs[3].set_ylabel("IPC")
    axs[3].set_title('Mean Instructions per Cycle for Different Modes')
    axs[3].grid(axis='y')
    axs[3].set_xticks(x_values + bar_width * (len(keys) - 1) / 3)
    axs[3].set_xticklabels(keys)
    # axs[3].legend()

    # Show the plot
    plt.tight_layout()
    plt.show()


