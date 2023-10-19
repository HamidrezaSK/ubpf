import re
import matplotlib.pyplot as plt
from statistics import mean 

def plot(vanila_jit, modified_jit, aot, x86, cache):
    keys = list(vanila_jit.keys())
    fig, axs = plt.subplots(1, 3, figsize=(15, 5))

    # Scatter plot for each mode
    for mode, data in [("aot times", aot), ("vanilla_jit times", vanila_jit), ("x86 times", x86), ("modified_jit times", modified_jit)]:
        x_values = keys
        y_values =  [mean(data[key]) for key in keys]
        axs[0].plot(x_values, y_values, label=mode, marker='o')
        y_values =  [min(data[key]) for key in keys]
        axs[1].plot(x_values, y_values, label=mode, marker='o')
        y_values =  [max(data[key]) for key in keys]
        axs[2].plot(x_values, y_values, label=mode, marker='o')


    # Customize the plot
    axs[0].set_xlabel('Rules Number')
    axs[0].set_ylabel('Execution Time')
    axs[0].set_title('Mean Execution Times for Different Modes ' + cache)
    axs[0].set_xticks(keys)
    axs[0].legend()
    axs[0].grid(True)

    axs[1].set_xlabel('Rules Number')
    axs[1].set_ylabel('Execution Time')
    axs[1].set_title('Min Execution Times for Different Modes ' + cache)
    axs[1].set_xticks(keys)
    axs[1].legend()
    axs[1].grid(True)

    axs[2].set_xlabel('Rules Number')
    axs[2].set_ylabel('Execution Time')
    axs[2].set_title('Max Execution Times for Different Modes ' + cache)
    axs[2].set_xticks(keys)
    axs[2].legend()
    axs[2].grid(True)

    # Show the plot
    plt.tight_layout()
    plt.show()


def extract_times(path):
    with open(path) as my_file:

        content = my_file.read()
        
        average_times = re.findall(r'Average execution time: (\d+\.\d+)', content)

        average_times = [float(time) for time in average_times]

        return average_times

def list_to_dict (data, keys):
    temp = {}
    num_exp = 20

    for i in range(len(keys)):
        temp[keys[i]] = data[i*num_exp:(i+1)*num_exp]
    
    return temp



if __name__ == "__main__":

    vanila_jit_hot = extract_times("bpf/log_vanila_jit_hot.log")

    modified_jit_hot = extract_times("bpf/log_modified_jit_hot.log")  

    aot_hot = extract_times("bpf/log_aot_hot.log")

    x86_hot = extract_times("x86/log_hot.log")

    keys = [8, 16, 32, 64]



    vanila_jit_hot = list_to_dict(vanila_jit_hot,keys)

    modified_jit_hot = list_to_dict(modified_jit_hot,keys)

    aot_hot = list_to_dict(aot_hot,keys)

    x86_hot = list_to_dict(x86_hot,keys)


    vanila_jit_cold = extract_times("bpf/log_vanila_jit_cold.log")

    modified_jit_cold = extract_times("bpf/log_modified_jit_cold.log")  

    aot_cold = extract_times("bpf/log_aot_cold.log")

    x86_cold = extract_times("x86/log_cold.log")

    keys = [8, 16, 32, 64]



    vanila_jit_cold = list_to_dict(vanila_jit_cold,keys)

    modified_jit_cold = list_to_dict(modified_jit_cold,keys)

    aot_cold = list_to_dict(aot_cold,keys)

    x86_cold = list_to_dict(x86_cold,keys)
    
    #plot

    plot(vanila_jit_hot, modified_jit_hot, aot_hot, x86_hot, "Hot")

    plot(vanila_jit_cold, modified_jit_cold, aot_cold, x86_cold, "Cold")




