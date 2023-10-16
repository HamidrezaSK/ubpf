import re
import matplotlib.pyplot as plt
from statistics import mean 

def plot(vanila_jit, modified_jit, aot, x86):
    keys = list(vanila_jit.keys())
    fig, ax = plt.subplots()

    # Scatter plot for each mode
    for mode, data in [("aot times", aot), ("vanilla_jit times", vanila_jit), ("x86 times", x86), ("modified_jit times", modified_jit)]:
        # y_values = [mean(data[8]), mean(data[16]), mean(data[32])]  # Get execution times for each mode
        y_values =  [mean(data[key]) for key in keys]
        x_values = keys
        ax.plot(x_values, y_values, label=mode, marker='o')

    # Customize the plot
    ax.set_xlabel('Key')
    ax.set_ylabel('Execution Time')
    ax.set_title('Execution Times for Different Modes')
    ax.set_xticks(keys)
    ax.legend()

    # Show the plot
    plt.grid(True)
    plt.show()


def extract_times(path):
    with open(path) as my_file:

        content = my_file.read()
        
        average_times = re.findall(r'Average execution time: (\d+\.\d+)', content)

        average_times = [float(time) for time in average_times]

        return average_times

def list_to_dict (data, keys):
    temp = {}
    num_exp = 5

    for i in range(len(keys)):
        temp[keys[i]] = data[i*num_exp:(i+1)*num_exp]
    
    return temp



if __name__ == "__main__":

    vanila_jit = extract_times("bpf/log_vanila_jit.log")

    modified_jit = extract_times("bpf/log_modified_jit.log")  

    aot = extract_times("bpf/log_aot.log")

    x86 = extract_times("x86/log.log")

    keys = [8, 16, 32, 64]



    vanila_jit = list_to_dict(vanila_jit,keys)

    modified_jit = list_to_dict(modified_jit,keys)

    aot = list_to_dict(aot,keys)

    x86 = list_to_dict(x86,keys)
    
    # modified_jit = {8: modified_jit[:5], 16: modified_jit[5:10], 32: modified_jit[10:15]}

    # aot = {8: aot[:5], 16: aot[5:10], 32: aot[10:15]}
    
    # x86 = {8: x86[:5], 16: x86[5:10], 32: x86[10:]}

    plot(vanila_jit, modified_jit, aot, x86)




