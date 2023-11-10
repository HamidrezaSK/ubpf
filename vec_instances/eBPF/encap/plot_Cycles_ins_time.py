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

    # Data Extraction

    vanila_cycles, vanila_inst, vanila_times = extract_data("logs/log_vanila_jit.log")

    modified_cycles, modified_inst, modified_times = extract_data("logs/log_memcpy_jit.log") 

    x86_cycles, x86_inst, x86_times = extract_data("logs/log_x86.log")
    
    aot_cycles, aot_inst, aot_times = extract_data("logs/log_aot.log")



    keys = [1000000]


    cycles = np.array([mean(vanila_cycles), mean(modified_cycles), mean(x86_cycles), mean(aot_cycles)])
    inst = np.array([mean(vanila_inst), mean(modified_inst), mean(x86_inst), mean(aot_inst)])
    times = np.array([mean(vanila_times), mean(modified_times), mean(x86_times), mean(aot_times)])

    #plot

    # Data labels and positions
    labels = ['Vanila', 'Modified', 'x86', 'AOT']
    x = np.arange(len(labels))
    width = 0.2  # Width of the bars

    # Define different colors for the bars
    colors = ['#0080FF', '#FF007F', '#00CC66', '#CC00CC']

    fig, axs = plt.subplots(1, 3, figsize=(12, 4))

    # Subplot 1: Cycles
    axs[0].bar(x, cycles, width, color=colors)
    axs[0].set_xticks(x)
    axs[0].set_xticklabels(labels)
    axs[0].set_title('Cycles')
    axs[0].legend()

    # # Subplot 2: Instructions
    axs[1].bar(x, inst, width, color=colors)
    axs[1].set_xticks(x)
    axs[1].set_xticklabels(labels)
    axs[1].set_title('Instructions')
    axs[1].legend()


    # # Subplot 3: Times
    axs[2].bar(x, times, width, color=colors)
    axs[2].set_xticks(x)
    axs[2].set_xticklabels(labels)
    axs[2].set_title('Times')
    axs[2].legend()

    plt.tight_layout()
    plt.show()
    


    # Data labels and positions
    labels = ['Vanila', 'Modified', 'x86']
    x = np.arange(len(labels))
    width = 0.2  # Width of the bars

    # Define different colors for the bars
    colors = ['#0080FF', '#FF007F', '#00CC66']

    fig, axs = plt.subplots(1, 3, figsize=(12, 4))

    # Subplot 1: Cycles
    axs[0].bar(x, cycles[:3], width, color=colors)
    axs[0].set_xticks(x)
    axs[0].set_xticklabels(labels)
    axs[0].set_title('Cycles')
    axs[0].legend()

    # # Subplot 2: Instructions
    axs[1].bar(x, inst[:3], width, color=colors)
    axs[1].set_xticks(x)
    axs[1].set_xticklabels(labels)
    axs[1].set_title('Instructions')
    axs[1].legend()


    # # Subplot 3: Times
    axs[2].bar(x, times[:3], width, color=colors)
    axs[2].set_xticks(x)
    axs[2].set_xticklabels(labels)
    axs[2].set_title('Times')
    axs[2].legend()

    plt.tight_layout()
    plt.show()

    labels = ['Vanila', 'Modified', 'x86']
    x = np.arange(len(labels))
    width = 0.2  # Width of the bars

    # Define different colors for the bars
    colors = ['#0080FF', '#FF007F', '#00CC66']

    fig, axs = plt.subplots(1, 4, figsize=(12, 4))

    # Subplot 1: Cycles
    axs[0].bar(x, cycles[:3]/cycles[2], width, color=colors)
    axs[0].set_xticks(x)
    axs[0].set_xticklabels(labels)
    axs[0].set_title('Cycles Normalised')
    axs[0].legend()

    # # Subplot 2: Instructions
    axs[1].bar(x, inst[:3]/inst[2], width, color=colors)
    axs[1].set_xticks(x)
    axs[1].set_xticklabels(labels)
    axs[1].set_title('Instructions Normalised')
    axs[1].legend()


    # # Subplot 3: Times
    axs[2].bar(x, times[:3]/times[2], width, color=colors)
    axs[2].set_xticks(x)
    axs[2].set_xticklabels(labels)
    axs[2].set_title('Times Normalised')
    axs[2].legend()

    # # Subplot 3: Times
    labels = ['Vanila', 'Modified', 'x86', 'AOT']

    labels = ['Vanila', 'Modified', 'x86', 'AOT']
    x = np.arange(len(labels))
    # Define different colors for the bars
    colors = ['#0080FF', '#FF007F', '#00CC66', '#CC00CC']
    axs[3].bar(x, inst/cycles, width, color=colors)
    axs[3].set_xticks(x)
    axs[3].set_xticklabels(labels)
    axs[3].set_title('IPC')
    axs[3].legend()

    plt.tight_layout()
    plt.show()