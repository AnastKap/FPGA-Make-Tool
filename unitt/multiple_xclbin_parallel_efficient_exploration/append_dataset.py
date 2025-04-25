import os
import re
import numpy as np
import pandas as pd

import common as common

HLS_TOP_FUNC_NAME = "bandwidth"


# Get the current working directory where this Python file is located
current_directory = os.path.dirname(os.path.abspath(__file__))

# List all files in the current directory
files = os.listdir(current_directory)

# Regex pattern to match files of the type .buildExplorationFPGA_*MHz
pattern = re.compile(r"\.buildExplorationFPGA_(\d+)")

# Iterate through the files and find matches
# Initialize an empty dictionary to store the results
frequency_dict = {}

for file in files:
    match = pattern.match(file)
    if match:
        frequency = int(match.group(1))  # Extract the frequency as an integer
        key = (frequency,)  # Create a tuple with one element
        if key in frequency_dict:
            print(f"Error: Duplicate entry for frequency {frequency} MHz")
            exit(1)  # Exit with error
        frequency_dict[key] = os.path.join(file, f"hw/temp_files/reports/{HLS_TOP_FUNC_NAME}/hls_reports/{HLS_TOP_FUNC_NAME}_csynth.rpt")  # Store the folder name as the value


if not frequency_dict:
    print("Error: No matching files found for the specified pattern.")
    exit(1)


input_order = common.INPUT_ORDER
metric_order = common.METRIC_ORDER

###################################################################
## Get the actual values of the metrics
###################################################################
inputs = []
metrics = []
for key, file_path in frequency_dict.items():
    try:
        temp_array = list(key)  # Convert the tuple to a list
        inputs.append(temp_array)  # Append the list to the inputs array


        # Open the file and read its contents
        with open(file_path, 'r') as file:
            contents = file.read()
        
        # Split the contents into sections based on the specified pattern
        sections = re.split(r"={64}\n== .*\n={64}\n", contents)

        initial_whitespace = sections[0]
        initial_info = sections[1]
        perf_estimates = sections[2]
        util_estimates = sections[3]
        interaces = sections[4]

        metrics_found = []
        

        ######################################
        # Get timing information
        ######################################
        # Extract the content before "+ Latency" in perf_estimates
        perf_lines = perf_estimates.splitlines()
        content_before_latency = []
        for line in perf_lines:
            if "+ Latency" in line:
                break
            content_before_latency.append(line)
        
        target_clk = None
        estimated_clk = None
        uncertainty = None
        if content_before_latency:
            # Find the line containing "Total"
            timing_line = next((line for line in content_before_latency if "ap_clk" in line), None)
            if timing_line:
                # Split the line by '|' and process the elements
                timing_line = timing_line.split('|')[2:-1]  # Ignore the first two elements
                timing_line = [float(value.strip().replace("ns", "")) for value in timing_line]  # Remove "ns" and trim spaces
                target_clk, estimated_clk, uncertainty = timing_line
            else:
                print(f"Error: 'ap_clk' line not found for frequency {key[0]} MHz")
        else:
            print(f"Error: No content found before '+ Latency:' for frequency {key[0]} MHz")
        
        slack = abs(target_clk - uncertainty - estimated_clk)
        metrics_found.append(slack)  # Add slack to the metrics_found list

        # Find the line containing the label we want to track
        label_name = "main_loop"
        metric_line = [line for line in perf_lines if label_name in line]
        if len(metric_line) != 1:
            raise ValueError(f"Error: '{label_name}' line not found or found multiple times for frequency {key[0]} MHz")
        
        # Split the line by '|' and find the element containing '~'
        metric_line = metric_line[0].split('|')
        
        min_latency_cycles = int(metric_line[3].strip())
        max_latency_cycles = int(metric_line[4].strip())
        # Assert that min_latency is less than max_latency
        assert min_latency_cycles <= max_latency_cycles, f"Error: min_latency ({min_latency_cycles}) is not less or equalt to max_latency ({max_latency_cycles}) for frequency {key[0]} MHz"

        metrics_found.extend([min_latency_cycles, max_latency_cycles])



        ######################################
        # Get resource information
        ######################################
        # Extract the content before "+ Detail:" in util_estimates
        util_lines = util_estimates.splitlines()
        content_before_detail = []
        for line in util_lines:
            if "+ Detail:" in line:
                break
            content_before_detail.append(line)
        
        if content_before_detail:
            # Find the line containing "Total"
            total_line = next((line for line in content_before_detail if "Total" in line), None)
            if total_line:
                # Split the line by '|' and process the elements
                total_values = total_line.split('|')[2:]  # Ignore the first two elements
                total_values = [int(value.strip()) for value in total_values if value.strip().isdigit()]  # Convert to integers
                metrics_found.extend(total_values)  # Add to the metrics_found list
            else:
                print(f"Error: 'Total' line not found for frequency {key[0]} MHz")
        else:
            print(f"Error: No content found before '+ Detail:' for frequency {key[0]} MHz")
        

        metrics.append(metrics_found)
        

    
    except FileNotFoundError:
        print(f"Error: File not found for frequency {key[0]} MHz at path {file_path}")
    except Exception as e:
        print(f"Error processing file for frequency {key[0]} MHz: {e}")

print(f"The inputs array is {inputs}")
print(f"The metrics array is {metrics}")

##################################################
## Convert findings to a numpy array
##################################################
data = np.column_stack((inputs, metrics))

# Convert the data to a pandas DataFrame
columns = input_order + metric_order
df = pd.DataFrame(data, columns=columns)

# Check for duplicates based on the first N columns (input_order)
duplicates = df.duplicated(subset=input_order, keep=False)
if duplicates.any():
    print("Warning: Duplicate rows found based on input_order:")
    print(df[duplicates])

# Define the output file path
output_file = os.path.join(current_directory, common.OUTPUT_DATASET)

if os.path.exists(output_file):
    # Read the existing CSV file
    existing_df = pd.read_csv(output_file)
    
    # Check if the dimensions match
    if existing_df.shape[1] != df.shape[1]:
        raise ValueError(f"Error: Dimension mismatch between existing dataset ({existing_df.shape[1]} columns) and new dataset ({df.shape[1]} columns).")
    
    # Check if the column names and order match
    if not existing_df.columns.equals(df.columns):
        raise ValueError("Error: Column names or order do not match between the existing dataset and the new dataset.")
    
    # Concatenate the existing data with the new data
    combined_df = pd.concat([existing_df, df], ignore_index=True)
    
    # Drop duplicates based on the first N columns (input_order), keeping the last occurrence
    combined_df.drop_duplicates(subset=input_order, keep='last', inplace=True)
    
    # Save the updated DataFrame back to the CSV file
    combined_df.to_csv(output_file, index=False)
else:
    # Save the new DataFrame to the CSV file
    df.to_csv(output_file, index=False)